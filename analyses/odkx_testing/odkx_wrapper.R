
library(tidyverse)

# download function
get_odkx_data <- function(server_url, table_id, user, pass, download_path){
  # create sting to pass to system function for running download command
  download_string = paste0('cd ~/Documents/suitcase/; java -jar ODK-X_Suitcase_v2.1.7.jar -download -a -cloudEndpointUrl ', server_url,' -appId default -tableId ', table_id,' -username ', user, ' -password ', pass, ' -path ', download_path)
  system(download_string)

}

# update function - update, new, or delete depends on the "operation" column of the csv.
update_odkx_data <- function(server_url, table_id, user, pass, update_path){
  update_string = paste0('cd ~/Documents/suitcase/; java -jar ODK-X_Suitcase_v2.1.7.jar -a -cloudEndpointUrl ', server_url,' -appId default -dataVersion 2', ' -tableId ', table_id,' -username ', user, ' -password ', pass,' -update -path ', update_path)

  system(update_string)
}

###########
# EXAMPLE 
###########

# First download the census form and store it in a "Download" folder in the suitcase repo (Documents/suitcase)

get_odkx_data(server_url = 'https://databrew.app', table_id = 'census', user = 'dbrew', pass = 'admin', download_path = 'Download')

# read in that csv (because it is already in the format needed)
dat <- read.csv('~/Documents/suitcase/Download/default/census/data_unformatted.csv')

# remove X from meta column names
names(dat) <- gsub('X_', '_', names(dat))

# subset to the first row in case there are more than one. I use only one row for the n replications. 
dat <- dat[1,]

# remove contents of _id and _row_etag column so they will be generated on upload
dat$`_id` <- ''
dat$`_row_etag` <- ''

# add the command "NEW" to the new column "operation"
dat <- cbind(operation = 'NEW', dat)
dat[is.na(dat)] <- ''

# set the number of forms you want 
n= 2

# push n forms to the server, each with a unique hh_id
for(i in 1:n){
  # create n number of random house ids
  hh_letters <- Hmisc::capitalize(sample(letters, 3, replace = TRUE))
  hh_numbers <- sample(0:9, 3, replace=TRUE)
  hh_ids <- c(hh_letters, '-', hh_numbers)
  dat$hh_id <- paste0(hh_ids, collapse = '')
  
  # write the csv to be used in the upload
  write_csv(dat, file = '~/Documents/suitcase/census.csv')
  
  # upload to server
  update_odkx_data(server_url = 'https://databrew.app', table_id='census', user = 'dbrew', pass = 'admin', update_path = 'census.csv')
  
  # write this csv to the suitcase directory
  message('finished ', i,' iteration' )
}

