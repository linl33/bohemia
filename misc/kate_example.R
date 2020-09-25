library(bohemia)
library(yaml)
creds <- yaml::yaml.load_file('../credentials/credentials.yaml')
url <- 'https://bohemia.systems'
id = 'minicensus'
id2 = NULL
user = creds$databrew_odk_user
password = creds$databrew_odk_pass
data <- odk_get_data(
  url = url,
  id = id,
  id2 = id2,
  unknown_id2 = FALSE,
  uuids = NULL,
  exclude_uuids = NULL,
  user = user,
  password = password
)

# You now have a list called "data".
# It has two items in the list:
# 1. non_repeats: this is the main dataset. we should call it minicensus_main or something similar in psql
# 2. repeats: these are the nested datasets. each has its own name. each should get its own table in psql