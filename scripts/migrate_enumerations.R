# https://trello.com/c/8Zqfd5Ke/1877-bohemia-enumerations-write-script-o-migrate-forms-from-database-to-odk-server

# The purpose of this script is to retrieve "enumerations" data entries
# from the databrew database, format into ODK records, and migrate them to the 
# CISM ODK server.
# This is necessary because Manhica uploaded some enumerations forms to the databrew
# server, these were then transferred to the databrew database, and then deleted from the server

# Connect to databrew database
creds_fpath <- '../credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
suppressMessages({
  require('RPostgreSQL')
  library(bohemia)
  library(yaml)
  library(dplyr)
  library(xml2)
}
)
psql_end_point = creds$endpoint
psql_user = creds$psql_master_username
psql_pass = creds$psql_master_password
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                 port=5432,
                 user=psql_user, password=psql_pass)

# REad in enumerations
enumerations <- dbReadTable(conn = con,
                            'enumerations')


# Define briefcase storage location
briefcase_folder <- '/home/joebrew/Desktop/ODK Briefcase Storage/'

# Define which instance_ids already exist in briefcase folder (and therefore do not need to be converted)
already_exist <- dir(paste0(briefcase_folder, 'forms/Enumerations/instances'))
already_exist <- gsub('uuid', '', already_exist)

# Keep only those which do not already exist
keep <- enumerations %>% filter(!instance_id %in% already_exist)

for(i in 1:nrow(keep)){
  df <- keep[i,]
  # Define the format for the xml files
  the_format <- paste0('<enumerations id="enumerations" instanceID="uuid:', df$instance_id, '" version="2020100503" submissionDate="2020-10-01T01:01:01.001Z" isComplete="true" markedAsCompleteDate="2020-10-01T01:01:01.001Z" xmlns="http://opendatakit.org/submissions"><group_inquiry><device_id>', df$device_id, '</device_id><start_time>', paste0(gsub(' ', 'T', as.character(df$start_time)), '.001+02:00'), '</start_time><end_time>', paste0(gsub(' ', 'T', as.character(df$end_time)), '.001+02:00'), '</end_time><todays_date>', as.character(df$todays_date), '</todays_date><have_wid>', df$have_wid, '</have_wid><wid_manual>', df$wid_manual, '</wid_manual><wid_qr /><wid>', df$wid, '</wid><inquiry_date>', df$inquiry_date, '</inquiry_date></group_inquiry><group_location><agregado>', df$agregado, '</agregado><localizacao_agregado>', df$localizacao_agregado, '</localizacao_agregado><localizacao_agregado_free /><Country>', df$country, '</Country><Region>', df$region, '</Region><District>', df$district, '</District><Ward>', df$ward, '</Ward><Village>', df$village, '</Village><village_other /><Hamlet>', df$hamlet, '</Hamlet><hamlet_other /><other_location>AAA</other_location><hamlet_code_list>', df$hamlet_code, '</hamlet_code_list><hamlet_code_not_list /><hamlet_code>', df$hamlet_code, '</hamlet_code></group_location><group_construction><construction_type>', df$construction_type, '</construction_type><construction_material>', df$construction_material, '</construction_material><construction_material_free /><wall_material>', df$wall_material, '</wall_material><wall_material_free /><n_total_constructions>', df$n_total_constructions, '</n_total_constructions><location_gps>', df$location_gps, '</location_gps><n_residents>', df$n_residents, '</n_residents><n_deaths_past_year>', df$n_deaths_past_year, '</n_deaths_past_year><vizinho1>', df$vizinho1, '</vizinho1><vizinho2>', ifelse(is.na(df$vizinho2), '', df$vizinho2), '</vizinho2></group_construction><group_chefe><chefe_name>', df$chefe_name, '</chefe_name><sub_name>', df$sub_name, '</sub_name></group_chefe><n0:meta xmlns:n0="http://openrosa.org/xforms"><n0:instanceID>uuid:', df$instance_id, '</n0:instanceID><n0:instanceName>enumerations_', df$hamlet_code, '-', 'migrated', as.numeric(Sys.time()), '</n0:instanceName></n0:meta></enumerations>')
  # Define the path
  new_folder <- paste0(briefcase_folder, 'forms/Enumerations/instances/uuid', df$instance_id)
  # new_folder <- paste0('~/Desktop/instances/', df$instance_id)
  if(!dir.exists(new_folder)){
    dir.create(new_folder)
  }
  # Write the data
  fileConn<-file(paste0(new_folder, '/submission.xml'))
  writeLines(c(the_format), fileConn)
  close(fileConn)
}




dbDisconnect(con)
