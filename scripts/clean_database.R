#!/usr/bin/Rscript
start_time <- Sys.time()
message('------System time is: ', as.character(start_time))
message('------Timezone: ', as.character(Sys.timezone()))
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

# Read in table of corrections instructions
corrections <- dbReadTable(conn = con,
                           name = 'corrections')

# Read in raw data
data <- list()
main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main"))
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
va <- dbGetQuery(con, "SELECT * FROM clean_va")
data$va <- va
# Read in refusals data
refusals <- dbGetQuery(con, "SELECT * FROM clean_refusals")
data$refusals <- refusals

# Read in corrections data
corrections <- dbGetQuery(con, "SELECT * FROM corrections")

# Drop the previously cleaned data
message('------DROPPING OLD CLEAN_ DATA')
create_clean_db(credentials_file = '../credentials/credentials.yaml', 
                drop_all = TRUE)
# Create new clean tables
message('------CREATING NEW CLEAN_ DATA')
create_clean_db(credentials_file = '../credentials/credentials.yaml')

# Process / clean data
# This should line by line SQL statements acting on tables beginning with the "clean_" prefix
# Every entry should have the following components
# - 1. The SQL statement which executes the change (can be more than one). This should ONLY BE ON CLEAN_ tables. It can be no change, if applicable.
# - 2. The SQL statement which logs the execution in the corrections table
# - 3. A Comment explaining exactly what was done


# # Example change
# # This is just an example
# # This part executes the change
# # Anomaly ID: fake_error_type_0017eea6-7239-433d-827a-3bd3d4c65c4e
# dbExecute(conn = con,
#           statement = paste0("UPDATE clean_minicensus_main SET hh_possessions = 'joetest' WHERE instance_id='0017eea6-7239-433d-827a-3bd3d4c65c4e'"))
# # This part modifies the corrections table
# dbExecute(conn = con,
#           statement = paste0("UPDATE corrections SET done = 'true', done_by = 'Joe Brew' WHERE id='fake_error_type_0017eea6-7239-433d-827a-3bd3d4c65c4e'"))

dbDisconnect(con)
