library(RPostgres)
library(bohemia)
library(yaml)
library(dplyr)

creds_fpath <- '../credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
is_local <- FALSE

# load data from odk for both countries
odk_data <- odk_data_moz <- load_odk_data(credentials_path = '../credentials/credentials.yaml',
                              the_country = 'Mozambique',
                          users_path = '../credentials/users.yaml',
                          local = is_local, efficient = FALSE)
# odk_data_tza <- load_odk_data(credentials_path = '../credentials/credentials.yaml',
#                               the_country = 'Tanzania',
#                               users_path = '../credentials/users.yaml',
#                               local = is_local, efficient = FALSE)


# get corrections and fixes.
corrections <- odk_data$corrections
fixes <- odk_data$fixes 

#get ids from fixes 
fixes_ids <- fixes$id

# keep only response_details, id, and instance_id
corrections <- corrections %>% filter(!id %in% fixes_ids) %>% select(id, instance_id, response_details)
write.csv(corrections, '~/Desktop/temporary_corrections.csv')

minicensus_main <- odk_data$minicensus_main
people <- odk_data$minicensus_people
subs <- odk_data$minicensus_repeat_hh_sub
enumerations <- odk_data$enumerations

# check data associated with a certain instance_id
#temp <- odk_data$minicensus_main[odk_data$minicensus_main$instance_id=='',]
#temp1 <- odk_data$minicensus_people[odk_data$minicensus_people$instance_id=='',]

minicensus_main <- odk_data$minicensus_main
people <- odk_data$minicensus_people
subs <- odk_data$minicensus_repeat_hh_sub

others <- c()


# eldo <- readr::read_csv('~/Desktop/eldo.csv')
# ids <- eldo$`meta:instanceID`
# ids <- gsub('uuid:', '', ids)
# for(i in 1:length(ids)){
#   this_id <- ids[i]
#   out <- paste0(
#     'implement(id=None, query="',
#     "DELETE FROM clean_enumerations WHERE instance_id='",
#     this_id,
#     "'", '"',
#     ", who='Joe Brew') #manual removal at site request; going to re-enumerate\n")
#   cat(out)
# }
# 
# source('../rpackage/bohemia/R/app_functions.R')
# owd <- getwd()
# setwd('..')
# con <- get_db_connection(local = is_local)
# setwd(owd)
# anomalies <- dbGetQuery(conn = con, 'SELECT * FROM anomalies;')
# dbDisconnect(con)
# 
# remove_anomalies <- anomalies %>%
#   filter(instance_id %in% ids)
# for(i in 1:nrow(remove_anomalies)){
#   this_anomaly <- remove_anomalies[i,]
#   this_id <- this_anomaly$instance_id
#   this_aid <- this_anomaly$id
#   this_correction <- corrections %>% filter(id == this_aid)
#   out <- paste0(
#     "DELETE FROM anomalies WHERE instance_id='", this_id, "';\n"
#   )
#   cat(out)
# }


# Also need to remove all anomalies pertaining to these

# for(i in 1:nrow(corrections)){
#   if(grepl('strange_wid_enumeration|missing_wid_enumeration', corrections$id[i])){
#     this_id <- corrections$id[i]
#     this_instance_id <- corrections$instance_id[i]
#     rd <- tolower(corrections$response_details[i])
#     rd <- gsub(' ', '', rd)
#     this_fid <- as.numeric(gsub('thecorrectidis', '', rd))
#     if(!is.na(this_fid)){
#       cat(
#         paste0("implement(id = '", this_id, "', query = \"UPDATE clean_enumerations SET wid='", this_fid, "' WHERE instance_id='", this_instance_id, "'\", who = 'Joe Brew')\n\n")
#       )
#     } else {
#       others <- c(others, i)
#     }
#   } else {
#     others <- c(others, i)
#   }
# }

