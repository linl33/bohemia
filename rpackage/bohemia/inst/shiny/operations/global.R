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
refresh_data <- F
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
  if('tz_done.RData' %in% dir() & !refresh_data){
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
  # Drop duplicates
  bad_ids <- c("uuid:b6b28300-1b0b-43d3-9b0b-3ce21353d5fc",
               "uuid:387ad05d-aa9e-4009-b351-89527237cd9e",
               "uuid:55d6d8d0-3e9c-41dd-be95-a6124c512378",
               "uuid:e230358d-3e51-4df9-bdb1-2defb261983d",
               "uuid:43ef137d-558f-49df-9804-4f1c9dec3697",
               "uuid:7b64159c-29a7-4da4-8bb2-99cce28e58d0",
               "uuid:bb23ee5c-cbd8-4e1c-8085-587b9f16382e",
               "uuid:f25d3a3a-a7b2-48cc-8e3e-d2ec08ad0584",
               "uuid:1ae6260f-32c4-4f34-af15-8c047b6d166a",
               "uuid:da49d73c-d370-4747-b530-1d3cabd83c27",
               "uuid:bb276094-f5d0-406c-bcd1-c55cde178d93")
  recon_data <- recon_data %>%
    filter(!instanceID %in% bad_ids)
  # Drop if no chief
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
  
  # Remove bad / duplicated ids from animal annex
  bad_animals <- c("uuid:9bf58f63-039d-491d-8018-9d34a852cc20",
                   "uuid:aa99cd2c-78c6-4df9-b5dc-f0b6059bd2b7",
                   "uuid:29d3abae-e0b6-4b4e-89c9-f46e94a7fa5b",
                   "uuid:19f8ee8d-fecb-480d-8f18-75609ebbd5aa",
                   "uuid:e2934d79-a3f2-4d8e-baec-d0c3aa5cba81",
                   "uuid:fbce3e5b-2fa7-4496-8543-a92aea30b538",
                   "uuid:e81ac431-93e8-4069-8841-3c179ed208cc")
  
  # Correct incorrect fieldworkers in animal
  animal <- replace_wid(animal, "uuid:1a79dabe-62cb-4897-8c20-d6607eeec717", 22)
  animal <- replace_wid(animal, "uuid:59b5197d-f0cd-4976-a68f-ef174b5338a5", 2)
  animal <- replace_wid(animal, "uuid:91303f21-52be-473d-8f77-7c87694d095a", 28)
  animal <- replace_wid(animal, "uuid:55f408a7-62c6-40ae-8413-2ccbdeaa9293", 66)
  animal <- replace_wid(animal, "uuid:2900856e-aa7d-4d7f-b70a-cf9b3fd42261", 62)

  animal <- animal %>% filter(!instanceID %in% bad_animals)
  
  # get data data 
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
  
  # Read in the code corrections
  cc <- gsheet2tbl('https://docs.google.com/spreadsheets/d/1EuQXpZ5TcFzReIDr-jJDMQdxxguSpdIVOGyzwsFStlQ/edit#gid=0')
  cc <- cc %>% dplyr::select(instanceID, correct_code = `Correct Hamlet Code`)
  
  # Make corrections
  animal <- animal %>% left_join(cc) %>% mutate(hamlet_code = ifelse(!is.na(correct_code),
                                                                     correct_code,
                                                                     hamlet_code))
  recon_data <- recon_data %>% left_join(cc) %>% mutate(hamlet_code = ifelse(!is.na(correct_code),
                                                                             correct_code,
                                                                             hamlet_code))
  
  # Remove duplicates (NOT DONE YET)
  # Use the spreadsheet here: https://docs.google.com/spreadsheets/d/1uFEHmL6rRdAvEPHe8wwOdUy6ntGBFh_RAs2hntR-Rig/edit#gid=664792461
  
  
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
  

  # Save for fast loading
  save(
    geocodes,
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
  
  combined <- bind_rows(
    selector(no_code_animal) %>% mutate(form = 'Animal Annex'),
    selector(no_code_recon) %>% mutate(form = 'Recon')
  ) %>%
    mutate(`Correct Hamlet Code` = '')
  write_csv(combined, '~/Desktop/corrections.csv')
  
  # Deal with duplicates
  # Generate duplicates for fixing
  make_dups <- function(df, word = 'Animal'){
    left <- df %>% group_by(hamlet_code) %>%
      tally %>% filter(n > 1) %>% mutate(form = word)
    out <- left_join(left, df) %>% filter(!is.na(hamlet_code))
    return(out)
  }
  
  duplicates_animal <- make_dups(df = animal, 'Animal')
  duplicates_recon <- make_dups(df = recon_data, 'Recon')
  write_csv(duplicates_animal, '~/Desktop/duplicates_animal.csv')
  write_csv(duplicates_recon, '~/Desktop/duplicates_recon.csv')
  # Write to the spreadsheet here: https://docs.google.com/spreadsheets/d/1uFEHmL6rRdAvEPHe8wwOdUy6ntGBFh_RAs2hntR-Rig/edit#gid=664792461
  
}

