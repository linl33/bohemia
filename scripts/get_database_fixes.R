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

for(i in 1:nrow(corrections)){
  if(grepl('strange_wid_enumeration|missing_wid_enumeration', corrections$id[i])){
    this_id <- corrections$id[i]
    this_instance_id <- corrections$instance_id[i]
    rd <- tolower(corrections$response_details[i])
    rd <- gsub(' ', '', rd)
    this_fid <- as.numeric(gsub('thecorrectidis', '', rd))
    if(!is.na(this_fid)){
      cat(
        paste0("implement(id = '", this_id, "', query = \"UPDATE clean_minicensus_main SET wid='", this_fid, "' WHERE instance_id='", this_instance_id, "'\", who = 'Joe Brew')\n\n")
      )
    } else {
      others <- c(others, i)
    } 
  } else {
    others <- c(others, i)
  }
}

