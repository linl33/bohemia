#!/usr/bin/Rscript
start_time <- Sys.time()
message('System time is: ', as.character(start_time))
message('---Timezone: ', as.character(Sys.timezone()))
keyfile_path <- '../bohemia_pub.pem'
creds_fpath <- '../credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
suppressMessages({
  library(RPostgres)
  library(bohemia)
  library(yaml)
  library(dplyr)
}
)

is_local <- FALSE
drv <- RPostgres::Postgres()

if(is_local){
  con <- dbConnect(drv, dbname='bohemia')
} else {
  psql_end_point = creds$endpoint
  psql_user = creds$psql_master_username
  psql_pass = creds$psql_master_password
  con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                   port=5432,
                   user=psql_user, password=psql_pass)
}

id2 = NULL
skip_deprecated <- FALSE

############# SMALLCENSUSA TANZANIA
url <- creds$tza_odk_server
user = creds$tza_odk_user
password = creds$tza_odk_pass
id = 'smallcensusa'
suppressWarnings({
  existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
})
if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
}
# Get data
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = existing_uuids,
  user = user,
  password = password,
  pre_auth = TRUE,
  use_data_id = FALSE
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
}
if(new_data){
  # Format data
  formatted_data <- format_minicensus(data = data, keyfile = keyfile_path)
  # Update data
  update_minicensus(formatted_data = formatted_data,
                    con = con)
}

############### TANZANIA VA
message('PULLING TANZANIA VA')
url <- creds$tza_odk_server
user = creds$tza_odk_user
password = creds$tza_odk_pass
id = 'va153'
suppressWarnings({
  existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM va')
})
if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
}
# Get data
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = existing_uuids,
  user = user,
  password = password,
  pre_auth = TRUE,
  use_data_id = FALSE
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
}
if(new_data){
  # Format data
  formatted_data <- format_va(data = data, keyfile = keyfile_path)
  # Update data
  update_va(formatted_data = formatted_data,
            con = con)
}

# REFUSALS TANZANIA ######################################################################
message('PULLING REFUSALS (TANZANIA)')
url <- creds$tza_odk_server
user = creds$tza_odk_user
password = creds$tza_odk_pass
id = 'refusals'
suppressWarnings({
  existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM refusals')
})
if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
} 
# Get data
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = existing_uuids,
  user = user,
  password = password
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
  message('---', nrow(data$non_repeats), ' new data points.')
}
if(new_data){
  # Format data
  formatted_data <- format_refusals(data = data)
  # Update data
  update_refusals(formatted_data = formatted_data,
                  con = con)
}

# MINICENSUS MOZAMBIQUE #######################################################################
message('PULLING DEPRECATED MINICENSUS (MOZAMBIQUE')
if(!skip_deprecated){
  url <- creds$moz_odk_server
  user = creds$moz_odk_user
  password = creds$moz_odk_pass
  id = 'minicensus'
  suppressWarnings({
    existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
  })
  if (nrow(existing_uuids)< 0){
    existing_uuids <- c()
  } else {
    existing_uuids <- existing_uuids$instance_id
  }
  # Get data
  data <- odk_get_data(
    url = url,
    id = id,
    id2 = id2,
    unknown_id2 = FALSE,
    uuids = NULL,
    exclude_uuids = existing_uuids,
    user = user,
    password = password,
    pre_auth = TRUE,
    use_data_id = TRUE
  )
  new_data <- FALSE
  if(!is.null(data)){
    new_data <- TRUE
  }
  if(new_data){
    # Format data
    formatted_data <- format_minicensus(data = data, keyfile = keyfile_path)
    # Update data
    update_minicensus(formatted_data = formatted_data,
                      con = con)
  }
} else {
  message('...skipping')
}

# # MINICENSUS MOZAMBIQUE #######################################################################
# message('PULLING DEPRECATED MINICENSUS2 (MOZAMBIQUE')
## BROKEN / CORRUPTED: 35 FORMS
# if(!skip_deprecated){
#   url <- creds$moz_odk_server
#   user = creds$moz_odk_user
#   password = creds$moz_odk_pass
#   id = 'minicensus2'
#   suppressWarnings({
#     existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
#   })
#   if (nrow(existing_uuids)< 0){
#     existing_uuids <- c()
#   } else {
#     existing_uuids <- existing_uuids$instance_id
#   }
#   # Get data
#   data <- odk_get_data(
#     url = url,
#     id = id,
#     id2 = id2,
#     unknown_id2 = FALSE,
#     uuids = NULL,
#     exclude_uuids = existing_uuids,
#     user = user,
#     password = password,
#     pre_auth = TRUE,
#     use_data_id = TRUE
#   )
#   new_data <- FALSE
#   if(!is.null(data)){
#     new_data <- TRUE
#   }
#   if(new_data){
#     # Format data
#     formatted_data <- format_minicensus(data = data)
#     # Update data
#     update_minicensus(formatted_data = formatted_data,
#                       con = con)
#   }
# } else {
#   message('...skipping')
# }



