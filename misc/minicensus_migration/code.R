library(dplyr)
library(readr)
library(tidyr)

# Define the suitcase directory
suitcase_dir <- '~/Documents/suitcase/'
# Get current directory 
owd <- getwd()
setwd(suitcase_dir)

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
                file_name, na = '')
      the_command <- 
        paste0('java -jar ODK-X_Suitcase_v2.1.7.jar -download -a -cloudEndpointUrl "https://databrew.app" -appId "default" -tableId "', the_table, '" -username "data" -password "data" -path "Download"
')
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
format_data_census <- this_data <- this_data[1,]

# HH member form
this_form <- 'hh_member'
this_dir <- paste0(forms_dir, this_form)
this_data <- read_csv(paste0(this_dir, '/data_unformatted.csv'))
format_data_hh_member <- this_data <- this_data[1,]

# Define a function for making fake data
make_fake <- function(format_data_census,
                      format_data_hh_member,
                      hh_number = NULL,
                      n_people = NULL){
  
  if(is.null(hh_number)){
    hh_number <- paste0(paste0(sample(LETTERS, 3), collapse = ''), '-', paste0(sample(0:9, 3), collapse = ''))
    
    if(is.null(n_people)){
      n_people <- sample(1:9, 1)
    }
  }
  
  # Define some uids
  uids <- paste0('uuid:', uuid::UUIDgenerate(n = 100))
  id_df <- 
    tibble(key = c('_id', '_data_etag_at_modification', 
                   'hh_consent_who_signed', 'hh_head_new_select',
                   'hh_head_sub_new_select', '_row_etag'),
           value = c(uids[1:3], 
                     paste0('["',
                            uids[3],
                            '"]'),
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
    tibble(`_id` = uids[6:(6+(n-1))],
           `_row_etag` = uids[100:(100-n+1)],
           `_data_etag_at_modification` = uids[(100-n):(100-n-n+1)])
  hh_member$`_id`[1] <- uids[3]
    # Join with the formatter
  right <- format_data_hh_member[,!names(format_data_hh_member) %in% names(hh_member)]
  joined <- bind_cols(hh_member, right)
  hh_member <- joined
  # Get names
  hh_member$surname <- sample(c('Johson', 'Avery', 'Garcia', 'Roure'),
                              n, replace = TRUE)
  hh_member$name <- sample(c('John', 'Lola', 'Jaime', 'Enric', 'Eldo', 'Francesc', 'Jose'), n, replace = TRUE)
  # Get head
  hh_
  
  # Deal with household id
  census$hh_id <- hh_number
  hh_member$id <- paste0(hh_number, '-', bohemia::add_zero(1:n, 3))
  
  # Add the NEW tag
  left <- tibble(operation = 'NEW')
  census <- bind_cols(left, census)
  hh_member <- bind_cols(left, hh_member)
  
  # Return list
  out <- list(census, hh_member)
  names(out) <- c('census', 'hh_member')
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
  
  for(form in c('census', 'hh_member')){
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
                  format_data_hh_member = format_data_hh_member)
upload_fake(fake)


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
