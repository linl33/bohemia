library(leaflet)
library(sp)
# library(leaflet.providers)
library(leaflet.extras)
library(bohemia)
library(knitr)
library(kableExtra)
library(tidyverse)
library(yaml)
library(gsheet)
library(geosphere)
library(sf)
library(rgeos)
library(htmlTable)
# rdir <- '../../rpackage/bohemia/R/'
# funs <- dir(rdir)
# for(i in 1:length(funs)){
#   source(paste0(rdir, funs[i]))
# }

# at the time of writing, version 1.8.0
# pd <- providers_default()


## Retrieve data using bohemia package
# mopeia2 <- bohemia::mopeia2
# rufiji2 <- bohemia::rufiji2
# mopeia_health_facilities <- bohemia::mopeia_health_facilities
# rufiji_health_facilities <- bohemia::rufiji_health_facilities
# locations <- bohemia::locations
# save(locations, file = 'data/locations.RData')
# save(mopeia2, file = 'data/mopeia2.rda')
# save(rufiji2, file = 'data/rufiji2.rda')
# save(mopeia_health_facilities, file = 'data/mopeia_health_facilities.rda')
# save(rufiji_health_facilities, file = 'data/rufiji_health_facilities.rda')

# load('data/mopeia2.rda')
# load('data/rufiji2.rda')
# load('data/mopeia_health_facilities.rda')
# load('data/rufiji_health_facilities.rda')
# load('data/locations.RData')
# load('data/mopeia_hamlets.RData')
# load('data/rufiji_hamlets.RData')
# # Load the location hierarchy
# if(!'locations.RData' %in% dir('data')){
#   locations <- bohemia::locations
#   save(locations, file = 'data/locations.RData')
# } else {
#   load('data/locations.RData')
# }
# 
# # Load the spatial data
# 
# # Mopeia (needs cleaning up)
# if(!'mopeia_hamlets.RData' %in% dir('data')){
#   mopeia_hamlets <- bohemia::mopeia_hamlets
#   save(mopeia_hamlets, file = 'data/mopeia_hamlets.RData')
# } else {
#   load('data/mopeia_hamlets.RData')
# }
# 
# # Rufiji (doesn't yet exist!)
# if(!'rufiji_hamlets.RData' %in% dir('data')){
#   # rufiji_hamlets <- bohemia::rufiji_hamlets
#   rufiji_hamlets <- bohemia::rufiji3
#   save(rufiji_hamlets, file = 'data/rufiji_hamlets.RData')
# } else {
#   load('data/rufiji_hamlets.RData')
# }

# get mopeia hamlet number of houses
mop_houses <- bohemia::mopeia_hamlet_details

# sort by number of houses and remove duplicates
mop_houses <- mop_houses %>% 
  group_by(Hamlet) %>% 
  summarise(households = max(households, na.rm = TRUE))


# get rufiji hamlets
rufiji_hamlets <- bohemia::rufiji3
rufiji_hamlets@data$village <- rufiji_hamlets@data$NAME_3
rufiji_hamlets@data$population <- 'Unknown'

# Define function for filtering locations based on inputs
filter_locations <- function(locations,
                             country = NULL,
                             region = NULL,
                             district = NULL,
                             ward = NULL,
                             village = NULL,
                             hamlet = NULL){
  out <- locations
  if(!is.null(country)){
    if(country != ''){
      out <- out %>% filter(Country %in% country) 
    }
  }
  if(!is.null(region)){
    if(region != ''){
      out <- out %>% filter(Region %in% region)
    }
  }
  if(!is.null(district)){
    if(district != ''){
      out <- out %>% filter(District %in% district)
    }
  }
  if(!is.null(ward)){
    if(ward != ''){
      out <- out %>% filter(Ward %in% ward) 
    }
  }
  if(!is.null(village)){
    if(village != ''){
      out <- out %>% filter(Village %in% village)
    }
  }
  if(!is.null(hamlet)){
    if(hamlet != ''){
      out <- out %>% filter(Hamlet %in% hamlet) 
    }
    
  }
  return(out)
}

locations <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765')



# add_nothing <- function(x){c('', x)}
add_nothing <- function(x){x}

# Get ODK data for recon form
refresh_data <- FALSE
tza_done <- TRUE
data_file <- 'recon.RData'

