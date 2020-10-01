library(bohemia)
library(yaml)
creds <- yaml::yaml.load_file('../credentials/credentials.yaml')
url <- 'https://bohemia.systems'
id = 'minicensus'
id2 = NULL
user = creds$databrew_odk_user
password = creds$databrew_odk_pass

require('RPostgreSQL')
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, dbname='bohemia', host='localhost', port=5432, user='bohemia_app', password='riscrazy')
dbExistsTable(con, 'minicensus_main')

existing_uuids <- dbGetQuery(con, 'SELECT instance_id FROM minicensus_main')
if(nrow(existing_uuids)< 0){ existing_uuids <- c()} else {existing_uuids <- existing_uuids$instance_id} 

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

# You now have a list called "data".
# It has two items in the list:
# 1. non_repeats: this is the main dataset. we should call it minicensus_main or something similar in psql
# 2. repeats: these are the nested datasets. each has its own name. each should get its own table in psql

# Write main table (non repeats)
library(dplyr)
format_minicensus <- function(data){
  
  ## MAIN PART OF MINICENSUS
  df <- data$non_repeats
  df <- df %>% dplyr::rename(instance_id = instanceID)
  # Extract the people columns
  people_columns <- c(paste0('first_name', 1:30),
                      paste0('last_name', 1:30),
                      paste0('pid', 1:30),
                      paste0('name_label', 1:30))
  # Divide between the people part and non people part
  people_part <- df[,people_columns] %>% mutate(instance_id = df$instance_id)
  df <- df[,!names(df) %in% people_columns]
  # Remove all the notes
  df <- df[,!grepl('note_', names(df))]
  df <- df[,!names(df) %in% c('animal_house_distance_pigs', 
                              'hh_animals_animal_house_location_pigs',
                              'hh_member_note',
                              'hh_no_paint_problem',
                              'hh_owns_cattle_or_pigs_note',
                              'hh_paint_note',
                              'hh_region_show',
                              'other_decider')]
  # Clean up the people part
  people_list <- list()
  counter <- 0
  for(i in 1:nrow(people_part)){
    for(j in 1:30){
      counter <- counter + 1
      these_columns <- c(paste0('first_name', j),
                         paste0('last_name', j),
                         paste0('pid', j),
                         paste0('name_label', j))
      these_data <- people_part[i,these_columns]
      names(these_data) <- c('first_name', 'last_name', 'pid', 'name_label')
      these_data$num <- j
      these_data$instance_id <- people_part$instance_id[i]
      people_list[[counter]] <- these_data
    }
  }
  people_part <- bind_rows(people_list)
  people_part <- people_part %>% dplyr::filter(!is.na(pid))
  # Clean up some variables
  df <- df %>%
    # Hamlet and village clean-up
    mutate(hh_hamlet = ifelse(!is.na(hh_hamlet_other),
                              hh_hamlet_other,
                              hh_hamlet)) %>%
    mutate(hh_village = ifelse(!is.na(hh_village_other),
                               hh_village_other,
                              hh_village)) %>%
    dplyr::select(-hh_hamlet_code_list,
                  -hh_hamlet_code_not_list,
                  -hh_hamlet_other,
                  -hh_village_other,
                  -hh_other_location) %>%
    # Household ID clean up
    dplyr::select(-hh_id_manual) %>% # we can remove because hh_id just copies it
    # Main building type clean up
    mutate(hh_main_building_type = ifelse(!is.na(hh_main_building_type_other),
                                          hh_main_building_type_other,
                                          hh_main_building_type)) %>%
    dplyr::select(-hh_main_building_type_other) %>%
    # lighting clean up
    mutate(hh_main_energy_source_for_lighting = ifelse(!is.na(hh_main_energy_source_for_lighting_other),
                                                              hh_main_energy_source_for_lighting_other,
                                                              hh_main_energy_source_for_lighting)) %>%
    # wall material clean up
    mutate(hh_main_wall_material = ifelse(!is.na(hh_main_wall_material_free),
                                                 hh_main_wall_material_free,
                                                 hh_main_wall_material)) %>%
    mutate(hh_health_permission = ifelse(!is.na(hh_health_permission_other),
                                         hh_health_permission_other,
                                         hh_health_permission))
  
  # REPEATS
  # death
  repeat_death_info <- data$repeats$repeat_death_info %>%
    dplyr::rename(instance_id = instanceID) %>% dplyr::select(-repeat_name, -repeated_id)
  # hh_sub
  repeat_hh_sub <- data$repeats$repeat_hh_sub %>%
    dplyr::rename(instance_id = instanceID) %>% 
    dplyr::select(-repeat_name, 
                  -repeated_id,
                  -note_hh_head_is_sub)
  # household members (joining to people part) 
  repeat_household_members_enumeration <- data$repeats$repeat_household_members_enumeration %>%
    dplyr::rename(instance_id = instanceID) %>% dplyr::select(-repeat_name, -repeated_id, -hh_member_number_size) %>% filter(!is.na(permid))
  people <- people_part %>% left_join(repeat_household_members_enumeration %>%
                                   dplyr::select(-first_name,
                                                 -last_name) %>%
                                   mutate(pid = permid))
  # mosquito nets
  repeat_mosquito_net <- data$repeats$repeat_mosquito_net %>%
    dplyr::rename(instance_id = instanceID,
                  num = repeat_mosquito_net_count) %>% 
    dplyr::select(-repeat_name, -repeated_id) %>%
    filter(!is.na(num))
  # water 
  repeat_water <- data$repeats$repeat_water %>%
    dplyr::rename(instance_id = instanceID,
                  num = repeat_water_count) %>% 
    dplyr::select(-repeat_name, -repeated_id) %>%
    dplyr::filter(!is.na(num))
  
  # Return the formatted data
  out <- list(df, people,
              repeat_death_info, repeat_hh_sub, repeat_mosquito_net,
              repeat_water)
  names(out) <- c('main', 'people', 'repeat_death_info', 'repeat_hh_sub', 'repeat_mosquito_net',
                  'repeat_water')
  return(out)
}

formatted_minicensus <- format_minicensus(data = data)

for(i in 1:length(formatted_minicensus)){
  message(i)
  this_table <- formatted_minicensus[[i]]
  this_name <- names(formatted_minicensus)[i]
  dbWriteTable(con, this_name, value = this_table, append=TRUE, row.names=FALSE)
  
}
