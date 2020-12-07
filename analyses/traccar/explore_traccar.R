library(bohemia)
library(tidyverse)
library(RPostgres)
library(RColorBrewer)
library(bohemia)
library(leafgl)
library(htmltools)
library(sf)
library(yaml)
library(leaflet)
library(readr)

# read in credenstials 
creds <- yaml::yaml.load_file('../../credentials/credentials.yaml')

psql_end_point = creds$endpoint
psql_user = creds$psql_master_username
psql_pass = creds$psql_master_password
drv <- RPostgres::Postgres()
con <- dbConnect(drv, dbname='bohemia', host=psql_end_point, 
                 port=5432,
                 user=psql_user, password=psql_pass)
traccar <- dbReadTable(conn = con, name = 'traccar')
dbDisconnect(con)

source('../../rpackage/bohemia/R/app_functions.R')

# Define a default fieldworkers data
if(!'fids.csv' %in% dir('/tmp')){
  fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=0'
  fids1 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor) %>% dplyr::mutate(country = 'Tanzania')
  fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=490144130'
  fids2 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor) %>% dplyr::mutate(country = 'Mozambique')
  fids_url <- 'https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=179257508'
  fids3 <- gsheet::gsheet2tbl(fids_url) %>% dplyr::select(bohemia_id, first_name, last_name, supervisor) %>% dplyr::mutate(country = 'Catalonia')
  fids <- bind_rows(fids1, fids2, fids3)
  readr::write_csv(fids, '/tmp/fids.csv')
} else {
  fids <- readr::read_csv('/tmp/fids.csv')
}

# mozambique
moz_forms <- load_odk_data(the_country = 'Mozambique',
                           credentials_path = '../../credentials/credentials.yaml',
                           users_path = '../../credentials/users.yaml',
                           local = TRUE, 
                           efficient=TRUE,
                           use_cached = FALSE)

tz_forms <- load_odk_data(the_country = 'Tanzania',
                          credentials_path = '../../credentials/credentials.yaml',
                          users_path = '../../credentials/users.yaml',
                          local = TRUE, 
                          efficient=TRUE,
                          use_cached = FALSE)

# get minicensus
moz_census <- moz_forms$minicensus_main
moz_enum <- moz_forms$enumerations
moz_va <- moz_forms$va

# get tza forms
tz_census <- tz_forms$minicensus_main
tz_va <- tz_forms$va

# get traccar data
traccar <- separate(data = traccar, col = 'valid', into = c('battery', 'distance', 'total_distance', 'motion'), sep = ' ')
traccar$battery <- as.numeric(unlist(lapply(strsplit(traccar$battery, ':'), function(x) x[2])))
traccar$distance <- as.numeric(unlist(lapply(strsplit(traccar$distance, ':'), function(x) x[2])))
traccar$total_distance <- as.numeric(unlist(lapply(strsplit(traccar$total_distance, ':'), function(x) x[2])))
traccar$motion <- as.character(unlist(lapply(strsplit(traccar$motion, ':'), function(x) x[2])))

traccar_moz <- traccar %>% filter(unique_id %in% fids$bohemia_id[fids$country == 'Mozambique'])
traccar_tz <- traccar %>% filter(unique_id %in% fids$bohemia_id[fids$country == 'Tanzania'])

load('temp_data.R')

# get correct time zones for census data
moz_census$end_time <- lubridate::as_datetime(moz_census$end_time, tz = 'Africa/Maputo')
tz_census$end_time <- lubridate::as_datetime(tz_census$end_time, tz = 'Africa/Dar_es_Salaam')
moz_census$start_time <- lubridate::as_datetime(moz_census$start_time, tz = 'Africa/Maputo')
tz_census$start_time <- lubridate::as_datetime(tz_census$start_time, tz = 'Africa/Dar_es_Salaam')

# get correct time zones for enumerations data (Moz only)
moz_enum$end_time <- lubridate::as_datetime(moz_enum$end_time, tz = 'Africa/Maputo')

# get correct time zones for va data
moz_va$end_time <- lubridate::as_datetime(moz_va$end_time, tz = 'Africa/Maputo')
tz_va$end_time <- lubridate::as_datetime(tz_va$end_time, tz = 'Africa/Dar_es_Salaam')

# get time zones for traccar data
traccar_moz$devicetime <- lubridate::as_datetime(traccar_moz$devicetime, tz = 'Africa/Maputo')
traccar_tza$devicetime <- lubridate::as_datetime(traccar_tza$devicetime, tz = 'Africa/Maputo')

