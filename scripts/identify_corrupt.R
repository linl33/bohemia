#!/usr/bin/Rscript
start_time <- Sys.time()
message('System time is: ', as.character(start_time))
message('---Timezone: ', as.character(Sys.timezone()))
creds_fpath <- '../credentials/credentials.yaml'
creds <- yaml::yaml.load_file(creds_fpath)
suppressMessages({
  suppressWarnings({
    library(RPostgres)
    library(bohemia)
    library(yaml)
    library(dplyr)
  })
})

id2 = NULL
skip_deprecated <- FALSE


############# SMALLCENSUSb MOZAMBIQUE
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'smallcensusb'

uuids <- odk_list_submissions(
  url = url,
  id = id,
  user = user,
  password = password,
  pre_auth = TRUE
)

# Get those in the briefcase (previously must pull briefcase)
briefcase_directory <- '~/Desktop/ODK Briefcase Storage/forms/bohemia_smallcensus_b/instances/'
briefcase_uuids <- dir(briefcase_directory)
briefcase_uuids <- gsub('uuid', 'uuid:', briefcase_uuids, fixed = TRUE)

# Display the corrupt
corrupt_smallcensus <- uuids[!uuids %in% briefcase_uuids]

############### MOZAMBIQUE VA B
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'va153b'

uuids <- odk_list_submissions(
  url = url,
  id = id,
  user = user,
  password = password,
  pre_auth = TRUE
)

# Get those in the briefcase (previously must pull briefcase)
briefcase_directory <- '~/Desktop/ODK Briefcase Storage/forms/bohemia_va153_b/instances/'
briefcase_uuids <- dir(briefcase_directory)
briefcase_uuids <- gsub('uuid', 'uuid:', briefcase_uuids, fixed = TRUE)
# Display the corrupt
corrupt_va153 <- uuids[!uuids %in% briefcase_uuids]



# ENUMERATIONS MOZAMBIQUE######################################################################
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'enumerationsb'
uuids <- odk_list_submissions(
  url = url,
  id = id,
  user = user,
  password = password,
  pre_auth = TRUE
)

# Get those in the briefcase (previously must pull briefcase)
briefcase_directory <- '~/Desktop/ODK Briefcase Storage/forms/bohemia_enumerations_b/instances/'
briefcase_uuids <- dir(briefcase_directory)
briefcase_uuids <- gsub('uuid', 'uuid:', briefcase_uuids, fixed = TRUE)
# Display the corrupt
corrupt_enumerations <- uuids[!uuids %in% briefcase_uuids]



# REFUSALS MOZAMBIQUE######################################################################
url <- creds$moz_odk_server
user = creds$moz_odk_user
password = creds$moz_odk_pass
id = 'refusalsb'
uuids <- odk_list_submissions(
  url = url,
  id = id,
  user = user,
  password = password,
  pre_auth = TRUE
)

# Get those in the briefcase (previously must pull briefcase)
briefcase_directory <- '~/Desktop/ODK Briefcase Storage/forms/bohemia_refusals_b/instances/'
briefcase_uuids <- dir(briefcase_directory)
briefcase_uuids <- gsub('uuid', 'uuid:', briefcase_uuids, fixed = TRUE)
# Display the corrupt
corrupt_refusals <- uuids[!uuids %in% briefcase_uuids]


corrupt <- tibble(uuid = corrupt_smallcensus)

knitr::kable(corrupt)



end_time <- Sys.time()
message('Done at : ', as.character(Sys.time()))
time_diff <- end_time - start_time
message('That took ', as.character(round(as.numeric(time_diff), 2)), ' ', attr(time_diff, 'units'))


