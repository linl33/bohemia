#!/usr/bin/Rscript
start_time <- Sys.time()
message('System time is: ', as.character(start_time))
message('---Timezone: ', as.character(Sys.timezone()))
creds_fpath <- '../credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
suppressMessages({
  library(RPostgres)
  library(bohemia)
  library(yaml)
}
)
psql_end_point = creds$endpoint
psql_user = creds$psql_master_username
psql_pass = creds$psql_master_password
drv <- RPostgres::Postgres()
con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                 port=5432,
                 user=psql_user, password=psql_pass)
id2 = NULL

# MINICENSUS MOZAMBIQUE #######################################################################
message('PULLING DEPRECATED MINICENSUS (MOZAMBIQUE')
skip_deprecated <- FALSE
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
    formatted_data <- format_minicensus(data = data)
    # Update data
    update_minicensus(formatted_data = formatted_data,
                      con = con)
  }
} else {
  message('...skipping')
}

####### SECOND DEPRECATED MOZAMBIQUE MINICENSUS
message('PULLING DEPRECATED MINICENSUS (SMALLCENSUS) (MOZAMBIQUE')
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
  formatted_data <- format_minicensus(data = data)
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
  formatted_data <- format_va(data = data)
  # Update data
  update_va(formatted_data = formatted_data,
                    con = con)
}



# # SMALL MOZAMBIQUE #######################################################################
# message('PULLING SMALLCENSUS, MOZAMBIQUE')
# skip_deprecated <- FALSE
# if(!skip_deprecated){
#   # url <- creds$moz_odk_server
#   # user = creds$moz_odk_user
#   # password = creds$moz_odk_pass
#   url <- creds$databrew_odk_server
#   user = creds$databrew_odk_user
#   password = creds$databrew_odk_pass
#   id = 'smallcensus'
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
#     pre_auth = FALSE, #TRUE,
#     use_data_id = FALSE#TRUE
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


# # SMALLCENSUSA DATABREW #######################################################################
# message('PULLING SMALLCENSUSA (DATABREW')
# url <- creds$databrew_odk_server
# user = creds$databrew_odk_user
# password = creds$databrew_odk_pass
# id = 'smallcensusa'
# suppressWarnings({
#   existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
# })
# if (nrow(existing_uuids)< 0){
#   existing_uuids <- c()
# } else {
#   existing_uuids <- existing_uuids$instance_id
# }
# # Get data
# data <- odk_get_data(
#   url = url,
#   id = id,
#   id2 = id2,
#   unknown_id2 = FALSE,
#   uuids = NULL,
#   exclude_uuids = existing_uuids,
#   user = user,
#   password = password,
#   pre_auth = FALSE,
#   use_data_id = FALSE
# )
# new_data <- FALSE
# if(!is.null(data)){
#   new_data <- TRUE
# }
# if(new_data){
#   # Format data
#   formatted_data <- format_minicensus(data = data)
#   # Update data
#   update_minicensus(formatted_data = formatted_data,
#                     con = con)
# }


# # MINICENSUS TZA #######################################################################
# message('PULLING MINICENSUS (TANZANIA')
# url <- creds$tza_odk_server
# user = creds$tza_odk_user
# password = creds$tza_odk_pass
# id = 'minicensus'
# suppressWarnings({
#   existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
# })
# if (nrow(existing_uuids)< 0){
#   existing_uuids <- c()
# } else {
#   existing_uuids <- existing_uuids$instance_id
# }
# # Get data
# data <- odk_get_data(
#   url = url,
#   id = id,
#   id2 = id2,
#   unknown_id2 = FALSE,
#   uuids = NULL,
#   exclude_uuids = existing_uuids,
#   user = user, 
#   password = password,
#   pre_auth = FALSE,
#   use_data_id = FALSE
# )
# new_data <- FALSE
# if(!is.null(data)){
#   new_data <- TRUE
# }
# if(new_data){
#   # Format data
#   formatted_data <- format_minicensus(data = data)
#   # Update data
#   update_minicensus(formatted_data = formatted_data,
#                     con = con)
# }


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
  message('---', nrow(data$non_repeats), ' new data points.')
}
if(new_data){
  # Format data
  formatted_data <- format_enumerations(data = data)
  # Update data
  update_enumerations(formatted_data = formatted_data,
                      con = con)
}

# REFUSALS MOZAMBIQUE######################################################################
message('PULLING REFUSALS (MOZAMBIQUE)')
url <- creds$databrew_odk_server
user = creds$databrew_odk_user
password = creds$databrew_odk_pass
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


# VA MOZAMBIQUE######################################################################
message('PULLING VA153 (MOZAMBIQUE)')
url <- creds$databrew_odk_server
user = creds$databrew_odk_user
password = creds$databrew_odk_pass
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
  password = password
)
new_data <- FALSE
if(!is.null(data)){
  new_data <- TRUE
}
if(new_data){
  # Format data
  formatted_data <- format_va(data = data)
  # Update data
  update_va(formatted_data = formatted_data,
            con = con)
}


x = dbDisconnect(con)

# #Execute cleaning code
# create_clean_db(credentials_file = '../credentials/credentials.yaml')
message('--- NOW EXECUTING CLEANING CODE ---')
source('clean_database.R')

end_time <- Sys.time()
message('Done at : ', as.character(Sys.time()))
time_diff <- end_time - start_time
message('That took ', as.character(round(as.numeric(time_diff), 2)), ' ', attr(time_diff, 'units'))


