library(bohemia)
library(yaml)

creds <- read_yaml('../../credentials/credentials.yaml')

fl <- odk_list_forms(url = creds$tza_odk_server,
                     user = creds$tza_odk_user,
                     pass = creds$tza_odk_pass)

for(i in 5){
# for(i in 1:nrow(fl)){
  this_id <- fl$id[i]
  xdf <- odk_get_data(url = creds$tza_odk_server,
                      user = creds$tza_odk_user,
                      pass = creds$tza_odk_pass,
                      id = this_id,
                      id2 = NULL,
                      unknown_id2 = TRUE)
  save(xdf, file = paste0(this_id, '.RData'))
}
