# The purpose of this script is to retrieve "minicensu2" data entries
# from the databrew ODK server, modify formatting slightly, and migrate them to the 
# CISM ODK server.
# This is necessary because Manhica uploaded some enumerations forms to the databrew
# server, these were then transferred to the databrew database, and then deleted from the server

# Connect to databrew database
creds_fpath <- '../../credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
suppressMessages({
  library(RPostgres)
  library(bohemia)
  library(yaml)
  library(dplyr)
  library(xml2)
}
)

# Loop through each form and modify slightly
the_dir <- '~/Desktop/to_migrate/instances/'
# dir.create(out_dir)
files <- dir(the_dir)
for(i in 1:length(files)){
  this_file <- files[i]
  this_xml <- readLines(paste0(the_dir, this_file, '/submission.xml'))
  new_xml <- gsub('minicensus2', 'smallcensus', this_xml)
  new_xml <- gsub('minicensus', 'smallcensus', new_xml)
  new_xml <- gsub('/dob><gender', '/dob><dob_type>exact</dob_type><gender', new_xml, fixed = TRUE)
  # Write the data
  fileConn<-file(paste0(the_dir, this_file, '/submission.xml'))
  writeLines(c(new_xml), fileConn)
  close(fileConn)
}

# # Pull and then move to a separate loc, to_migrate
# to_migrate <- '~/Desktop/to_migrate/'

# # Get the newly formatted data
# url <- creds$databrew_odk_server
# user = creds$databrew_odk_user
# password = creds$databrew_odk_pass
# id <- id2 <- 'smallcensus'
# # Get data
# data <- odk_get_data(
#   url = url,
#   id = id,
#   id2 = id2,
#   unknown_id2 = FALSE,
#   uuids = NULL,
#   exclude_uuids = NULL,
#   user = user,
#   password = password,
#   pre_auth = FALSE,
#   use_data_id = FALSE
# )


# Define briefcase storage location
briefcase_folder <- '/home/joebrew/Desktop/ODK Briefcase Storage/'

# Define which instance_ids already exist in briefcase folder (and therefore do not need to be converted)
already_exist <- dir(paste0(briefcase_folder, 'forms/Enumerations/instances'))
already_exist <- gsub('uuid', '', already_exist)

# Keep only those which do not already exist
keep <- enumerations %>% filter(!instance_id %in% already_exist)
# for(i in 7:11){
for(i in 1:nrow(keep)){
  df <- keep[i,]
  # Define the format for the xml files
  the_format <- paste0('<enumerations id="enumerations" instanceID="uuid:', df$instance_id, '" version="2020100503" submissionDate="2020-10-01T01:01:01.000+02" isComplete="true" markedAsCompleteDate="2020-10-02T01:01:01.000+02" xmlns="http://opendatakit.org/submissions"><group_inquiry><device_id>', df$device_id, '</device_id><start_time>', '2020-01-01T01:01:00.000+02', '</start_time><end_time>', '2020-01-01T01:01:01.000+02', '</end_time><todays_date>', as.character(df$todays_date), '</todays_date><have_wid>', df$have_wid, '</have_wid><wid_manual>', ifelse(is.na(df$wid_manual), ifelse(is.na(df$wid), 000, df$wid), df$wid_manual), '</wid_manual><wid_qr /><wid>', ifelse(is.na(df$wid), 000, df$wid), '</wid><inquiry_date>2020-10-01</inquiry_date></group_inquiry><group_location><agregado>', ifelse(is.na(df$agregado), ' 000', df$agregado), '</agregado><localizacao_agregado>', ifelse(is.na(df$localizacao_agregado), 'none', df$localizacao_agregado), '</localizacao_agregado><localizacao_agregado_free /><Country>', df$country, '</Country><Region>', df$region, '</Region><District>', df$district, '</District><Ward>', df$ward, '</Ward><Village>', ifelse(is.na(df$village), 'other', df$village), '</Village><village_other /><Hamlet>', ifelse(is.na(df$hamlet), 'other', df$hamlet), '</Hamlet><hamlet_other /><other_location>AAA</other_location><hamlet_code_list>', ifelse(is.na(df$hamlet_code), 'XXX', df$hamlet_code), '</hamlet_code_list><hamlet_code_not_list /><hamlet_code>', ifelse(is.na(df$hamlet_code), 'XXX', df$hamlet_code), '</hamlet_code></group_location><group_construction><construction_type>', df$construction_type, '</construction_type><construction_material>', ifelse(is.na(df$construction_material), 'none', df$construction_material), '</construction_material><construction_material_free /><wall_material>', ifelse(is.na(df$wall_material), 'none', df$wall_material), '</wall_material><wall_material_free /><n_total_constructions>', ifelse(is.na(df$n_total_constructions), 0, df$n_total_constructions), '</n_total_constructions><location_gps>', ifelse(is.na(df$location_gps), '', ifelse(grepl('NA', df$location_gps), '0 0 0 0', df$location_gps)), '</location_gps><n_residents>', ifelse(is.na(df$n_residents), 0, df$n_residents), '</n_residents><n_deaths_past_year>', ifelse(is.na(df$n_deaths_past_year), 0, df$n_deaths_past_year), '</n_deaths_past_year><vizinho1>', ifelse(is.na(df$vizinho1), 'none', df$vizinho1), '</vizinho1><vizinho2>', ifelse(is.na(df$vizinho2), 'none', df$vizinho2), '</vizinho2></group_construction><group_chefe><chefe_name>', ifelse(is.na(df$chefe_name), 'none', df$chefe_name), '</chefe_name><sub_name>', ifelse(is.na(df$sub_name), 'none', df$sub_name), '</sub_name></group_chefe><n0:meta xmlns:n0="http://openrosa.org/xforms"><n0:instanceID>uuid:', df$instance_id, '</n0:instanceID><n0:instanceName>enumerations_', ifelse(is.na(df$hamlet_code), 'XXX', df$hamlet_code), '-', 'migrated', round(as.numeric(Sys.time())), '</n0:instanceName></n0:meta></enumerations>')
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
  