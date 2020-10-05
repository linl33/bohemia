library(bohemia)
library(yaml)
creds <- yaml::yaml.load_file('../credentials/credentials.yaml')
url <- 'https://bohemia.systems'
id = 'minicensus'
id2 = NULL
user = creds$databrew_odk_user
password = creds$databrew_odk_pass
psql_end_point = creds$endpoint
psql_user = creds$psql_master_username
psql_pass = creds$psql_master_password

require('RPostgreSQL')
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                 port=5432,
                 user=psql_user, password=psql_pass)

# con <- dbConnect(drv, dbname='bohemia', host='localhost', port=5432, user='bohemia_app', password='riscrazy')
dbExistsTable(con, 'va153')

existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM va153')

if (nrow(existing_uuids)< 0){
  existing_uuids <- c()
} else {
  existing_uuids <- existing_uuids$instance_id
} 

# Get data
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

# Format data
formatted_data <- format_minicensus(data = data)

# Update data
update_minicensus(formatted_data = formatted_data,
                  con = con)
dbDisconnect(con)
