#' Clean DB
#'
#' Clean the database
#' @param credentials_file Path to a credentials.yaml
#' @return Data will be modified in the database
#' @import dplyr
#' @import RPostgreSQL
#' @import yaml
#' @export

clean_db <- function(credentials_file = 'credentials/credentials.yaml'){
  
  # Connect to the bohemia database
  start_time <- Sys.time()
  creds <- yaml::yaml.load_file(credentials_file)
  drv <- dbDriver('PostgreSQL')
  con <- dbConnect(drv, dbname='bohemia', host=creds$endpoint, 
                   port=5432,
                   user=creds$psql_master_username, password=creds$psql_master_password)
  
  # Read in the corrections_errors tables
  corrections_errors <- dbReadTable(conn = con,
                                     name = 'corrections_errors')
  
  # Loop through each correction and implement
  message('...Beginning cleaning')
  message('...Going to carry out ', nrow(corrections_errors), ' corrections.')
  ok <- FALSE
  if(nrow(corrections_errors) > 0){
    ok <- TRUE
  }
  if(ok){
    for(i in 1:nrow(corrections_errors)){
      dbExecute(conn = con,
                statement = '')
    }
  }
  message('...Done')
  dbDisconnect(con)
}
