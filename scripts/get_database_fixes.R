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

# error_id <- 'repeat_hh_id_0d09707a-51be-4e91-a5e8-5534fb7bd007,7f97b88a-4090-4c81-aab7-b26fa51d5e99,fe970bb0-521c-4a82-b7d7-b8ef282b1bbb'

# get_num <- function(error_id){
#   inst_id <- unlist(lapply(strsplit(error_id, split = ','), function(x) x[length(x)]))
#   num_people <- minicensus_main$hh_member_num[minicensus_main$instance_id == inst_id]
#   return(num_people)
# }
# 

# # create function to get number of people in household 
# get_query <- function(error_id, inst_id){
#   temp <- corrections %>% filter(id == error_id)
#   # get new hh id
#   new_hh_id <- unique(trimws(unlist(lapply(strsplit(temp$response_details, split = 'to'), function(x) x[length(x)])), which = 'both'))
#   # UPDATE clean_minicensus_main SET hh_id='DEU-216' WHERE instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'
#   # get household id query (first part)
#   hh_query <- paste0("UPDATE clean_minicensus_main SET hh_id='", new_hh_id, "' WHERE instance_id='", inst_id, "'")
#   
#   # get people query (second part)
#   old_hh_id <- minicensus_main$hh_id[minicensus_main$instance_id == inst_id]
#   people$hh_id <- substr(people$pid, 1, 7)
#   temp <- people %>% filter(hh_id == old_hh_id & instance_id==inst_id)  %>% select(pid, num)
#   temp$ind_id <- unlist(lapply(strsplit(temp$pid, '-'), function(x) x[length(x)]))
#   temp$new_hh_id <- new_hh_id
#   temp$new_pid <- paste0(temp$new_hh_id, '-', temp$ind_id)
#   result_list <- list()
#   for(i in 1:nrow(temp)){
#     result_list[[i]] <- paste0("UPDATE clean_minicensus_people SET pid = '", temp$new_pid[i],"'",", permid='",temp$new_pid[i],"'", " WHERE num='", temp$num[i],"'", " and instance_id='", inst_id,"'" )
#   }
#   people_query=  paste0(unlist(result_list), collapse = ';')
#   
#   # combine queries separated by ;
#   full_query = paste0(hh_query, ';', people_query )
#   return(full_query)
# }
# 
# get_query(error_id = 'repeat_hh_id_3dd8c322-947c-4552-8adf-1352e675c897,cd082e8c-b3a1-4253-a752-43bb516d0d91', 
#           inst_id = '8d3ed037-7e7d-4efe-a813-17fe0896309d')
# 
# x <- odk_data$minicensus_main[odk_data$minicensus_main$instance_id=='8d3ed037-7e7d-4efe-a813-17fe0896309d',]
# xp <- odk_data$minicensus_people[odk_data$minicensus_people$instance_id=='84975cb5-3fde-42cb-8e16-f03aba8aba0b',]

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