#### lots of junk below. put it all into one function, that takes all data (NA for enum if TZ), and layers a plot. If enumeration and/or census not available (because tz or date range selected), then dont add layer. final plot has map with data that's available.

# moving forward - see if people changed devices (device id compared to unique_id)
# function takes into account va, enumerations, and census

# compare_tz function

# two function - subset_forms and subset_traccar (one country at a time)
subset_forms <- function(temp_dat, wid_code, date_slider){
  # subset census by 331
  temp_wid <- temp_dat %>% filter(wid==wid_code) %>%
    filter(end_time>=date_slider[1], end_time <=date_slider[2]) 
  temp_wid$date <- as.Date(temp_wid$end_time)
  # get lat and lon
  ll <- extract_ll(temp_wid$hh_geo_location)
  temp_wid$lat <- ll$lat
  temp_wid$lng <- ll$lng
  rm(ll)
  return(temp_wid)
}

subset_traccar <- function(temp_dat, wid_code, date_slider){
  # other traccar map
  sub_data <- temp_dat %>% filter(unique_id==wid_code) 
  sub_data$devicetime <- lubridate::as_datetime(sub_data$devicetime, tz = 'Africa/Maputo')
  sub_data$date <- as.Date(sub_data$devicetime)
  sub_data <- sub_data %>% 
    filter(date >= date_slider[1],date <= date_slider[2])
  sub_data$time_of_day <- lubridate::round_date(sub_data$devicetime, 'hour')
  sub_data$day <- lubridate::round_date(sub_data$devicetime, 'day')
  
  sub_data$time_of_day <- as.character(sub_data$time_of_day)
  sub_data$day <- as.character(sub_data$day)
  return(sub_data)
  
}

wid_code <- '311'
date_range <-  c("2020-10-09", "2020-10-20")
# subset traccar
sub_traccar <- subset_traccar(temp_dat = traccar_moz, wid_code = wid_code,date_slider =  date_range )

# subset the 3 forms
sub_mini <- subset_forms(temp_dat = moz_census,  wid_code = wid_code,date_slider = date_range)
sub_enum <- subset_forms(temp_dat = moz_enum,  wid_code = wid_code,date_slider = date_range)
sub_va <- subset_forms(temp_dat = moz_va,  wid_code = wid_code,date_slider = date_range)

# get palettes
pal_traccar <- colorFactor(brewer.pal(sort(unique(sub_traccar$date)), name = 'Blues'), domain = unique(sub_traccar$date))

t <- leaflet(sub_traccar) %>% addTiles() %>%
  clearMarkers() %>%
  addCircleMarkers(lng = sub_traccar$longitude, lat = sub_traccar$latitude,
                   color = ~pal_traccar(as.factor(sub_traccar$date)),
                   popup = sub_traccar$devicetime,
                   stroke = FALSE, fillOpacity = 0.5
  ) %>%
  addLegend(pal = pal_traccar, values = ~sub_traccar$date, group = "circles", position = "bottomleft") 

pal_census <- 
  
m <-  leaflet(sub_mini) %>% 
  addTiles() %>%
  clearMarkers() %>%
  addCircleMarkers(lng = sub_mini$lng, lat = sub_mini$lat,
                   color = ~pal_census(as.factor(sub_mini$date)),
                   popup = sub_mini$end_time,
                   stroke = FALSE, fillOpacity = 0.5
  ) %>%
  addLegend(pal = pal, values = ~sub_mini$date, group = "circles", position = "bottomleft") 



pal_census <- colorFactor(brewer.pal(sort(unique(sub_cen$date)), name = 'Blues'), domain = unique(sub_traccar$date))



# function to get longest travelling distance
get_long_travel <- function(temp_dat){
  temp_dat$devicetime <- lubridate::as_datetime(temp_dat$devicetime, tz = 'Africa/Maputo')
  temp_dat$date <- as.Date(temp_dat$devicetime)
  temp <- temp_dat %>% group_by(unique_id, date) %>% summarise(sum_travel = sum(distance, na.rm = TRUE))
  return(temp)
}

top_travels <- get_long_travel(traccar_tz)
# find most prevelant workers
top_workers <- moz_census %>% group_by(wid) %>% summarise(counts = n())  %>% arrange(-counts)

# use worker id
print(top_workers$wid[3])


get_census(temp_dat = moz_census, wid_code = '311', date_slider =c("2020-10-12", "2020-10-14"), color_by = 'date' )

get_traccar(temp_dat = traccar_moz, wid_code = '349', date_slider = c("2020-10-9", "2020-10-9"), color_by = 'time_of_day'  )

