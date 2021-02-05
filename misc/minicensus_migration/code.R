library(dplyr)
library(readr)
library(tidyr)

# Define the suitcase directory
suitcase_dir <- '~/Documents/suitcase/'
# Define the designer directory
designer_dir <- '~/Documents/ODK-X_ApplicationDesigner_v2.1.7/'
# Define the Bohemia dir
bohemia_dir <- '~/Documents/bohemia/'
# Define bohemia repo
# Get current directory 
owd <- getwd()
setwd(suitcase_dir)

# Reset the server
the_command <- 
  paste0('java -jar ODK-X_Suitcase_v2.1.7.jar -reset  -cloudEndpointUrl "https://databrew.app" -appId "default" -username "dbrew" -password "admin" -dataVersion 2')
system(the_command)

# Push the new forms
the_command <- 
  paste0('java -jar ODK-X_Suitcase_v2.1.7.jar -cloudEndpointUrl "https://databrew.app" -dataVersion 2 -appId "default" -username "dbrew" -password "admin" -upload -uploadOp RESET_APP -path ', bohemia_dir, 'odkx/app/config')
system(the_command)

# # Push the new forms
# setwd(designer_dir)
# # Delete the app dir
# dir.exists('app')
# unlink('app', recursive = TRUE)
# # Copy over from the git repo

# Define the tables
tables <- 
  c('census',
    'fw_location',
    'hh_death',
    'hh_geo_location',
    'hh_latrine',
    'hh_member',
    'hh_mosquito_net',
    'hh_travel',
    'hh_water_body')