####### SECOND DEPRECATED MOZAMBIQUE MINICENSUS
message('PULLING DEPRECATED MINICENSUS (SMALLCENSUS) (MOZAMBIQUE')
if(!skip_deprecated){
  url <- creds$moz_odk_server
  user = creds$moz_odk_user
  password = creds$moz_odk_pass
  id = 'smallcensus'
  suppressWarnings({
    existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
  })
  if (nrow(existing_uuids)< 0){
    existing_uuids <- c()
  } else {
    existing_uuids <- existing_uuids$instance_id
  }
  # Get data
  data <- odk_get_data(
    url = url,
    id = id,
    id2 = id2,
    unknown_id2 = FALSE,
    uuids = NULL,
    exclude_uuids = existing_uuids,
    user = user,
    password = password,
    pre_auth = TRUE,
    use_data_id = FALSE
  )
  new_data <- FALSE
  if(!is.null(data)){
    new_data <- TRUE
  }
  if(new_data){
    # Format data
    formatted_data <- format_minicensus(data = data, keyfile = keyfile_path)
    # Update data
    update_minicensus(formatted_data = formatted_data,
                      con = con)
  }
}

############# SMALLCENSUSA MOZAMBIQUE
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'smallcensusa'
suppressWarnings({
  existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
})
if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
}
# Get data
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = existing_uuids,
  user = user,
  password = password,
  pre_auth = TRUE,
  use_data_id = FALSE
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
}
if(new_data){
  # Format data
  formatted_data <- format_minicensus(data = data, keyfile = keyfile_path)
  # Update data
  update_minicensus(formatted_data = formatted_data,
                    con = con)
}


############### MOZAMBIQUE VA
message('PULLING MOZAMBIQUE VA')
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'va153'
suppressWarnings({
  existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM va')
})
if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
}
# Get data
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = existing_uuids,
  user = user,
  password = password,
  pre_auth = TRUE,
  use_data_id = FALSE
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
}
if(new_data){
  # Format data
  formatted_data <- format_va(data = data, keyfile = keyfile_path)
  # Update data
  update_va(formatted_data = formatted_data,
                    con = con)
}

# ENUMERATIONS MOZAMBIQUE######################################################################
message('PULLING ENUMERATIONS (MOZAMBIQUE')
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'enumerations'
suppressWarnings({
  existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM enumerations')
})
if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
} 
# Get data
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = existing_uuids,
  user = user,
  password = password
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
  # message('---', nrow(data$non_repeats), ' new data points.')
}
if(new_data){
  # Format data
  formatted_data <- format_enumerations(data = data, keyfile = keyfile_path)
  # Update data
  update_enumerations(formatted_data = formatted_data,
                      con = con)
}

# REFUSALS MOZAMBIQUE######################################################################
message('PULLING REFUSALS (MOZAMBIQUE)')
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'refusals'
suppressWarnings({
  existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM refusals')
})
if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
} 
# Get data
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = existing_uuids,
  user = user,
  password = password, 
  pre_auth = TRUE
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
  message('---', nrow(data$non_repeats), ' new data points.')
}
if(new_data){
  # Format data
  formatted_data <- format_refusals(data = data)
  # Update data
  update_refusals(formatted_data = formatted_data,
                  con = con)
}


## TRACCAR LOCATIONS ##############################################

# get traccar data - one row per ID 
message('Syncing traccar workers')
sync_workers_traccar(credentials = creds)
# 
message('Retrieving information on workers from traccar')
dat <- get_traccar_data(url = creds$traccar_server,
                        user = creds$traccar_user,
                        pass = creds$traccar_pass)
# 

# Get existing max date
max_date <- dbGetQuery(con, 'SELECT max(devicetime) FROM traccar')
# fetch data only from one week prior to max date
fetch_date <- max_date$max - lubridate::days(7)
fetch_date <- as.character(as.Date(fetch_date))
if(is.na(fetch_date)){
  fetch_date <- '2020-01-01'
}
fetch_path <- paste0("api/positions?from=", fetch_date, "T22%3A00%3A00Z&to=2022-12-31T22%3A00%3A00Z")