if(refresh_data){
  # read in credentials
  creds <- read_yaml('credentials.yaml')
  form_name_mz <- 'recon'
  form_name_tz <- 'recon_geo'
  
  
  # read in moz data  
  recon_mz <- odk_get_data(
    url = creds$moz_odk_server,
    id = form_name_mz,
    id2 = NULL,
    unknown_id2 = FALSE,
    uuids = NULL,
    exclude_uuids = NULL,
    user = creds$moz_odk_user,
    password = creds$moz_odk_pass
  )
  
  # get non repeat data
  recon_mz_rep <- recon_mz[[1]]
  recon_mz <- recon_mz[[2]]
  
  # Read in recon2 form from moz
  recon2_mz <- odk_get_data(
    url = creds$moz_odk_server,
    id = 'recon2',
    id2 = NULL,
    unknown_id2 = TRUE,
    uuids = NULL,
    exclude_uuids = NULL,
    user = creds$moz_odk_user,
    password = creds$moz_odk_pass
  )
  recon2_mz$non_repeats$device_id <- as.character(recon2_mz$non_repeats$device_id)
  if(!is.null(recon2_mz)){
    recon_mz_rep <- bind_rows(recon_mz_rep, recon2_mz[[1]])
    recon_mz <- bind_rows(recon_mz, recon2_mz[[2]])
  }
  
  # read in tz data
  # (now closed, so reading a saved rdata)
  # 1 more village to do, so need to temporarily unclose in future
  if('tz_done.RData' %in% dir() & tza_done){
    load('tz_done.RData')
  } else {
    recon_tz <- odk_get_data(
      url = creds$tza_odk_server,
      id = 'recon',
      id2 = NULL,
      unknown_id2 = FALSE,
      uuids = NULL,
      exclude_uuids = NULL,
      user = creds$tza_odk_user,
      password = creds$tza_odk_pass
    )
    save(recon_tz,
         file = 'tz_done.RData')
  }
  
  # get non repeat data
  recon_tz_rep <- recon_tz[[1]]
  recon_tz <- recon_tz[[2]]
  
  # change device id to numeric
  recon_tz$device_id <- as.character(recon_tz$device_id)
  
  # join tz and mz data 
  recon_data <- bind_rows(recon_tz, recon_mz)
  
  # get data data 
  recon_data$date <- as.Date(strftime(recon_data$start_time, format = "%Y-%m-%d"))
  
  # extract lat long
  recon_data$lon <- as.numeric(unlist(lapply(strsplit(recon_data$location, ' '), function(x) x[2])))
  recon_data$lat <- as.numeric(unlist(lapply(strsplit(recon_data$location, ' '), function(x) x[1])))
  
  # get indicator for if location has been geocoded
  recon_data$geo_coded <- ifelse(!is.na(recon_data$lon) | !is.na(recon_data$lat), TRUE, FALSE)
  
  # Read in the recon data xls in order to get variable names
  recon_xls <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1xe8WrTGAUsf57InDQPIQPfnKXc7FwjpHy1aZKiA-SLw/edit?usp=drive_web&ouid=117219419132871344734')
  recon_xls <- recon_xls %>%
    dplyr::select(name, question = `label::English`)
  
  # Read in the fieldworker ids
  registered_workers_tza <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=0")
  registered_workers_moz <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=490144130")
  registered_workers_other <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=179257508")
  fids <- bind_rows(registered_workers_tza %>% mutate(phone = as.character(phone)),
                    registered_workers_moz %>% mutate(phone = as.character(phone)) %>% dplyr::select(-tablet_id),
                    registered_workers_other %>% mutate(phone = as.character(phone)))
  
  # Add manual corrections as per Imani's email
  replace_wid <- function(df, instance, new_id){
    df$wid[df$instanceName == instance] <- new_id
    return(df)
  }
  
  # Some manual tanzania cleaning
  recon_data <- recon_data %>%
    replace_wid('recon-Tangimoja-2020-04-24', 58) %>%
    replace_wid('recon-SIDO-2020-04-25', 58) %>%
    replace_wid('recon-Kikibu-2020-04-26', 58) %>%
    replace_wid('recon-Mwembe Muhoro-2020-04-22', 62) %>%
    replace_wid('recon-Ngasinda-2020-04-24', 62) %>%
    replace_wid('recon-Kilombero-2020-04-30', 27) %>%
    replace_wid('recon-Kariakoo-2020-05-05', 51) %>%
    replace_wid('recon-Mkongoni-2020-04-28', 51) %>%
    replace_wid('recon-Mkole-2020-04-30', 51) %>%
    replace_wid('recon-Mapinduzi-2020-04-28', 51) %>%
    replace_wid('recon-Ngungule-2020-04-28', 51) %>%
    replace_wid("recon-Mikwang'ombe-2020-05-05", 51) %>%
    replace_wid('recon-Genju-2020-05-05', 51) %>%
    replace_wid('recon-Nyamikamba-2020-04-29', 27)
  recon_data$wid <- ifelse(recon_data$wid == 301, 108, recon_data$wid)
  recon_data$wid <- ifelse(recon_data$wid == 302, 108, recon_data$wid)
  
  # Add manual changes to number of households, per Imani's August 1 2020 email
  replace_number_hh <- function(df, instance, new_number){
    df$number_hh[df$instanceID == instance] <- new_number
    return(df)
  }
  recon_data <- recon_data %>%
    replace_number_hh('uuid:2d0f2d7a-dc3a-4b26-934d-72181cd99e3a', 130) %>%
    replace_number_hh('uuid:67180c96-b354-402c-8cab-f4e0ee8c2c7a', 103) %>%
    replace_number_hh('uuid:a7efe521-9bc6-4fb2-9eae-b63deda3884b', 203) %>%
    replace_number_hh('uuid:95756e85-349f-49ef-8803-c2f5a72a6250', 310) %>%
    replace_number_hh('uuid:a31bced6-a53c-4d25-bae3-372282c464ff', 258) %>%
    replace_number_hh('uuid:fb16a021-700c-4971-8bfc-32b746f93c3c', 152)
  
  # Add further manual changes from Imani
  recon_data$wid <- ifelse(recon_data$wid == 301, 108, recon_data$wid)
  recon_data$wid <- ifelse(recon_data$wid == 302, 108, recon_data$wid)
  
  # Drop duplicates (from where)
  bad_ids <- c("uuid:b6b28300-1b0b-43d3-9b0b-3ce21353d5fc",
               "uuid:55d6d8d0-3e9c-41dd-be95-a6124c512378",
               "uuid:e230358d-3e51-4df9-bdb1-2defb261983d",
               "uuid:43ef137d-558f-49df-9804-4f1c9dec3697",
               "uuid:7b64159c-29a7-4da4-8bb2-99cce28e58d0",
               "uuid:bb23ee5c-cbd8-4e1c-8085-587b9f16382e",
               "uuid:f25d3a3a-a7b2-48cc-8e3e-d2ec08ad0584",
               "uuid:1ae6260f-32c4-4f34-af15-8c047b6d166a",
               "uuid:da49d73c-d370-4747-b530-1d3cabd83c27",
               "uuid:bb276094-f5d0-406c-bcd1-c55cde178d93",
               "uuid:3d5f3519-8fa1-4161-8b67-2e0e33c15472")
  recon_data <- recon_data %>%
    filter(!instanceID %in% bad_ids)
  # Name fix
  recon_data <- recon_data %>%
    mutate(hamlet_code = ifelse(instanceID == 'uuid:33dc64ac-0065-4cc8-823b-6179486de466',
                                'MMN',
                                hamlet_code))
  recon_data <- recon_data %>%
    mutate(Hamlet = ifelse(instanceID == 'uuid:33dc64ac-0065-4cc8-823b-6179486de466',
                           'Malenda Halisi',
                           Hamlet))
  # Drop if no chief in Tanzania
  recon_data$drop <- recon_data$Country == 'Tanzania' &
    !recon_data$instanceID %in% recon_tz_rep$repeat_chief$instanceID
  recon_data <- recon_data %>% filter(!drop)
  
  chiefs <- bind_rows(recon_tz_rep[[1]],
                      recon_mz_rep[[1]])
  chiefs <- chiefs %>% filter(!instanceID %in% bad_ids)
  
  # Get animal annex
  animal_mz <- odk_get_data(
    url = creds$moz_odk_server,
    id = 'animalannex',
    id2 = NULL,
    unknown_id2 = FALSE,
    uuids = NULL,
    exclude_uuids = NULL,
    user = creds$moz_odk_user,
    password = creds$moz_odk_pass
  )
  if(tza_done){
    load('animal_tz.RData')
  } else {
    animal_tz <- odk_get_data(
      url = creds$tza_odk_server,
      id = 'animalannex',
      id2 = NULL,
      unknown_id2 = FALSE,
      uuids = NULL,
      exclude_uuids = NULL,
      user = creds$tza_odk_user,
      password = creds$tza_odk_pass
    )
    save(animal_tz,
         file = 'animal_tz.RData')
  }
  
  
  # no repeats in animal, so just keeping the non-repeats
  if(is.list(animal_mz)){
    animal_mz <- animal_mz$non_repeats
  }
  if(is.list(animal_tz)){
    animal_tz <- animal_tz$non_repeats
  }
  # Combine
  animal_mz$device_id <- as.character(animal_mz$device_id)
  animal_tz$device_id <- as.character(animal_tz$device_id)
  animal <- bind_rows(animal_mz, animal_tz)
  
  # Remove bad / duplicated ids from animal annex (TZA)
  bad_animals <- c("uuid:9bf58f63-039d-491d-8018-9d34a852cc20",
                   "uuid:aa99cd2c-78c6-4df9-b5dc-f0b6059bd2b7",
                   "uuid:29d3abae-e0b6-4b4e-89c9-f46e94a7fa5b",
                   "uuid:19f8ee8d-fecb-480d-8f18-75609ebbd5aa",
                   "uuid:e2934d79-a3f2-4d8e-baec-d0c3aa5cba81",
                   "uuid:fbce3e5b-2fa7-4496-8543-a92aea30b538",
                   "uuid:e81ac431-93e8-4069-8841-3c179ed208cc",
                   "uuid:69cf6304-f799-4640-b9fc-16a8c65a13d4",
                   "uuid:cb2e8078-256e-4cb2-bf53-c805c552dabf")
  
  # Correct incorrect fieldworkers in animal (TZA)
  animal <- replace_wid(animal, "uuid:1a79dabe-62cb-4897-8c20-d6607eeec717", 22)
  animal <- replace_wid(animal, "uuid:59b5197d-f0cd-4976-a68f-ef174b5338a5", 2)
  animal <- replace_wid(animal, "uuid:91303f21-52be-473d-8f77-7c87694d095a", 28)
  animal <- replace_wid(animal, "uuid:55f408a7-62c6-40ae-8413-2ccbdeaa9293", 66)
  animal <- replace_wid(animal, "uuid:2900856e-aa7d-4d7f-b70a-cf9b3fd42261", 62)
  
  animal <- animal %>% filter(!instanceID %in% bad_animals)
  
  
  # Manually correct the Ucheme / Njianne issues
  uuid <- "uuid:4dbcdfac-e36d-4e39-abfa-ac64c467fdb1"
  recon_data$hamlet_code[recon_data$instanceID == uuid] <- 'UCM'
  # uuid <- 'uuid:fd75edcd-1f9e-420f-94a7-691209d5d91d'
  # animal$hamlet_code[animal$instanceID == uuid] <- uuid
  
  # Correct the number of pigs
  animal <- animal %>%
    mutate(n_pigs = ifelse(instanceID == "uuid:e16ff6b2-072b-4636-bf7a-85eefd138658",
                           '0',
                           n_pigs))
  
  # get date data 
  animal$date <- as.Date(strftime(animal$start_time, format = "%Y-%m-%d"))
  
  # extract lat long
  animal$lon <- as.numeric(unlist(lapply(strsplit(animal$location, ' '), function(x) x[2])))
  animal$lat <- as.numeric(unlist(lapply(strsplit(animal$location, ' '), function(x) x[1])))
  
  # get indicator for if location has been geocoded
  animal$geo_coded <- ifelse(!is.na(animal$lon) | !is.na(animal$lat), TRUE, FALSE)
  
  # Read in the recon data xls in order to get variable names
  animal_xls <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1APsFS5BrXDu5v1jrZ4EwyOGcos4JVxV61DDe9x-HKQA/edit#gid=0')
  animal_xls <- animal_xls %>%
    dplyr::select(name, question = `label::English`)
  
  # Update the codes when missing
  # (this occured because of the fact that the code field was not required)
  fix_codes <- function(x){
    message(length(which(is.na(x$hamlet_code))), ' missing hamlet codes')
    x <- x %>%
      left_join(locations %>% 
                  dplyr::select(-clinical_trial),
                by = c("Country", "District", "Hamlet", "Region", "Village", "Ward")) %>%
      mutate(hamlet_code = ifelse(is.na(hamlet_code) | hamlet_code == 'XXX', code, hamlet_code)) %>%
      dplyr::select(-code)
    message('Reduced to ', length(which(is.na(x$hamlet_code))), ' missing hamlet codes')
    return(x)
    
  }
  animal <- fix_codes(animal)
  recon_data <- fix_codes(recon_data)
  
  # # Read in the code corrections
  # cc <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1EuQXpZ5TcFzReIDr-jJDMQdxxguSpdIVOGyzwsFStlQ/edit#gid=0')
  # cc <- cc %>% dplyr::select(instanceID, correct_code = `Correct Hamlet Code`)
  # 
  # # Make corrections
  # animal <- animal %>% left_join(cc) %>% mutate(hamlet_code = ifelse(!is.na(correct_code),
  #                                                                    correct_code,
  #                                                                    hamlet_code))
  # recon_data <- recon_data %>% left_join(cc) %>% mutate(hamlet_code = ifelse(!is.na(correct_code),
  #                                                                            correct_code,
  #                                                                            hamlet_code))
  
  

  # Save for fast loading
  save(
    # geocodes,
    animal,
    animal_xls,
    recon_data,
    recon_xls,
    chiefs,
    fids,
    file = data_file)
  
} else {
  load(data_file)
}

