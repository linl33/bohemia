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
    refresh_data <- TRUE
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
                   # "uuid:387ad05d-aa9e-4009-b351-89527237cd9e", # ok, email aug 5
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
      
      # Remove bad / duplicated ids from animal annex
      bad_animals <- c("uuid:9bf58f63-039d-491d-8018-9d34a852cc20",
                       "uuid:aa99cd2c-78c6-4df9-b5dc-f0b6059bd2b7",
                       "uuid:29d3abae-e0b6-4b4e-89c9-f46e94a7fa5b",
                       "uuid:19f8ee8d-fecb-480d-8f18-75609ebbd5aa",
                       "uuid:e2934d79-a3f2-4d8e-baec-d0c3aa5cba81",
                       "uuid:fbce3e5b-2fa7-4496-8543-a92aea30b538",
                       "uuid:e81ac431-93e8-4069-8841-3c179ed208cc",
                       "uuid:69cf6304-f799-4640-b9fc-16a8c65a13d4",
                       "uuid:cb2e8078-256e-4cb2-bf53-c805c552dabf")
      
      # Correct incorrect fieldworkers in animal
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
      
      # Clean up geocodes
      geocodes <- geocodes %>% filter(code %in% locations$code)
      
      # Manually add locations for missing geography from Tanzania
      geocodes$lng[geocodes$code == 'UCM'] <- 39.11625
      geocodes$lat[geocodes$code == 'UCM'] <- -7.7603228
      
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
    
    # Make manual modifications for Mozambique (per Eldo's guidance)
    bad_animal_ids <- c('uuid:3e6c8142-e462-4a40-9716-68792de1b384',
                        'uuid:5014fb67-29d3-4cf2-9cdf-61043326c48c',
                        'uuid:7706ce79-c72a-4631-a3a3-8bc2ecb36e18',
                        'uuid:c0937bf1-2f3f-46c1-9fde-6cfb59c55aab',
                        'uuid:ca1bb9da-fe89-41d6-98e7-9d72a691d9ba',
                        'uuid:cec3c6ed-c37f-4d2b-afaa-7f4684ba43a9',
                        'uuid:24aa0493-36a8-4069-8335-0a3446db091e',
                        'uuid:b2cc4199-d6f0-4ed0-886b-fd087d3d1e38')
    animal <- animal %>%
      filter(!instanceID %in% bad_animal_ids)
    recon_data <- recon_data %>%
      filter(!instanceID %in% bad_animal_ids)
    update_code <- function(form, uuid, code){
        form$correct_code[form$instanceID == uuid] <- code
        form$hamlet_code[form$instanceID == uuid] <- code
        return(form)
    }
    animal <- animal %>%
      update_code('uuid:05bfc2dd-dbad-4be4-b97f-ad5dcf4a75f0', 'VDB') %>%
      update_code('uuid:3e8c57cb-acff-4ece-8d4c-f0b22c4608ef', 'VDA') %>%
      update_code('uuid:7ff0e819-0ba4-4e23-9738-af077a77ee07', 'NAM') %>%
      update_code('uuid:8bdbf704-9583-415d-b259-6ef0b3e3ec45', 'SAC') %>%
      update_code('uuid:1271703f-e23b-4a0d-9c06-50df264b9c12', 'NXX') %>%
      update_code('uuid:1d471088-7f15-4d5c-9083-ae79b48ac30a', 'CFE') %>%
      update_code('uuid:1d94f6da-d242-4090-9c2e-2092a4928e6b', 'SDS') %>%
      update_code('uuid:567d130b-dcd1-4569-b604-f7b5223206ca', 'MHA') %>%
      update_code('uuid:7ad1bd1f-747d-40ad-b8b8-a07fee8d944c', 'AGG') %>%
      update_code('uuid:822a7716-3b5f-4d93-ac6b-ae92f7dfd3af', 'NDD') %>%
      update_code('uuid:c6790df0-82c3-478b-8b82-b76f60c9bd55', 'ZZE') %>%
      update_code('uuid:d8ef43e8-be5f-4e52-bdb7-7145655c7bff', 'NOB') %>%
      update_code('uuid:f3a716bb-9142-4d85-b68d-1e3ac0b3face', 'NIB') %>%
      update_code('uuid:f5237056-8d1c-4acc-91eb-eb7b6b13d8db', 'SMG') 
    recon_data <- recon_data %>%
      update_code('uuid:27d1400d-c141-43df-8ee8-8ccfb1b284cc', 'VDA') %>%
      update_code('uuid:2e19b6c3-199a-4de9-afd5-49d80143a474', 'VDB') %>% 
      update_code('uuid:47adeac0-fd08-45cd-b828-0527647254e4', 'NAM') %>%
      update_code('uuid:875ef3e9-97ce-43f3-8f88-8e744fc2207c', 'NNU') %>%
      update_code('uuid:d456f8a2-98bf-4d49-8a7f-3036db0a1fed', 'SEA') %>%
      update_code('uuid:53376742-ee66-42a0-93ab-8010a0b620c8', 'MHA') %>%
      update_code('uuid:c05ae835-1d4c-49e4-8bd9-22b8998033d3', 'NXX') %>%
      update_code('uuid:1ca9d18e-41a4-4e30-8a32-38d6780ba07e', 'CFE') %>%
      update_code('uuid:877ab379-f1da-4fd1-90d9-b54193ef9ce3', 'MOO') %>%
      update_code('uuid:961f8734-677d-46a1-bd6d-34dc03b2c61f', 'NHB') %>%
      update_code('uuid:b47c2249-9b88-41a4-9a27-2cf0aa5d4368', 'SDS') %>%
      update_code('uuid:f768a85f-1328-406d-9e22-84ef52a16771', 'ZZE') %>%
      update_code('uuid:e2756c6d-1b59-4138-9bf9-c12750a96ee7', 'SMG')
    
    # More updates
    more_bad_animals <- c('uuid:7ad1bd1f-747d-40ad-b8b8-a07fee8d944c',
                          'uuid:9a696a91-eabe-4556-acd8-94eb53ebed1c',
                          'uuid:5e4ad910-960d-4dac-9fab-d4cc2f0f0581',
                          'uuid:2e1570f8-6fed-4d14-a61d-0fd9cc77cd4b',
                          'uuid:abe5de0a-e96b-4d44-a313-6b62c628c2ab',
                          'uuid:1c30acb0-8876-4220-8294-cbf323fce7a3',
                          'uuid:5ea40a63-8e8e-4bdb-bb26-3137ec77b2c9',
                          'uuid:fcdf54e7-96e4-4b28-96be-0a8903b0a660',
                          'uuid:c8297fbd-8fb7-4a22-a47a-de979fc6866a',
                          'uuid:1ef6384f-bb30-4625-8d13-280af2cd359c',
                          'uuid:dab59738-1791-432a-8fb0-c442fb86bbc1',
                          'uuid:eee9ab3a-f0d9-4902-aad4-801cb5eede44',
                          'uuid:ecf75eaa-c992-4a71-ac7d-19aa9e4d3eda',
                          'uuid:46029e17-fa1e-402b-84a4-f2b8575fece5',
                          'uuid:e96ce8f6-21d2-4976-b6dd-dde289327c11',
                          'uuid:9fe33a2b-ebf1-40b2-9ed3-5ff241b11844',
                          'uuid:f2515690-0f6c-4246-8a45-e80ca03bad01',
                          'uuid:6129178d-2e44-4940-a7e1-236a5856e16c',
                          'uuid:ac42366f-4ab6-4183-a152-194343cd1f62',
                          'uuid:c58f3319-4352-491f-9523-10ade02c27b0',
                          'uuid:94a44f3a-9961-4b01-bf45-8dd80e1765ce',
                          'uuid:bda6632d-468d-4a7e-bd09-be9c609d25fa',
                          'uuid:5aed2bd6-a95d-4923-8ecf-ba63a0fb76f6',
                          'uuid:31e42022-7d40-425b-ad8e-66ba2270b04e',
                          'uuid:567d130b-dcd1-4569-b604-f7b5223206ca',
                          'uuid:567d130b-dcd1-4569-b604-f7b5223206ca',
                          'uuid:fb8e4fdb-ad5c-4c54-bdf3-f60bcb8d313e',
                          'uuid:81396fd5-9360-47db-ad79-be4df3437544',
                          'uuid:1271703f-e23b-4a0d-9c06-50df264b9c12',
                          'uuid:1271703f-e23b-4a0d-9c06-50df264b9c12',
                          'uuid:16791d8c-9231-46a2-b022-d6445f8be79d',
                          'uuid:32af0f99-f230-43d4-addc-20942811af1a',
                          'uuid:5e740ef3-d330-4ad7-a64e-a751ed775e76',
                          'uuid:eae2bde1-8050-4c89-ad3a-a02299baaeb4',
                          'uuid:8dc94b82-7d41-4f0a-b47c-fb4b7173fd90',
                          'uuid:b977e14c-9597-4eaf-b82e-85e3d72100db',
                          'uuid:822a7716-3b5f-4d93-ac6b-ae92f7dfd3af',
                          'uuid:822a7716-3b5f-4d93-ac6b-ae92f7dfd3af',
                          'uuid:ebf609ba-ee6c-4204-a132-3c25512e91d9',
                          'uuid:363838dc-215d-4a14-85f7-f148cd330bb4',
                          'uuid:920f22d4-f282-47af-83aa-7361b6f631de',
                          'uuid:92c24bfd-1592-48dc-b678-3c25e0fd4a82',
                          'uuid:bc60fa20-5068-4144-8a52-c31d962ede9d',
                          'uuid:362b4115-9de6-47fb-b84c-d503ca065f2a',
                          'uuid:d4070d02-7aab-4143-b7ca-03dec0d737a2',
                          'uuid:b1f2b9c9-1e74-4c9f-870e-685c2bf6edcd',
                          'uuid:f5237056-8d1c-4acc-91eb-eb7b6b13d8db',
                          'uuid:f5237056-8d1c-4acc-91eb-eb7b6b13d8db',
                          'uuid:5bc0b7c0-b637-40ba-a0d8-6bb77847990e',
                          'uuid:b2887307-f358-4810-b544-04698c71b579',
                          'uuid:fff3a5ee-6eee-477c-a029-fa8d5b0b0faa',
                          'uuid:225c3bd1-2be5-496f-adc6-7370fa6619a2',
                          'uuid:8bdbf704-9583-415d-b259-6ef0b3e3ec45',
                          'uuid:02f58c7a-f58e-4345-8ba5-22861549043b',
                          'uuid:7ff0e819-0ba4-4e23-9738-af077a77ee07')
    animal <- animal %>%
      filter(!instanceID %in% more_bad_animals)
    animal <- animal %>%
      update_code('uuid:399c3925-84ff-48a1-a73f-8f89158373ab', 'AGZ') %>%
      update_code('uuid:5e4ad910-960d-4dac-9fab-d4cc2f0f0581', 'ALR') %>%
      update_code('uuid:f110dd4c-e85b-4476-9b86-7ddd631e3a44', 'ALF') %>%
      update_code('uuid:0303bf5b-8d3c-47dc-a87d-42dd3b487424', 'JSA') %>%
      update_code('uuid:2e1570f8-6fed-4d14-a61d-0fd9cc77cd4b', 'JON') %>%
      update_code('uuid:bc9bd35c-4be9-4496-b6e2-d0dfca68ad6d', 'JSD') %>%
      update_code('uuid:4bd0fbe8-dc9d-402b-9520-97e9ed9b6fbe', 'JSC') %>%
      update_code('uuid:567d130b-dcd1-4569-b604-f7b5223206ca', 'MHA') %>%
      update_code('uuid:1271703f-e23b-4a0d-9c06-50df264b9c12', 'NXX') %>%
      update_code('uuid:822a7716-3b5f-4d93-ac6b-ae92f7dfd3af', 'NDD') %>%
      update_code('uuid:f4fa9196-f564-4f9b-9cc6-465c31280664', 'PZS') %>%
      update_code('uuid:006fa536-099a-45e3-94c9-be6e8443e955', 'SMM') %>%
      update_code('uuid:f5237056-8d1c-4acc-91eb-eb7b6b13d8db', 'SMG') %>%
      update_code('uuid:1a086257-8e6d-4627-a813-4ff149ac7725', 'ALF') %>%
      update_code('uuid:f110dd4c-e85b-4476-9b86-7ddd631e3a44', 'ALR') %>%
      update_code('uuid:0303bf5b-8d3c-47dc-a87d-42dd3b487424', 'JON') %>%
      update_code('uuid:d8eaa89e-7d2e-445c-9bcb-064a0074cc6d', 'JSA') %>%
      update_code('uuid:9a696a91-eabe-4556-acd8-94eb53ebed1c', 'NNU') %>%
      update_code('uuid:ff687eb2-1081-4412-8200-a1c3e78a1cdb', 'SAC') %>%
      update_code('uuid:d59f0ecb-a692-451b-9a7a-ae5174abc8ea', 'SAC') %>%
      update_code('uuid:ff687eb2-1081-4412-8200-a1c3e78a1cdb', 'NNU')
    bad_recon_ids <- c(
      'uuid:dedb7ac2-0eb5-42d4-af29-36b0a0391bec',
      'uuid:92fada11-19cc-4d10-91e5-1c2a9b717fb0',
      'uuid:95b9c584-5765-4c51-a4b8-17584fbe49a3',
      'uuid:0171a8d4-0530-4b94-8abf-d851433452f6',
      'uuid:2345c18d-e168-4f99-b4f8-3e393afd5010',
      'uuid:3a3e05e0-6836-4e14-89c7-3bd78b91781e',
      'uuid:c30da5e2-05bf-440e-af89-d9aa6f9afa61',
      'uuid:9b86f445-c688-4e84-83c9-d0884c7fdc16',
      'uuid:8a77417a-46d5-42d7-ae89-35a331e39249',
      'uuid:ae3fe5a0-81c0-4f33-9fc8-dd3d88f0b181',
      'uuid:7dfe736b-479d-42f3-826f-de477b3e3335',
      'uuid:05d461d1-0911-4599-9144-959a9cc25c66',
      'uuid:db48464d-1f2f-4983-9eb3-7e420eede11e',
      'uuid:5c18541f-e83f-4179-9aa9-ead1a86c0bf3',
      'uuid:1126567a-d6db-4a29-952a-1e001582f87d',
      'uuid:6d9caad2-0c63-4268-bcd0-339651a9e386',
      'uuid:a0ca1f54-4ecc-479a-9ef9-b8fed2481526',
      'uuid:a7a6dcd2-9838-4840-8703-9c318563ffc4',
      'uuid:d245a056-c7e6-4091-aa9e-5fc867349115',
      'uuid:c16fb19e-7240-439e-aa5d-53ec7460ec69',
      'uuid:a7e723a7-98f6-4691-80b7-822c2c674556',
      'uuid:5fd37e6b-62c9-42d4-94ee-1d1e0bce91f2',
      'uuid:4ab60906-fa8a-4000-a43d-e7e34fa89102',
      'uuid:98dacf08-e06b-4336-8ef6-8b6598586982',
      'uuid:f890142c-a0e1-4ded-beb3-0e58263d8bdd',
      'uuid:6d0a862b-7ce3-46e8-87d7-27b5814ab796',
      'uuid:9d5464f4-56ec-4151-b984-0d2f447a7471',
      'uuid:a67f535f-564c-4aea-994a-50cd477a1fbe',
      'uuid:ea5cd7bf-9cc2-443b-9f99-820c27e6eb7d',
      'uuid:3a306f21-20ab-4cd4-bce1-b82c141ac3d2',
      'uuid:2e4e3f8e-efb1-4dcf-b554-e4cf94c354df',
      'uuid:1491cbf9-827d-4c0f-bb0f-baf01c32ab4c',
      'uuid:0b9c3384-3680-4cf5-a680-09cc61970d8a',
      'uuid:41ee6e3c-976c-41fd-8de3-51e179d9fe76',
      'uuid:eeb72cee-32af-440b-b150-7d2efce3746a',
      'uuid:253b296f-9159-453c-abf1-cbe90f4a4e0a',
      'uuid:47adeac0-fd08-45cd-b828-0527647254e4',
      'uuid:138aec39-19ab-450c-a947-bd9586d74e0e',
      'uuid:087c53fa-f291-4eaf-b351-4e53ffcadb98',
      'uuid:875ef3e9-97ce-43f3-8f88-8e744fc2207c',
      'uuid:b8a841c2-a02e-4068-85d0-5fd40a1c0224',
      'uuid:ede0b34b-de46-4b2b-b477-98bd8951db8e',
      'uuid:2366191e-2a80-46d2-b045-ec9fe4c8ab84',
      'uuid:6de67f3c-d5e6-4e5f-9168-f5c57cb52fcf',
      'uuid:c1f5f502-ecd6-4a4e-83c8-08932f0b044d',
      'uuid:a5da594e-e641-477a-b7c5-7dba9d9d2ac2',
      'uuid:13908bff-3165-420c-8b70-777fa41f36a7',
      'uuid:1331f782-e916-4318-ab82-c064fee603af',
      'uuid:7c1e2761-e306-4b4b-ad5e-70d5cc7d4384',
      'uuid:b020cfa8-2ca1-404f-ac21-e64549ade1cc',
      'uuid:7f61f1a1-6c3f-4171-9797-9cf34dbe0b1d',
      'uuid:c3b5b6e4-b8d1-4824-9bdc-310648fe8f7b')
    recon_data <- recon_data %>% filter(!instanceID %in% bad_recon_ids)
    recon_data <- recon_data %>%
      update_code('uuid:e836637e-68d9-466d-8be4-c3f1775c5078', 'AGO') %>%
      update_code('uuid:dedb7ac2-0eb5-42d4-af29-36b0a0391bec', 'AGX') %>%
      update_code('uuid:9ab48a2d-79a2-40d3-9d12-2edd5b1f9510', 'CAA') %>%
      update_code('uuid:cf096547-42dc-467e-ae8d-96c6335c0221', 'CAB') %>%
      update_code('uuid:0171a8d4-0530-4b94-8abf-d851433452f6', 'CCC') %>%
      update_code('uuid:0957a367-cebb-46bb-91fc-78071c827c57', 'CIE') %>%
      update_code('uuid:2345c18d-e168-4f99-b4f8-3e393afd5010', 'CMX') %>%
      update_code('uuid:5a7b8ea2-a4d6-4ba8-9639-ea7819b0e76b', 'CMX') %>%
      update_code('uuid:ec9e42b6-9719-4f22-bef6-2dbd3e7b6b52', 'JON') %>%
      update_code('uuid:95b9c584-5765-4c51-a4b8-17584fbe49a3', 'JSA') %>%
      update_code('uuid:c30da5e2-05bf-440e-af89-d9aa6f9afa61', 'JSC') %>%
      update_code('uuid:9b86f445-c688-4e84-83c9-d0884c7fdc16', 'JSD') %>%
      update_code('uuid:7c8f8fec-c716-4bc6-b228-db99ce71960d', 'LIZ') %>%
      update_code('uuid:da81f60b-59c4-4cd7-ad4e-0b7c8d782de7', 'LMA') %>%
      update_code('uuid:78668ebf-f42a-401a-a029-d7a48449afc7', 'LMB') %>%
      update_code('uuid:83ac46e9-2c70-4ce4-b228-978ac936a050', 'LOT') %>%
      update_code('uuid:4564a5b1-e026-4535-91b0-e2ea9e450473', 'MPI') %>%
      update_code('uuid:8a77417a-46d5-42d7-ae89-35a331e39249', 'MPX') %>%
      update_code('uuid:ae3fe5a0-81c0-4f33-9fc8-dd3d88f0b181', 'MRX') %>%
      update_code('uuid:17659f03-0b4c-4b54-9bce-6debc6435e3c', 'MUR') %>%
      update_code('uuid:7dfe736b-479d-42f3-826f-de477b3e3335', 'NNN') %>%
      update_code('uuid:c5855aec-59df-4b11-9e8b-180a140c1c57', 'NRA') %>%
      update_code('uuid:05d461d1-0911-4599-9144-959a9cc25c66', 'NUX') %>%
      update_code('uuid:05697bd1-4daf-4878-875c-a5723519650d', 'PZA') %>%
      update_code('uuid:0d653f1c-5d28-43c5-88b9-34112e9c5b6b', 'PZS') %>%
      update_code('uuid:fcaeb04d-76fc-4502-97a4-ef454571d8a5', 'RRB') %>%
      update_code('uuid:27d1400d-c141-43df-8ee8-8ccfb1b284cc', 'VDA') %>%
      update_code('uuid:2e19b6c3-199a-4de9-afd5-49d80143a474', 'VDB') %>%
      update_code('uuid:ea3af601-917a-4ba5-af8b-f0fcdb55a885', 'AGX') %>%
      update_code('uuid:842d1090-b0ae-47a3-8558-20f98eeae587', 'CCC') %>%
      update_code('uuid:483490b7-899a-436c-b26e-1af4b39fd7ab', 'JSD') %>%
      update_code('uuid:95b9c584-5765-4c51-a4b8-17584fbe49a3', 'JON') %>%
      update_code('uuid:ecdf03fb-4e31-4bea-aebf-6d70a4d1b39f', 'JSA') %>%
      update_code('uuid:92fada11-19cc-4d10-91e5-1c2a9b717fb0', 'CAA') 
      
    
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
    
    
    # No duplicated uids
    animal <- animal %>% dplyr::distinct(instanceID, .keep_all = TRUE)
    recon_data <- recon_data %>% dplyr::distinct(instanceID, .keep_all = TRUE)
    
    
    
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
    
