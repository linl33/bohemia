# use the system function to download and update to odk-x server.
library(tidyverse)

#########
# create a download function that takes arugments: 
# server_url, table_id, user, pass
#########
get_odkx_data <- function(server_url, table_id, user, pass, download_path){
  # create sting to pass to system function for running download command 
  download_string = paste0('cd ~/Documents/suitcase/; java -jar ODK-X_Suitcase_v2.1.7.jar -download -a -cloudEndpointUrl ', server_url,' -appId default -tableId ', table_id,' -username ', user, ' -password ', pass, ' -path ', download_path)
  system(download_string)
  
}


#########
# create a update function that takes arugments: 
# server_url, update_action,table_id, update_csv,user, pass, update_path
#########
update_odkx_data <- function(server_url, table_id, user, pass, update_path){
  update_string = paste0('cd ~/Documents/suitcase/; java -jar ODK-X_Suitcase_v2.1.7.jar -a -cloudEndpointUrl ', server_url,' -appId default -dataVersion 2', ' -tableId ', table_id,' -username ', user, ' -password ', pass,' -update -path ', update_path)
  
  system(update_string)
}


#########
# create a reproducible example by using the download function to get a sample csv. then modify that downloaded csv for updating (add 50k rows of fake data)
##########

# download the census form and store it in a "Download" folder in the suitcase repo (Documents/suitcase)
# works
get_odkx_data(server_url = 'https://databrew.app', table_id = 'hh_geo_location', user = 'dbrew', pass = 'admin', download_path = 'Download')

# read in that csv
dat <- read.csv('~/Documents/suitcase/Download/default/hh_geo_location/data_unformatted.csv')

# subset to the first row only. this is the row we will replicate
dat <- dat[1,]
# remove X from meta column names
names(dat) <- gsub('X_', '_', names(dat))
dat <- dat[rep(row.names(dat), 50000), 1:19]

# remove contents of _id column
dat$`_id` <- ''
dat$`_row_etag` <- ''

# create the operation column as the first one and fill it with the command "NEW"
dat <- cbind(operation = 'NEW', dat)

# write this csv to the suitcase directory
write_csv(dat, file = '~/Documents/suitcase/hh_geo_location.csv')

# upload to server using update_odkx_data
update_odkx_data(server_url = 'https://databrew.app', table_id='hh_geo_location', user = 'dbrew', pass = 'admin', update_path = 'hh_geo_location.csv')