update_code <- function(form, uuid, code){
  form$correct_code[form$instanceID == uuid] <- code
  form$hamlet_code[form$instanceID == uuid] <- code
  return(form)
}



# More manual changes from Imani
update_nearest_hf_type <- function(data, val, uuid){
  data %>%
    mutate(type_nearest_hf = ifelse(instanceID == uuid,
                                    val,
                                    type_nearest_hf))
}
update_nearest_hf_name <- function(data, val, uuid){
  data %>%
    mutate(name_nearest_hf = ifelse(instanceID == uuid,
                                    val,
                                    name_nearest_hf))
}
recon_data <- recon_data %>%
  update_nearest_hf_type("Dispensary","uuid:f4265e2c-4fc4-4804-b775-6fae2d5e37cd") %>% 
  update_nearest_hf_type("Health center","uuid:2433dbf1-7ce9-4f57-aafa-3c0ac4a21b22") %>% 
  update_nearest_hf_type("Dispensary","uuid:e4a1ee5f-b583-4f9c-8a61-0d13319e5f70") %>% 
  update_nearest_hf_type("Dispensary","uuid:e28eb8fc-50fa-4658-87f6-9a4576d72b1d") %>% 
  update_nearest_hf_type("Dispensary","uuid:aa94f5fb-8ea2-488f-b473-264d9faa0522") %>% 
  update_nearest_hf_type("Health center","uuid:c08f4dbd-a7b9-462d-b8e8-ec433bd7a3ee") %>% 
  update_nearest_hf_type("Health center","uuid:e8f47e31-49e4-4fec-b737-c8ba64c70806") %>% 
  update_nearest_hf_type("Dispensary","uuid:762351d6-103a-4679-951e-33d99918a103") %>% 
  update_nearest_hf_type("Dispensary","uuid:35129fa3-ca18-499f-a055-a4baa159175b")