message('Retrieving information on positions from traccar (takes a while)')
library(dplyr)
position_list <- list()
for(i in 1:nrow(dat)){
  message(i, ' of ', nrow(dat))
  this_id <- dat$id[i]
  unique_id <- dat$uniqueId[i]
  # message(i, '. ', this_id)
  suppressWarnings({
    suppressMessages({
      this_position <- bohemia::get_positions_from_device_id(url = creds$traccar_server,
                                                             user = creds$traccar_user,
                                                             pass = creds$traccar_pass,
                                                             device_id = this_id,
                                                             path = fetch_path) %>%
        mutate(unique_id = unique_id) %>%
        mutate(accuracy = as.numeric(accuracy),
               altitude = as.numeric(altitude),
               course = as.numeric(course),
               deviceId = as.numeric(deviceId),
               deviceTime = lubridate::as_datetime(deviceTime),
               fixTime = lubridate::as_datetime(fixTime),
               latitude = as.numeric(latitude),
               longitude = as.numeric(longitude),
               id = as.numeric(id))
    })
  })


  if(!is.null(this_position)){
    if(nrow(this_position) > 0){
      position_list[[i]] <- this_position
    }
  }
}
message('Finished retrieving positions. Combining...')
positions <- bind_rows(position_list)
message('Finished combining. Adding to database...')
names(positions) <- tolower(names(positions))
positions <- positions %>%
  dplyr::select(
    accuracy,
    altitude,
    course,
    deviceid,
    devicetime,
    id,
    latitude,
    longitude,
    valid ,
    unique_id)
message('...', nrow(positions), ' positions retrieved from traccar server.')

# Get existing ids
existing_ids <- dbGetQuery(con, 'SELECT id FROM traccar')

# Subset to remove those which are in existing ids
if(nrow(existing_ids) > 0){
  existing_ids <- existing_ids$id
  message('...', length(existing_ids), ' positions already in database.')
  positions <- positions %>%
    filter(!id %in% existing_ids)
    message('...filtered. going to add ', nrow(positions), ' new positions to database.')

}
message('...going to add ', nrow(positions), ' positions to traccar table')
# Update the database
dbAppendTable(conn = con,
              name = 'traccar',
              value = positions)
message('...done adding positions to traccar table.')


# #Execute cleaning code
# create_clean_db(credentials_file = '../credentials/credentials.yaml')
message('--- NOW EXECUTING CLEANING CODE ---')
source('clean_database.R')


####### ANOMALIES CREATION ##################################################
library(dplyr)
data_moz <- load_odk_data(the_country = 'Mozambique', 
                      credentials_path = '../credentials/credentials.yaml',
                      users_path = '../credentials/users.yaml',
                      local = is_local)
data_tza <- load_odk_data(the_country = 'Tanzania', 
                          credentials_path = '../credentials/credentials.yaml',
                          users_path = '../credentials/users.yaml',
                          local = is_local)
# Run anomaly detection
anomalies_moz <- identify_anomalies_and_errors(data = data_moz,
                                           anomalies_registry = bohemia::anomaly_and_error_registry,
                                           locs = bohemia::locations)
anomalies_tza <- identify_anomalies_and_errors(data = data_tza,
                                               anomalies_registry = bohemia::anomaly_and_error_registry,
                                               locs = bohemia::locations)
anomalies <- bind_rows(
  anomalies_moz %>% mutate(country = 'Mozambique'),
  anomalies_tza %>% mutate(country = 'Tanzania')
)
anomalies$date <- as.Date(anomalies$date)
# Drop old anomalies and add these ones to the database
# dbSendQuery(conn = con,
#             statement = 'DELETE FROM anomalies;')
# dbSendQuery(conn = con,
#             statement = 'DROP FROM anomalies CASCADE;')
anomalies <- anomalies %>% filter(!duplicated(id)) # need to check on this!
dbWriteTable(conn = con,
             name = 'anomalies',
             value = anomalies,
             append = TRUE)
x = dbDisconnect(con)


end_time <- Sys.time()
message('Done at : ', as.character(Sys.time()))
time_diff <- end_time - start_time
message('That took ', as.character(round(as.numeric(time_diff), 2)), ' ', attr(time_diff, 'units'))


