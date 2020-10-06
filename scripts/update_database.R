#!/usr/bin/Rscript
library(bohemia)
library(yaml)
creds_fpath <- '/home/ubuntu/Documents/bohemia/credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
url <- 'https://bohemia.systems'
id = 'minicensus'
id2 = NULL
user = creds$databrew_odk_user
password = creds$databrew_odk_pass
psql_end_point = creds$endpoint
psql_user = creds$psql_master_username
psql_pass = creds$psql_master_password

require('RPostgreSQL')
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                 port=5432,
                 user=psql_user, password=psql_pass)

existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')

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
  formatted_data <- format_minicensus(data = data)
  
  # Update data
  update_minicensus(formatted_data = formatted_data,
                    con = con)
}

dbDisconnect(con)