recon_data <- recon_data %>%
  update_nearest_hf_name("Ikwiriri Mission", "uuid:e28eb8fc-50fa-4658-87f6-9a4576d72b1d") %>%
  update_nearest_hf_name("Ikwiriri Health center", "uuid:5c3eb05f-5dc6-424e-8cee-67d151418823") %>%
  update_nearest_hf_name("Ikwiriri Health center", "uuid:672176fb-e6a2-4d4d-a180-04d58db4954e") %>%
  update_nearest_hf_name("Kiongoroni", "uuid:1577fc41-87e9-43f3-b2e5-84e74cdd7b8f") %>%
  update_nearest_hf_name("Kiongoroni", "uuid:1577fc41-87e9-43f3-b2e5-84e74cdd7b8f") %>%
  update_nearest_hf_name("Ikwiriri Health center", "uuid:7bf62981-333a-42f8-93b9-6cd87e6236bd") %>%
  update_nearest_hf_name("Ikwiriri Health center", "uuid:5fd18ff8-a9da-4c73-8502-47c685be5c57") %>%
  update_nearest_hf_name("Ikwiriri Health center", "uuid:a9df32d5-2203-4169-9a8c-96d3ae8bf169") %>%
  update_nearest_hf_name("FARAJA", "uuid:01f0be00-7807-4602-a9b8-4d9fd67ebd80") %>%
  update_nearest_hf_name("FARAJA", "uuid:48fa7923-60e5-415d-83a3-6d9d45024d54") %>%
  update_nearest_hf_name("FARAJA", "uuid:f4265e2c-4fc4-4804-b775-6fae2d5e37cd") %>%
  update_nearest_hf_name("FARAJA", "uuid:e4a1ee5f-b583-4f9c-8a61-0d13319e5f70") %>%
  update_nearest_hf_name("Ikwiriri Health center","uuid:e8f47e31-49e4-4fec-b737-c8ba64c70806")