for(i in 1:length(tables)){
  the_table <- tables[i]
  message('Going to retrieve data for...', the_table)
  the_command <- 
    paste0('java -jar ODK-X_Suitcase_v2.1.7.jar -download -a -cloudEndpointUrl "https://databrew.app" -appId "default" -tableId "', the_table, '" -username "data" -password "data" -path "Download"
')
  system(the_command)
}

# Delete everything
delete_everything <- function(){
  for(i in 1:length(tables)){
    the_table <- tables[i]
    this_dir <- paste0('Download/default/', the_table)
    message('Going to delete all data for', the_table)
    file_name <- paste0(the_table, '.csv')
    this_data <- read_csv(paste0(this_dir, '/data_unformatted.csv'))
    if(nrow(this_data) > 0){
      left <- tibble(operation = 'DELETE')
      this_data <- bind_cols(left, this_data) 
      write_csv(this_data,
                file_name)
      the_command <- 
        paste0('java -jar ODK-X_Suitcase_v2.1.7.jar -update -dataVersion 2 -cloudEndpointUrl "https://databrew.app" -appId "default" -tableId "', the_table, '" -username "data" -password "data" -path ', file_name)
      system(the_command)
      file.remove(file_name)
    } else {
      message('...Skipping.')
    }
  }
}
delete_everything()

# having retrieved data, let's use that as the base code with which to modify stuff
forms_dir <- paste0(suitcase_dir, 'Download/default/')
forms_list <- dir(forms_dir)

# Main census form
this_form <- 'census'
this_dir <- paste0(forms_dir, this_form)
this_data <- read_csv(paste0(this_dir, '/data_unformatted.csv'))
format_data_census <- this_data <- this_data[nrow(this_data),]

# HH member form
this_form <- 'hh_member'
this_dir <- paste0(forms_dir, this_form)
this_data <- read_csv(paste0(this_dir, '/data_unformatted.csv'))
format_data_hh_member <- this_data <- this_data[nrow(this_data),]

# geolocation
this_form <- 'hh_geo_location'
this_dir <- paste0(forms_dir, this_form)
this_data <- read_csv(paste0(this_dir, '/data_unformatted.csv'))
format_data_hh_geo_location <- this_data <- this_data[nrow(this_data),]

# Define a function for making fake data
make_fake <- function(format_data_census,
                      format_data_hh_member,
                      format_data_hh_geo_location,
                      hh_number = NULL,
                      n_people = NULL){
  
  if(is.null(hh_number)){
    hh_number <- paste0(paste0(sample(LETTERS, 3), collapse = ''), '-', paste0(sample(0:9, 3), collapse = ''))
  }
  if(is.null(n_people)){
    n_people <- sample(2:9, 1)
  }
  
  # Define some uids
  uids <- paste0('uuid:', uuid::UUIDgenerate(n = 100))
  id_df <- 
    tibble(key = c('_id', '_data_etag_at_modification', 
                   'hh_consent_who_signed', 'hh_head_new_select',
                   'hh_head_sub_new_select', '_row_etag'),
           value = c(uids[1:3], 
                     uids[3],
                     # paste0('["',
                     #        uids[3],
                     #        '"]'),
                     uids[4:5]))
  
  # Modify the ids of the census form
  census <- format_data_census
  for(j in 1:length(id_df$key)){
    this_key <- id_df$key[j]
    this_value <- id_df$value[j]
    census[,this_key] <- this_value
  }  
  
  # Modify the ids of the hh member form
  hh_member <- 
    tibble(`_id` = uids[6:(6+(n_people-1))],
           `_row_etag` = uids[100:(100-n_people+1)]) %>%
    mutate(`_data_etag_at_modification` = uids[(100-n_people)])
  hh_member$`_id`[1] <- uids[3]
  hh_member$`_id`[2] <- uids[4]
  hh_member$hh_head <- hh_member$`_id`[1]
  
  # Join with the formatter
  right <- format_data_hh_member[,!names(format_data_hh_member) %in% names(hh_member)]
  joined <- bind_cols(hh_member, right)
  hh_member <- joined
  # Get names
  hh_member$surname <- sample(c('Johson', 'Avery', 'Garcia', 'Roure', 'Wood', 'Poe', 'Brew', 'Kimani'),
                              n_people, replace = TRUE)
  hh_member$name <- sample(c('John', 'Lola', 'Jaime', 'Enric', 'Eldo', 'Francesc', 'Jose'), n_people, replace = TRUE)

  # Deal with household id
  census$hh_id <- hh_number
  hh_member$id <- paste0(hh_number, '-', bohemia::add_zero(1:n_people, 3))
  hh_member$hh_id <- hh_number
  
  # Modify the location form
  hh_geo_location <- format_data_hh_geo_location
  hh_geo_location <- hh_geo_location %>%
    mutate(`_id` = uids[50],
           `_data_etag_at_modification` = uids[51],
           `_row_etag` = uids[52]) %>%
    mutate(hh_id = hh_number) %>%
    mutate(hh_geo_location_accuracy = 13.26,	
           hh_geo_location_altitude = 52,	
           hh_geo_location_latitude = jitter(43.65),	
           hh_geo_location_longitude = jitter(-79.394992))
  
  # Add the NEW tag
  left <- tibble(operation = 'NEW')
  census <- bind_cols(left, census)
  hh_member <- bind_cols(left, hh_member)
  hh_geo_location <- bind_cols(left, hh_geo_location)
  
  # Return list
  out <- list(census, hh_member, hh_geo_location)
  names(out) <- c('census', 'hh_member', 'hh_geo_location')
  return(out)
}

# Define function for uploading fake data
upload_fake <- function(fake,
                        suitcase_dir = '~/Documents/suitcase/'){
  
  # Define the suitcase directory
  # Get current directory 
  owd <- getwd()
  setwd(suitcase_dir)
  
  # Write local csvs
  write_csv(fake$census, 'census.csv', na = '')
  write_csv(fake$hh_member, 'hh_member.csv', na = '')
  write_csv(fake$hh_geo_location, 'hh_geo_location.csv', na = '')
  
  for(form in c('census', 'hh_member', 'hh_geo_location')){
    tf <- paste0(form, '.csv')
    # Define text for uploading
    upload_command <- paste0(
      "java -jar 'ODK-X_Suitcase_v2.1.7.jar' -cloudEndpointUrl 'https://databrew.app' -appId 'default' -dataVersion 2 -username 'data' -password 'data' -update -tableId '", form, "' -path '", tf, "'"
    ) 
    system(upload_command)
    file.remove(tf)
  }
  setwd(owd)
}

fake <- make_fake(format_data_census = format_data_census,
                  format_data_hh_member = format_data_hh_member,
                  format_data_hh_geo_location = format_data_hh_geo_location)
upload_fake(fake)

ids <- paste0('ABC-', bohemia::add_zero(1:10, 3))
for(i in 1:length(ids)){
  this_id <- ids[i]
  fake <- make_fake(format_data_census = format_data_census,
                    format_data_hh_member = format_data_hh_member,
                    format_data_hh_geo_location = format_data_hh_geo_location,
                    hh_number = this_id)
  upload_fake(fake)
}

# Define text for uploading
upload_command <- paste0(
  "java -jar 'ODK-X_Suitcase_v2.1.7.jar' -cloudEndpointUrl 'https://databrew.app' -appId 'default' -dataVersion 2 -username 'data' -password 'data' -update -tableId '", this_form, "' -path '", tf, "'"
) 
system(upload_command)

# Now redownload the household data in order to get the instance id of the new household
the_table <- 'census'
the_command <- 
  paste0('java -jar ODK-X_Suitcase_v2.1.7.jar -download -a -cloudEndpointUrl "https://databrew.app" -appId "default" -tableId "', the_table, '" -username "data" -password "data" -path "Download"
')
system(the_command)
this_data <- read_csv(paste0(this_dir, '/data_unformatted.csv'))
this_data <- this_data %>% filter(hh_id == the_new_id)
