library(bohemia)
library(yaml)
creds <- yaml::yaml.load_file('../credentials/credentials.yaml')
url <- 'https://bohemia.systems'
id = 'minicensus'
id2 = NULL
user = creds$databrew_odk_user
password = creds$databrew_odk_pass

require('RPostgreSQL')
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, dbname='bohemia', host='localhost', port=5432, user='bohem_app', password='riscrazy')
dbExistsTable(con, 'minicensus_main')

existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')

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

# You now have a list called "data".
# It has two items in the list:
# 1. non_repeats: this is the main dataset. we should call it minicensus_main or something similar in psql
# 2. repeats: these are the nested datasets. each has its own name. each should get its own table in psql

# Save the data to the DB
for (i in 1:nrow(data['non_repeats'][[1]])){
  instance_id <- data['non_repeats'][[1]]['instanceID'][[1]][[1]]
  # household_data <- data['non_repeats'][[1]][['rest_of_the_list']]
  insert_data = data.frame(instance_id = instance_id, household_data = household_data)

  dbWriteTable(con, 'minicensus_main', value = insert_data, append=TRUE, row.names=FALSE)

  # Loop through the repeats with the same instanceID and insert them to DB
  # Repeat Death Info
  instance_id <- data['repeats'][[1]]['repeat_death_info'][[1]]['instanceID'][[1]][[1]]
  # insert_data <- data.frame(instance_id = instance_id, data['repeats'][[1]]['repeat_death_info'][[1]]['all_details_except_first_2_columns'])

  dbWriteTable(con, 'minicensus_repeat_death_info', value = insert_data, append=TRUE, row.names=FALSE)

  # Repeat HH Sub
  instance_id <- data['repeats'][[1]]['repeat_hh_sub'][[1]]['instanceID'][[1]][[1]]
  # insert_data <- data.frame(instance_id = instance_id, data['repeats'][[1]]['repeat_hh_sub'][[1]]['all_details_except_first_2_columns'])

  dbWriteTable(con, 'minicensus_repeat_hh_sub', value = insert_data, append=TRUE, row.names=FALSE)

  # Repeat Household Members Enumeration
  instance_id <- data['repeats'][[1]]['repeat_household_members_enumeration'][[1]]['instanceID'][[1]][[1]]
  # insert_data <- data.frame(instance_id = instance_id, data['repeats'][[1]]['repeat_household_members_enumeration'][[1]]['all_details_except_first_2_columns'])

  dbWriteTable(con, 'minicensus_repeat_household_members_enumeration', value = insert_data, append=TRUE, row.names=FALSE)

  # Repeat Mosquito Net
  instance_id <- data['repeats'][[1]]['repeat_mosquito_net'][[1]]['instanceID'][[1]][[1]]
  # insert_data <- data.frame(instance_id = instance_id, data['repeats'][[1]]['repeat_mosquito_net'][[1]]['all_details_except_first_2_columns'])

  dbWriteTable(con, 'minicensus_repeat_mosquito_net', value = insert_data, append=TRUE, row.names=FALSE)

  # Repeat Water
  instance_id <- data['repeats'][[1]]['repeat_water'][[1]]['instanceID'][[1]][[1]]
  # insert_data <- data.frame(instance_id = instance_id, data['repeats'][[1]]['repeat_water'][[1]]['all_details_except_first_2_columns'])

  dbWriteTable(con, 'minicensus_repeat_water', value = insert_data, append=TRUE, row.names=FALSE)
}