recon_data$type_nearest_hf_other[recon_data$instanceID == 'uuid:35129fa3-ca18-499f-a055-a4baa159175b'] <- NA
# More Tanzania cleaning
animal$hamlet_code[animal$instanceID == 'uuid:baf2145b-aca1-4413-9508-d5ad615e9e93'] <- 'LIK'
animal$hamlet_code[animal$instanceID == 'uuid:57a35737-3254-4296-81d9-c4582b2a118a'] <- 'MKJ'
#     # Manual cleaning instructions from Eldo sent after
#     # data collection ended
#     1 - "Remove from Location Hierarchy" - All hamlets in this file should be deleted from location hierarchy, these are villages that are either duplicates or doesn't exist.
# 2 - "Remove from AnimaAnnex" - All instances in this file should be deleted from Animal, these are duplicated records.
# 3 - "Incorrect_ID" - All instances in this file should be updated using the "correct_id" column.
# If anything comes out, please let me know.
clean_moz_remove_animals <- read_csv('moz_cleaning/2-Remove from_AnimalAnnex.csv')
clean_moz_animal_remove_locations <- read_csv('moz_cleaning/1-Remove from LocationHierarchy.csv') #
clean_moz_animal_incorrect_ids <- read_csv('moz_cleaning/3 - Incorrect ID.csv')
clean_moz_recon_incorrect_ids1 <- read_csv('moz_cleaning/2-Incorrect_IDs_Recon.csv') #
clean_moz_recon_incorrect_ids2 <- read_csv('moz_cleaning/2-Incorrect_IDs_Recon2.csv') #
clean_moz_recon_remove1 <- read_csv('moz_cleaning/1-Remove_from_Recon.csv') #
clean_moz_recon_remove2 <- read_csv('moz_cleaning/1-Remove_from_Recon2.csv') #

