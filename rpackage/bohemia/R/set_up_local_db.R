#' Set up local DB
#' 
#' Set up local database (ie, copy remote)
#' @param credentials_path The path to the credentials.yaml file 
#' @import yaml
#' @import dplyr
#' @import DBI
#' @import RPostgres
#' @export

set_up_local_db <- function(credentials_path = 'credentials/credentials.yaml',
                            file = '~/Desktop/bohemia.sql'){
  
  # setwd('../dev/')
  # library(yaml); library(dplyr); library(DBI); library(RPostgres)
  # credentials_path = 'credentials/credentials.yaml'
  creds <- yaml::yaml.load_file(credentials_path)
  psql_end_point = creds$endpoint
  psql_user = creds$psql_master_username
  psql_pass = creds$psql_master_password
  
  out <- paste0(
    "pg_dump --dbname=postgresql://postgres:",
    psql_pass,
    "@",
    psql_end_point,
    ":5432/bohemia > ", file)
  
  message('You will be setting up a local database in 3 steps...\n')
  message('Step 1: Download the database locally by running the following:\n')
  message(out)
  message('\n\n')
  message('Step 2: In a separate terminal, open a psql session by running: psql\n\n')
  message('Step 3: In that psql session, create the bohemia database locally:\n\n')
  message('DROP DATABASE IF EXISTS bohemia; CREATE DATABASE bohemia;')
  message('Step 4: Dump the data into your local database by running the following in regular terminal (not psql session):\n\n')
  message(paste0('psql -d bohemia -f ', file))
  
}