#' Load ODK data
#' 
#' Load odk data
#' @param the_country The country to be loaded
#' @param credentials_path The path to the credentials.yaml file 
#' @param users_path The path to the users.yaml file
#' @param the_tables The names of tables to be loaded
#' @import yaml
#' @import dplyr
#' @import DBI
#' @import RPostgres
#' @export

load_odk_data <- function(the_country = 'Mozambique',
                          credentials_path = 'credentials/credentials.yaml',
                          users_path = 'credentials/users.yaml'){
  
  creds <- yaml::yaml.load_file(credentials_path)
  users <- yaml::yaml.load_file(users_path)
  psql_end_point = creds$endpoint
  psql_user = creds$psql_master_username
  psql_pass = creds$psql_master_password
  drv <- RPostgres::Postgres()
  con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                   port=5432,
                   user=psql_user, password=psql_pass)
  # Read in data
  data <- list()
  if(!is.null(the_country)){
    main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main where hh_country='", the_country, "'"))
  } else {
    main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main"))
  }
  data$minicensus_main <- main
  ok_uuids <- paste0("(",paste0("'",main$instance_id,"'", collapse=","),")")
  
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
  # Read in enumerations data
  enumerations <- dbGetQuery(con, "SELECT * FROM clean_enumerations")
  data$enumerations <- enumerations
  
  # # Read in va data
  # va <- dbGetQuery(con, "SELECT * FROM clean_va")
  # data$va <- va
  # 
  # Read in refusals data
  refusals <- dbGetQuery(con, "SELECT * FROM clean_refusals")
  data$refusals <- refusals
  
  # Read in corrections data
  corrections <- dbGetQuery(con, "SELECT * FROM corrections")
  data$corrections <- corrections
  
  dbDisconnect(con)
  
  return(data)
}