# Remove wrong animal uuids
animal <- animal %>%
  filter(!instanceID %in% clean_moz_remove_animals$`meta:instanceID`)
# Remove incorrect locations (manually do on spreadsheet and re-render locations object)
# clean_moz_animal_remove_locations

# Adust incorrct codes
animal <- animal %>%
  left_join(clean_moz_animal_incorrect_ids %>% 
              dplyr::select(instanceID = `meta:instanceID`,
                            code_correct = Correct_ID)) %>%
  mutate(hamlet_code = ifelse(is.na(code_correct),
                              hamlet_code,
                              code_correct)) %>%
  dplyr::select(-code_correct)

# Now recon cleaning
clean_moz_recon_incorrect_ids <- 
  bind_rows(clean_moz_recon_incorrect_ids1,
            clean_moz_recon_incorrect_ids2)
recon_data <- recon_data %>%
  left_join(clean_moz_recon_incorrect_ids %>% 
              dplyr::select(instanceID = `meta:instanceID`,
                            code_correct = Correct_ID)) %>%
  mutate(hamlet_code = ifelse(is.na(code_correct),
                              hamlet_code,
                              code_correct)) %>%
  dplyr::select(-code_correct)

# Removals
recon_data <- recon_data %>%
  filter(!instanceID %in% clean_moz_recon_remove1$`meta:instanceID`) %>%
  filter(!instanceID %in% clean_moz_recon_remove2$`meta:instanceID`)


# No duplicated uids
animal <- animal %>% dplyr::distinct(instanceID, .keep_all = TRUE)
recon_data <- recon_data %>% dplyr::distinct(instanceID, .keep_all = TRUE)

