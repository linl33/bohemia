library(RPostgres)
library(bohemia)
library(yaml)
library(dplyr)

creds_fpath <- '../credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
is_local <- FALSE

# load data from odk for both countries
odk_data <- load_odk_data(credentials_path = '../credentials/credentials.yaml',
                          users_path = '../credentials/users.yaml',
                          local = is_local)

# get corrections and fixes.
corrections <- odk_data$corrections
fixes <- odk_data$fixes 

#get ids from fixes 
fixes_ids <- fixes$id

# keep only response_details, id, and instance_id
corrections <- corrections %>% filter(!id %in% fixes_ids) %>% select(id, instance_id, response_details)
write.csv(corrections, '~/Desktop/temporary_corrections.csv')

# check data associated with a certain instance_id
temp <- odk_data$minicensus_main[odk_data$minicensus_main$instance_id=='877f5c2a-1598-429c-98a1-5791976378e2',]
temp1 <- odk_data$minicensus_people[odk_data$minicensus_people$instance_id=='877f5c2a-1598-429c-98a1-5791976378e2',]
