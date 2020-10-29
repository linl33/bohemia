#!/usr/bin/Rscript
# start_time <- Sys.time()
# message('------System time is: ', as.character(start_time))
# message('------Timezone: ', as.character(Sys.timezone()))
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

# Drop the previously cleaned data
message('------DROPPING OLD CLEAN_ DATA DEPRECATED')
create_clean_db(credentials_file = '../credentials/credentials.yaml', 
                drop_all = TRUE)
# Create new clean tables
message('------CREATING NEW CLEAN_ DATA')
create_clean_db(credentials_file = '../credentials/credentials.yaml')

# Process / clean data
# This should line by line SQL statements acting on tables beginning with the "clean_" prefix
# Every entry should have the following components
# - 1. The SQL statement(s) which executes the change (can be more than one). This should ONLY BE ON CLEAN_ tables. It can be no change, if applicable.
# - 2. The SQL statement(s) which logs the execution in the corrections table
# - 3. A Comment explaining exactly what was done

# It is probably helpful to examine the corrections table while doing this
library(dplyr)
# Read in table of corrections instructions
corrections <- dbReadTable(conn = con,
                           name = 'corrections')
corrections %>% filter(!done)

# NOTE The first step is manual review of the correction. This means:
#    1. Examine the response_details provided
#    2. Add classification for it i.e. resolution_category
#    3. Add the corrective action label for it i.e. resolution_action
#    4. If the resolution_category and resolution_action match an entry in the preset_correction_steps proceed with step 2
#    5. If they don't exist, then add an entry to the preset_correction_steps and add the query to apply in the correction_steps 

# Step 2: 
# Now that the correction has a preset_correction_steps entry for its resolution_category and resolution_action
# Check if the preset_correction_steps have a corresponding function in R and call it with the required params if it does.
# If no specific function exists:
# Populate the following variables:
    # anomaly_id
    # correction_id
    # user_email
    # preset_correction_steps_id
    # correction_steps_list
    # correction_query_params_list

# Run the correction_steps keeping in line with the example change described below:
#
#   anomaly_id <- fake_error_type_0017eea6-7239-433d-827a-3bd3d4c65c4e
#   correction_id <- 776627ac-1c8c-4fd7-92f0-529a7f2749e8
#   user_email <- 'joe@brew.cc'
#   preset_correction_steps_id <- 5e86ee69-76a4-46a7-bdd1-6a5464d38b70
#   correction_steps_list <- c(
#     "UPDATE %s SET hh_possessions = %s WHERE instance_id= %s", 
#     "UPDATE %s SET done = %s, done_by = %s WHERE id=%s"
#   )
#   correction_query_params_list <- c(
#     c(clean_minicensus_main, 'joetest', '0017eea6-7239-433d-827a-3bd3d4c65c4e' ), 
#     c(corrections, 'true', 'Joe Brew', 'fake_error_type_0017eea6-7239-433d-827a-3bd3d4c65c4e'))
#
#   # This part executes the change
#   for (i in 1:length(correction_steps_list)){
#     statement <- paste0(corrections_steps_list[i], correction_query_param_list[i])
#     dbExecute(conn = con,
#           statement = statement)
#     # This part logs the action in the log table and is standard for all actions therefore this query should not be in the list
#     dbExecute(conn = con,
#           statement = paste0("INSERT INTO anomaly_corrections_log 
#                                 (anomaly_id, correction_id, preset_steps_id, user_id, log_details) VALUES 
#                                 (anomaly_id, correction_id, preset_correction_steps_id, user_email, statement)))
#    }
#######################

# hh_head_too_young_old_ade9172b-3b03-4254-b252-54e92b9a63e4
dbExecute(con,
          statement = paste0("UPDATE clean_minicensus_people SET dob = '2000-01-01' WHERE instance_id = 'ade9172b-3b03-4254-b252-54e92b9a63e4'"))
dbExecute(con,
          statement = paste0("UPDATE clean_minicensus_main SET hh_head_dob = '2000-01-01' WHERE instance_id = 'ade9172b-3b03-4254-b252-54e92b9a63e4'"))
dbExecute(conn = con,
            statement = paste0("UPDATE corrections SET done = 'true', done_by = 'Joe Brew' WHERE id='hh_head_too_young_old_ade9172b-3b03-4254-b252-54e92b9a63e4'"))

########################
# hh_head_too_young_old_425f18cd-e4a0-42e6-b496-8093b69fe69a
dbExecute(con,
          statement = paste0("DELETE FROM clean_minicensus_main WHERE instance_id = '425f18cd-e4a0-42e6-b496-8093b69fe69a'"))

dbExecute(con,
          statement = paste0("UPDATE corrections SET done = 'true', done_by = 'Joe Brew' WHERE id = 'hh_head_too_young_old_425f18cd-e4a0-42e6-b496-8093b69fe69a'"))

dbDisconnect(con)