# Get all locations that are geocoded
geocodes <- locations %>%
  left_join(animal %>%
              dplyr::arrange(lat) %>%
              mutate(animal_done = TRUE) %>%
              dplyr::select(animal_lat = lat,
                            animal_lng = lon,
                            code = hamlet_code,
                            animal_done) %>%
              dplyr::distinct(code, .keep_all = TRUE)) %>%
  left_join(recon_data %>%
              dplyr::arrange(lat) %>%
              mutate(recon_done = TRUE) %>%
              dplyr::select(recon_lat = lat,
                            recon_lng = lon,
                            code = hamlet_code,
                            recon_done) %>%
              dplyr::distinct(code, .keep_all = TRUE))

geocodes$distance <- NA
for(i in 1:nrow(geocodes)){
  geocodes$distance[i] <- distm(c(geocodes$animal_lng[i], geocodes$animal_lat[i]), 
                                c(geocodes$recon_lng[i], geocodes$recon_lat[i]), fun = distHaversine)
}

geocodes$lng <- ifelse(is.na(geocodes$animal_lng), geocodes$recon_lng, geocodes$animal_lng)
geocodes$lat <- ifelse(is.na(geocodes$animal_lat), geocodes$recon_lat, geocodes$animal_lat)

# Some more manual corrections
animal <- animal %>%
  mutate(hamlet_code = ifelse(instanceID == 'uuid:fd75edcd-1f9e-420f-94a7-691209d5d91d',
                              'UCM', hamlet_code))

# Clean up geocodes
geocodes <- geocodes %>% filter(code %in% locations$code)

# Manually add locations for missing geography from Tanzania
geocodes$lng[geocodes$code == 'UCM'] <- 39.11625
geocodes$lat[geocodes$code == 'UCM'] <- -7.7603228

geocodes$lat[geocodes$code == 'KOR'] <- -8.060087
geocodes$lng[geocodes$code == 'KOR'] <- 39.39556

geocodes$lat[geocodes$code == 'USM'] <- -8.016932
geocodes$lng[geocodes$code == 'USM'] <- 39.28767

geocodes$lat[geocodes$code == 'NYI'] <- -7.870281
geocodes$lng[geocodes$code == 'NYI'] <- 39.56919

if(grepl('joebrew', getwd())){
  # Identify places with no code (ie, manual hamlet entries)
  no_code_animal <- animal %>% filter(is.na(hamlet_code) | !hamlet_code %in% locations$code)
  no_code_recon <- recon_data %>% filter(is.na(hamlet_code) | !hamlet_code %in% locations$code)
  selector <- function(x){
    x %>% 
      mutate(Village = ifelse(Village == 'Other', paste0(village_other, ' (entered manually)'), Village)) %>%
      mutate(Hamlet = ifelse(Hamlet == 'Other', paste0(hamlet_other, ' (entered manually)'), Hamlet)) %>%
      mutate(hamlet_code = ifelse(is.na(hamlet_code), '', hamlet_code)) %>%
      
      dplyr::select(instanceID, Country, Region, District, Ward, Village, Hamlet, `Incorrect Hamlet Code` = hamlet_code)
  }
  
  # combined <- bind_rows(
  #   selector(no_code_animal) %>% mutate(form = 'Animal Annex'),
  #   selector(no_code_recon) %>% mutate(form = 'Recon')
  # ) %>%
  #   mutate(`Correct Hamlet Code` = '') %>%
  #   filter(Country == 'Mozambique')
  # write_csv(combined, '~/Desktop/corrections.csv')
  # 
  # Deal with duplicates
  # Generate duplicates for fixing
  make_dups <- function(df, word = 'Animal'){
    left <- df %>% filter(Country == 'Mozambique') %>% group_by(hamlet_code) %>%
      tally %>% filter(n > 1) %>% mutate(form = word)
    out <- left_join(left, df) %>% filter(!is.na(hamlet_code))
    return(out)
  }
  
  duplicates_animal <- make_dups(df = animal, 'Animal') %>% filter(Country == 'Mozambique')
  duplicates_recon <- make_dups(df = recon_data, 'Recon') %>% filter(Country == 'Mozambique')
  write_csv(duplicates_animal, '~/Desktop/duplicates_animal.csv')
  write_csv(duplicates_recon, '~/Desktop/duplicates_recon.csv')
  
  # Missing
  missing_animal <- locations$code[!locations$code %in% animal$hamlet_code &
                                     locations$Country == 'Mozambique']
  missing_animal <- sort(unique(missing_animal))
  missing_recon <- locations$code[!locations$code %in% recon_data$hamlet_code &
                                    locations$Country == 'Mozambique']
  missing_recon <- sort(unique(missing_recon))
  write_csv(tibble(code = missing_animal), '~/Desktop/missing_animal.csv')  
  write_csv(tibble(code = missing_recon), '~/Desktop/missing_recon.csv')
  # Write to the spreadsheet here: https://docs.google.com/spreadsheets/d/1uFEHmL6rRdAvEPHe8wwOdUy6ntGBFh_RAs2hntR-Rig/edit#gid=664792461
  
}

