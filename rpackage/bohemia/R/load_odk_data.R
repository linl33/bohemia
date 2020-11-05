#' Load ODK data
#' 
#' Load odk data
#' @param the_country The country to be loaded
#' @param credentials_path The path to the credentials.yaml file 
#' @param users_path The path to the users.yaml file
#' @param the_tables The names of tables to be loaded
#' @param local Whether to use the local database
#' @import yaml
#' @import dplyr
#' @import DBI
#' @import RPostgres
#' @export

load_odk_data <- function(the_country = 'Mozambique',
                          credentials_path = 'credentials/credentials.yaml',
                          users_path = 'credentials/users.yaml',
                          local = FALSE){
  
  creds <- yaml::yaml.load_file(credentials_path)
  users <- yaml::yaml.load_file(users_path)
  psql_end_point = creds$endpoint
  psql_user = creds$psql_master_username
  psql_pass = creds$psql_master_password
  drv <- RPostgres::Postgres()
  if(local){
    con <- dbConnect(drv, dbname='bohemia')
  } else {
    con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                     port=5432,
                     user=psql_user, password=psql_pass)
  } 
  
  # Define server
  if(the_country == 'Mozambique'){
    server_url <- 'https://sap.manhica.net:4442/ODKAggregate'
  } else {
    server_url <- 'https://bohemia.ihi.or.tz'
  }
  
  # Read in data
  data <- list()
  if(!is.null(the_country)){
    main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main where server='", server_url, "'"))
  } else {
    main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main"))
  }
  data$minicensus_main <- main
  ok_ids <- main$instance_id
  ok <- TRUE
  if(length(ok_ids) == 0){
    ok_ids <- '86ff878c-1f45-11eb-adc1-0242ac120002' # fake
  }
  ok_uuids <- paste0("(",paste0("'",ok_ids,"'", collapse=","),")")
  
  repeat_names <- c("minicensus_people", 
                    "minicensus_repeat_death_info",
                    "minicensus_repeat_hh_sub", 
                    "minicensus_repeat_mosquito_net", 
                    "minicensus_repeat_water")
  for(i in 1:length(repeat_names)){
    this_name <- repeat_names[i]
    this_data <- dbGetQuery(con, paste0("SELECT * FROM clean_", this_name, " WHERE instance_id IN ", ok_uuids))
    data[[this_name]] <- this_data
  }
  # Read in enumerations, va, and refusals data
  if(!is.null(the_country)){
    enumerations <- dbGetQuery(con, paste0("SELECT * FROM clean_enumerations where server='", server_url, "'"))
    va <- dbGetQuery(con, paste0("SELECT * FROM clean_va where server='", server_url, "'"))
    refusals <- dbGetQuery(con, paste0("SELECT * FROM clean_refusals where server='", server_url, "'"))
  } else {
    enumerations <- dbGetQuery(con, "SELECT * FROM clean_enumerations")
    va <- dbGetQuery(con, "SELECT * FROM clean_va")
    refusals <- dbGetQuery(con, "SELECT * FROM clean_refusals")
  }
  
  data$enumerations <- enumerations
  data$va <- va
  data$refusals <- refusals
  
  # Read in corrections data
  corrections <- dbGetQuery(con, "SELECT * FROM corrections")
  data$corrections <- corrections
  
  
  dbDisconnect(con)
  
  return(data)
}