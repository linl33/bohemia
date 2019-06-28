# Libraries
library(scales)
library(databrew)
library(ggplot2)
library(cism)
library(readxl)
library(tidyr)
library(tidyverse)
library(cism)

# Create acd from 3 datasets, per Eldo's instructions
acda <- read_csv('data/from_eldo/COST_ACD_Core_13-05-2019.csv')
acdb <- read_csv('data/from_eldo/COST_ACD_Childs_13-05-2019.csv')
acdc <- read_csv('data/from_eldo/COST_ACD_nets_13-05-2019.csv')

acd <- 
  left_join(acdb,
            acda,
            by = c('_PARENT_AURI' = '_URI')) %>%
  left_join(acdc,
            by = c('_URI' = '_PARENT_AURI'))

# Read in eldo files
eldo_perm <- read_csv('data/from_eldo/COST_Permids.New&Old_EE.csv')
eldo_census_agg <- read_csv('data/from_eldo/COST_SprayStatus_by_Village_Id_11.04.2019.EE.csv')
eldo_livestock <- read_csv('data/from_eldo/COST_ACD_Core_13-05-2019.csv')
eldo_census_2016 <- read_csv('data/from_eldo/Census_2016.csv')
eldo_census_2017 <- read_csv('data/from_eldo/COST_Censo2017_Core.1.4.2019.csv')
# census <- eldo_census_2016 %>% dplyr::select(gpc_lng,
#                                              gpc_lat,
#                                              locality_Final,
#                                              `village number_final`,
#                                              household_number) %>%
#   dplyr::rename(lng = gpc_lng,
#            lat = gpc_lat,
#            localidade = locality_Final,
#            hhid = household_number,
#            village_number = `village number_final`) %>% mutate(year = 2016) %>%
#   mutate(family_id )
#   bind_rows(eldo_census_2017 %>%
#               dplyr::rename(lng = LOCALITY_GPS_LNG,
#                             lat = LOCALITY_GPS_LAT,
#                             localidade = LOCAL_VILLAGENAME,
#                             village_number = FAMILY_ID) %>%
#               dplyr::select(village_number,
#                             localidade, lng, lat) %>%
#               mutate(village_number = as.numeric(unlist(lapply(strsplit(village_number, '-'), function(x){x[1]})))) %>%
#               mutate(year = 2017))

# Sort out locations of clusters, etc.
locations <- eldo_census_2016 %>%
  group_by(lng = gpc_lng,
           lat = gpc_lat,
           localidade = locality_Final,
           village_number = `village number_final`) %>%
  tally %>%
  dplyr::filter(n == 1) %>%
  dplyr::select(village_number, localidade, lng, lat)

# Try to get locations for each localidade for livestock
avg_locations <- locations %>%
  # mutate()
  group_by(localidade) %>%
  summarise(lng = mean(lng),
            lat = mean(lat))


# # Define function for converting a meta_instance_name from livestock
# to a household id in the census dataset
numeric_convert <- function(x){
  # Minimize
  x <- strsplit(x, '-')
  # Make numeric
  x <- lapply(x, function(z){as.character(as.numeric(z))})
  x <- lapply(x, function(z){paste0(z[1], '-', z[2], '-', z[3], '-', z[4])})
  x <- unlist(x)
  return(x)
}

# Join acd and eldo perm info
acd <-
  left_join(acd %>% 
              mutate(permid = numeric_convert(PERM_ID)), 
            eldo_perm %>% 
              mutate(permid = numeric_convert(new_permid)),
            by = 'permid')


acd <- acd %>%
  dplyr::select(
    permid,
    gender,
    cluster,
    longitude,
    latitude,
    chicken = MAIN_ANIMAL_CHICK,
    animals = MAIN_ANIMALS,
    cattle = MAIN_ANIMAL_CATTLE,
    pigs = MAIN_ANIMAL_PIGS,
    horses = MAIN_ANIMAL_HORSE,
    sheel = MAIN_ANIMAL_SHEEP,
    goats = MAIN_ANIMAL_COATS,
    FAMILY_ID,
    DEMOGRAFIC_DOB,
    HOME_WORK,
    HOME_WORK_TIME,
    HAD_MALARIA,
    INDUSTRY,
    MAIN_MALARIA_CONTROL_UNDERNET_SLEEP) %>%
  filter(!is.na(longitude),
         !is.na(latitude))

# # Make a mopeia incidence dataset
# out_list <- list()
# counter <- 0
# for(i in 1:nrow(eldo_census_2016)){
#   message(i)
#   this_row <- eldo_census_2016[i,]
#   n_children <- this_row$number_of_children
#   if(n_children > 0){
#     counter <- counter + 1
#     new_row <- this_row %>%
#       dplyr::select(lng = gpc_lng,
#                     lat = gpc_lat,
#                     localidade = locality_Final,
#                     village_number = `village number_final`,
#                     hhid = houseno_Final_1) %>%
#       mutate(joiner = 1)
#     left <- tibble(joiner = 1,
#                    dummy = 1:n_children)
#     new_row <- left_join(left, new_row, by = 'joiner')
#     new_row$n <- 1:n_children
#     out_list[[counter]] <- new_row
#   }
# }
# incidence <- bind_rows(out_list) %>% dplyr::select(-joiner, dummy, hhid, n)
# 
# # Join the acd data to incidence
# left <- incidence
# right <- acd %>%
#   group_by(lng = longitude,
#            lat = latitude)