# Get a cleaned, final df for animals
# Get the locations
left <- geocodes

left <- left %>% 
  filter(!duplicated(code)) %>%
  dplyr::select(code, lng, lat, clinical_trial, Country)
# Get the animal info
right <- animal %>%
  filter(!duplicated(hamlet_code)) %>%
  mutate(code = hamlet_code) %>%
  dplyr::select(code,
                contains('n_'))
# Join locations and animal info
joined <- left_join(left, right)
# Get the number of residents info
right <- recon_data %>%
  filter(!duplicated(hamlet_code)) %>%
  mutate(code = hamlet_code) %>%
  dplyr::select(code,
                n_households = number_hh)
# Join all info
df <- left_join(joined, right)
message(nrow(df), ' locations. Removing those without geocoding reduces to:')
df <- df %>% filter(!is.na(lng), !is.na(lat))
message(nrow(df), ' locations.')
# Get chiefs
right <- recon_data %>% dplyr::select(instanceID, code = hamlet_code) %>%
  left_join(
    chiefs %>% dplyr::distinct(instanceID, .keep_all = TRUE) %>%
      dplyr::select(instanceID, chief_name, chief_contact)
  )
df <- left_join(df, right)

# Write a locations thing for gps
gps <- df %>%
  left_join(recon_data %>% dplyr::select(code = hamlet_code, religion, electricity, contains('telecom_have')))
gps$iso <- ifelse(gps$Country == 'Mozambique', 'MOZ', 'TZA')
gps <- gps %>% 
  left_join(locations %>% dplyr::select(Ward, Village, Hamlet, code)) %>%
  dplyr::select(iso, code, ward = Ward, village = Village, hamlet = Hamlet, lng, lat, clinical_trial, n_cattle, n_goats, n_pigs, n_households,
                             religion, electricity, telecom_have_data, telecom_have_voice, chief_name)
# write_csv(gps, '~/Desktop/gps.csv')
# usethis::use_data(gps)
# Copy paste to google sheets
# xdf = df
# xdf <- left_join(xdf, locations %>% dplyr::select(-clinical_trial, -Country))
# 
# y = xdf %>% filter(is.na(lat))
# # Make a leaflet map of all locations
# library(leaflet)
# library(leaflet.extras)
# m = leaflet() %>% 
#   # addTiles() %>%
#   addProviderTiles(providers$Esri.WorldImagery,
#                    group = 'Satellite', options = providerTileOptions(zIndex = 3)) %>%
#   addProviderTiles(providers$OpenStreetMap,
#                    group = 'OSM', options = providerTileOptions(zIndex = 1000)
#   ) %>%
#   addProviderTiles(providers$Hydda.RoadsAndLabels, group = 'Places and names', options = providerTileOptions(zIndex = 10000)) %>%
#   
# 
#   addLayersControl(
#     baseGroups = c(#'ESRI WSM', 
#       'OSM',
#                    'Satellite'),
#     # overlayGroups = c(
#     #   'Places and names'
#     # ),
#     position = 'bottomright') %>%
#   addScaleBar(position = 'topright') %>%
#   addMarkers(data = xdf,
#              popup = paste0(xdf$code, ": Ward: ", xdf$Ward, ' | Village: ', xdf$Village, ' | Hamlet: ', xdf$Hamlet),
#              label = paste0(xdf$code, ": Ward: ", xdf$Ward, ' | Village: ', xdf$Village, ' | Hamlet: ', xdf$Hamlet),
#              options = markerOptions(riseOnHover = T))
# 
# library(htmlwidgets)
# saveWidget(m, file="map.html")
