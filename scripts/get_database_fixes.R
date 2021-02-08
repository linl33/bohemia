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
odk_data_tza <- load_odk_data(credentials_path = '../credentials/credentials.yaml',
                              the_country = 'Tanzania',
                              users_path = '../credentials/users.yaml',
                              local = is_local, efficient = FALSE)

is_local <- FALSE
drv <- RPostgres::Postgres()
if(is_local){
  con <- dbConnect(drv, dbname='bohemia')
} else {
  psql_end_point = creds$endpoint
  psql_user = creds$psql_master_username
  psql_pass = creds$psql_master_password
  con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                   port=5432,
                   user=psql_user, password=psql_pass)
}

# get corrections and fixes.
corrections <- odk_data_moz$corrections %>% bind_rows(odk_data_tza$corrections)
# Remove duplicates
corrections <- corrections %>% dplyr::distinct(id, instance_id, response_details, .keep_all = TRUE)
# # Overwrite corrections without duplicates (optional)
# dbWriteTable(conn = con, name = 'corrections', value = corrections, overwrite = TRUE)

fixes <- odk_data_moz$fixes %>% bind_rows(odk_data_tza$fixes)


anomalies <- dbGetQuery(conn = con, 'SELECT * FROM anomalies;')

va <- dbGetQuery(conn = con, 'SELECT * FROM va;')
x <- va %>% filter(hh_id == 'ZVA-018')


# x = dbDisconnect(con)

#get ids from fixes 
fixes_ids <- fixes$id

# keep only response_details, id, and instance_id
corrections <- corrections %>% filter(!id %in% fixes_ids) %>% 
  filter(id %in% anomalies$id) %>%
  dplyr::distinct(id, instance_id, response_details)

write.csv(corrections, '~/Desktop/temporary_corrections.csv')

# Write loop to visualize
for(i in 301:nrow(corrections)){
  out <- paste0('# ', i, '. instance_id: ',
                corrections$instance_id[i], '\n# id: ',
                corrections$id[i], '\n# response details: ',
                corrections$response_details[i],
                '\n',
                "implement(id = '",
                corrections$id[i],
                '\', query = "xxxxx where instance_id=\'',
                corrections$instance_id[i],
                '\'", who = "Joe Brew")\n\n')
  cat(out)
}


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

# 
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
# 
# ### Query for enumerations
# # get_query_enum <- function(error_id, inst_id){
# #   temp <- corrections %>% filter(id == error_id)
# #   # get new hh id
# #   new_hh_id <- unique(trimws(unlist(lapply(strsplit(temp$response_details, split = 'to'), function(x) x[length(x)])), which = 'both'))
# #   # UPDATE clean_minicensus_main SET hh_id='DEU-216' WHERE instance_id='8b133ccc-2f0d-439e-ab6d-06bb7b3d16eb'
# #   # get household id query (first part)
# #   hh_query <- paste0("UPDATE clean_enumerations SET hh_id='", new_hh_id, "' WHERE instance_id='", inst_id, "'")
# #   
# #   return(hh_query)
# # }
# 
# # get_query_enum(error_id='repeat_hh_id_4a811abc-ab94-4618-979b-ad14d0fc5ed1,e90e82f9-5bb2-470b-b20a-028bb42b32ce',
#                # inst_id='2046c45c-ed0a-4b1e-a9dd-f2b56adaa3f9')
# 
# get_query(error_id = 'repeat_hh_id_c4b07dc3-fec0-4450-a84d-7947984ce945,e5a29f5c-52da-43f3-ba4e-98c965309b5e',
#           inst_id = 'c4b07dc3-fec0-4450-a84d-7947984ce945')
# 
# x <- odk_data$minicensus_main[odk_data$minicensus_main$instance_id=='252767d7-8601-469b-be57-e334eb9c9f21',]
# xp <- odk_data$minicensus_people[odk_data$minicensus_people$instance_id=='e90e82f9-5bb2-470b-b20a-028bb42b32ce',]


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

