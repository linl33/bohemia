#' Create clean DB
#'
#' Create a clean database as a copy of the ODK "raw" database
#' @param con A connection
#' @param credentials_file Path to a credentials.yaml
#' @param drop_all Whether to, instead of creating clean tables, drop them
#' @return Data will be created in the database
#' @import dplyr
#' @import RPostgres
#' @import yaml
#' @export

create_clean_db <- function(con = NULL,
                            credentials_file = 'credentials/credentials.yaml',
                            drop_all = FALSE){
  
  # Connect to the bohemia database
  start_time <- Sys.time()
  no_original_con <- FALSE
  if(is.null(con)){
    no_original_con <- TRUE
    message('No connection supplied. Going to use the one in ', credentials_file)
    creds <- yaml::yaml.load_file(credentials_file)
    drv <- RPostgres::Postgres()
    con <- dbConnect(drv, dbname='bohemia', host=creds$endpoint, 
                     port=5432,
                     user=creds$psql_master_username, password=creds$psql_master_password)
  } 
  
  
  # Define the tables to copy
  copy_these <- c(
    'enumerations',
    'minicensus_main',
    'minicensus_people',
    'minicensus_repeat_death_info',
    'minicensus_repeat_hh_sub',
    'minicensus_repeat_mosquito_net',
    'minicensus_repeat_water',
    'refusals',
    'va'
  )
  
  # Loop through each table and copy
  for(i in 1:length(copy_these)){
    this_table <- copy_these[i]
    
    tbl_name <- paste0('clean_', this_table)
    
    # See if clean table exists
    tbl_exists <- dbGetQuery(
      conn = con, 
      statement = paste0("select exists (
          select from information_schema.tables where table_schema = 'public' and table_name ='", tbl_name,"'
          )")
    )
    
    if(tbl_exists$exists){
      if(drop_all){
        message('Dropping clean_', this_table)
        dbExecute(conn = con,
                  statement = paste0('drop table clean_', this_table))
      } else {
        message('clean_', this_table, ' already exists. Only adding the new rows not previously copied')
        dbExecute(conn = con,
                  statement = paste0('insert into clean_', this_table, ' select * from ', this_table, 'on conflict do nothing;')
        )
      }
      
    } else {
      if(!drop_all){
        message('Creating clean_', this_table, ' which did not already exist. Creating.')
        
        dbExecute(conn = con,
                  statement = paste0('create table clean_', this_table, ' as select * from ', this_table))
      }
      
    }
  }
  # Only close connection if not originally supplied
  if(no_original_con){
    dbDisconnect(con)
  }
}
