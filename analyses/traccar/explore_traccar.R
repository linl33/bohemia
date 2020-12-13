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
                           local = FALSE, 
                           efficient=FALSE,
                           use_cached = FALSE)

tz_forms <- load_odk_data(the_country = 'Tanzania',
                          credentials_path = '../../credentials/credentials.yaml',
                          users_path = '../../credentials/users.yaml',
                          local = FALSE, 
                          efficient=FALSE,
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


# get correct time zones for census data
moz_census$start_time <- lubridate::as_datetime(moz_census$start_time, tz = 'Africa/Maputo')
tz_census$start_time <- lubridate::as_datetime(tz_census$start_time, tz = 'Africa/Dar_es_Salaam')

# get date for census
moz_census$date <- lubridate::date(moz_census$start_time)
tz_census$date <- lubridate::date(tz_census$start_time)

# get correct time zones for enumerations data (Moz only)
moz_enum$start_time <- lubridate::as_datetime(moz_enum$start_time, tz = 'Africa/Maputo')
moz_enum$date <-  lubridate::date(moz_enum$start_time)

# get correct time zones for va data
moz_va$start_time <- lubridate::as_datetime(moz_va$start_time, tz = 'Africa/Maputo')
moz_va$date <- lubridate::date(moz_va$start_time)

tz_va$start_time <- lubridate::as_datetime(tz_va$start_time, tz = 'Africa/Dar_es_Salaam')
tz_va$date <-  lubridate::date(tz_va$start_time)

# get time zones for traccar data
traccar_moz$devicetime <- lubridate::as_datetime(traccar_moz$devicetime, tz = 'Africa/Maputo')
traccar_moz$date <-  lubridate::date(traccar_moz$devicetime)

traccar_tz$devicetime <- lubridate::as_datetime(traccar_tz$devicetime, tz = 'Africa/Dar_es_Salaam')
traccar_tz$date <-  lubridate::date(traccar_tz$devicetime)

# save.image('temp_data.R')
load('temp_data.R')

# take all dates out of functions
# two function - subset_forms and subset_traccar (one country at a time)
subset_forms <- function(temp_dat, wid_code, date_slider, form){
  # subset census by 331
  
  temp_wid <- temp_dat %>% filter(wid==wid_code) %>%
    filter(date>=date_slider[1], date<=date_slider[2]) 
  # get lat and lon
  if(form=='enum'){
    ll <- extract_ll(temp_wid$location_gps)
  } else if (form=='va'){
    ll <- extract_ll(temp_wid$gps_location)
  } else{
    ll <- extract_ll(temp_wid$hh_geo_location)
  }
  temp_wid$lat <- ll$lat
  temp_wid$lng <- ll$lng
  rm(ll)
  return(temp_wid)
}

subset_traccar <- function(temp_dat, wid_code, date_slider){
  # other traccar map
  sub_data <- temp_dat %>% filter(unique_id==wid_code) 
  sub_data <- sub_data %>% 
    filter(as.Date(devicetime) >=date_slider[1], as.Date(devicetime)<= date_slider[2])
  return(sub_data)
  
}
#### lots of junk below. put it all into one function, that takes all data (NA for enum if TZ), and layers a plot. If enumeration and/or census not available (because tz or date range selected), then dont add layer. final plot has map with data that's available.

plot_traccar <- function(trac, mini, enum, va, wid_code,date_range, show_line_only ){
  mini <- try(subset_forms(temp_dat = mini, wid_code = wid_code, date_slider = date_range, form = 'mini'), silent = TRUE)
  enum <- try(subset_forms(temp_dat = enum, wid_code = wid_code, date_slider = date_range, form='enum'),silent = TRUE )
  va <- try(subset_forms(temp_dat = va, wid_code = wid_code, date_slider = date_range, form='va'), silent = TRUE)
  trac <- try(subset_traccar(temp_dat = trac, wid_code = wid_code, date_slider = date_range), silent = TRUE)
  
  if(class(trac)!='try-error'){
    # pts = st_as_sf(data.frame(trac), coords = c("longitude", "latitude"), crs = 4326) %>% points_to_line(group = 'date')
    # # Remove those which are two few
    # # sizes <- unlist(lapply(pts$geometry, length))
    # # pts <- pts[sizes >10,]
    # # pts$date <- as.character(pts$date)
    # # pts <- pts[-15,]
    # # pts$groups <- stplanr::rnet_group(pts)
    # # Make the plot
    # # l <- mapview::mapview()
    # l <- mapview::mapview(pts["date"],
    #                       legend = FALSE,
    #                       layer.name = 'date')
    # t <-l@object
    # get palettes
    pal_traccar <- colorFactor(brewer.pal(sort(unique(trac$devicetime)), name = 'YlOrRd'), domain = unique(trac$devicetime))
    if(show_line_only){
      t <- leaflet(trac) %>% addTiles() %>%
        clearMarkers() %>%
        addPolylines(lng = trac$longitude, lat = trac$latitude, color = 'black',
                     group = ~devicetime, weight = 0.5) #%>%
      # addLegend(pal = pal_traccar, values = ~trac$devicetime, group = "lines", position = "bottomleft") 
      
    } else {
      t <- leaflet(trac) %>% addTiles() %>%
        clearMarkers() %>%
        addCircleMarkers(lng = trac$longitude, lat = trac$latitude,
                         color = ~pal_traccar(as.factor(trac$devicetime)),
                         popup = trac$devicetime,
                         radius=8,
                         stroke = FALSE, fillOpacity = 0.9) #%>%
        #addLegend(pal = pal_traccar, values = ~trac$devicetime, group = "lines", position = "bottomleft") 
    }
    
  } 
  
  if(class(mini)!= 'try-error'){
    pal_traccar <- colorFactor(brewer.pal(sort(unique(mini$start_time)), name = 'Blues'), domain = unique(mini$start_time))
    t <- t %>% addCircleMarkers(lng = mini$lng, lat =mini$lat,
                                color = 'blue',
                                popup = mini$start_time,
                                stroke = FALSE, fillOpacity = 0.5
    ) #%>%
      #addLegend(pal = pal_traccar, values = ~mini$start_time, group = "circles", position = "bottomleft") 
  }
  if(class(enum)!='try-error'){
    # pal_traccar <- colorFactor(brewer.pal(sort(unique(enum$start_time)), name = 'Greens'), domain = unique(enum$start_time))
    t <- t %>% addCircleMarkers(lng = enum$lng, lat =enum$lat,
                                color ='green',
                                popup = enum$start_time,
                                stroke = FALSE, fillOpacity = 0.5
    ) #%>%
      #addLegend(pal = pal_traccar, values = ~enum$start_time, group = "circles", position = "bottomleft") 
  }
  
  if(class(va)!='try-error'){
    pal_traccar <- colorFactor(brewer.pal(sort(unique(va$start_time)), name = 'Purples'), domain = unique(va$start_time))
    t <- t %>% addCircleMarkers(lng = va$lng, lat =va$lat,
                                color = 'purple',
                                popup = va$start_time,
                                stroke = FALSE, fillOpacity = 0.5
    ) #%>%
      #addLegend(pal = pal_traccar, values = ~va$start_time, group = "circles", position = "bottomleft") 
  }
  
  return(t)
}

# function to get longest travelling distance
get_long_travel <- function(temp_dat){
  temp <- temp_dat %>% group_by(unique_id, date) %>% summarise(sum_travel = sum(distance, na.rm = TRUE))
  return(temp)
}

# top_travels <- get_long_travel(traccar_moz)
# top_travels <- top_travels %>% filter(date >='2020-10-02', date<='2020-12-05')
# temp <- top_travels %>% filter(unique_id=='358')

this_wid ='358'
temp <- moz_form_dis %>% filter(wid==this_wid)

# this_wid ='89'
# temp <- tz_form_dis %>% filter(wid==this_wid)
# 
# ggplot(temp, aes(date, km_to_form)) + 
#   geom_bar(stat='identity') +
#   labs(x='', y = 'km traveled to forms submitted') +
#   theme_bohemia()
#   

# MOZ
plot_traccar(trac = traccar_moz, mini = moz_census, enum = moz_enum, va = moz_va, wid_code = this_wid, date_range = c("2020-10-19", "2020-10-19"), show_line_only = FALSE)

# TZ
plot_traccar(trac = traccar_tz, mini = tz_census, enum = tz_enum, va = tz_va, wid_code = this_wid, date_range = c("2020-12-04", "2020-12-04"), show_line_only = TRUE)








#MZ:
#TZ:44, 72, 7, 3, 85, 20, 38, 51, 77,25,27,90, 71


###############################################################################################
# section for getting overall evidence of distance traveled and forms done 

#############
# mozambique
#############

# group by wid and date 
moz_census_group <- moz_census %>% group_by(wid, date) %>% summarise(counts=n())
moz_enum_group <- moz_enum %>% group_by(wid, date) %>% summarise(counts=n())
moz_va_group <- moz_va %>% group_by(wid, date) %>% summarise(counts=n())
moz_forms <- rbind(moz_census_group, moz_enum_group, moz_va_group)
# moz_forms <-moz_forms %>% group_by(wid) %>% summarise(mean_daily_forms = mean(counts, na.rm = TRUE))

# group by unique_id and date and get sum of meters travled 
moz_distance <- traccar_moz %>% group_by(unique_id, date) %>% summarise(sum_travel = sum(distance, na.rm = TRUE)) %>% filter(sum_travel >0) 
# join with moz forms 
moz_form_dis <- inner_join(moz_forms, moz_distance, by=c('wid'='unique_id', 'date'))
moz_form_dis$km <- moz_form_dis$sum_travel/1000
moz_form_dis$km_to_form <- moz_form_dis$km/moz_form_dis$counts
# moz_form_corr <- moz_form_dis %>% group_by(wid) %>% summarise(correlation = cor(counts, sum_travel),
#                                                               km_to_form = (km/counts))
moz_form_dis <- moz_form_dis %>% filter(km_to_form <2000)

# moz_form_dis <- moz_form_dis %>% filter(sum_travel <500000)
# moz_form_dis <- moz_form_dis %>% group_by(wid) %>% summarise(mean_forms = mean(counts), 
                                                              # mean_travel = mean(sum_travel))
options(scipen = '999')

# choose individual case and plot
ggplot(moz_form_dis ,aes(wid,km_to_form)) + geom_bar(stat='identity') +
  labs(x = 'Individual fieldworker days',
       y='km traveled to form ratio') +
  theme_bohemia() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

# plot corelation
ggplot(moz_form_dis %>% filter(wid=='316'), aes(counts, sum_travel)) + geom_point() +
  geom_smooth(method = 'lm', se = FALSE, lty=2) +
  labs(x='Forms submitted', 
       y='Distance Traveled (meters)')



#############
# tanzania
#############
# group by wid and date 
tz_census_group <- tz_census %>% group_by(wid, date) %>% summarise(counts=n())
tz_va_group <- tz_va %>% group_by(wid, date) %>% summarise(counts=n())
tz_forms <- rbind(tz_census_group,  tz_va_group)
# tz_forms <-tz_forms %>% group_by(wid) %>% summarise(mean_daily_forms = mean(counts, na.rm = TRUE))

# group by unique_id and date and get sum of meters travled 
tz_distance <- traccar_tz %>% group_by(unique_id, date) %>% summarise(sum_travel = sum(distance, na.rm = TRUE)) %>% filter(sum_travel >0) 
# join with tz forms 
tz_form_dis <- inner_join(tz_forms, tz_distance, by=c('wid'='unique_id', 'date'))
# tz_form_corr <- tz_form_dis %>% group_by(wid) %>% summarise(correlation = cor(counts, sum_travel))
tz_form_dis$km <- tz_form_dis$sum_travel/1000
tz_form_dis$km_to_form <- tz_form_dis$km/tz_form_dis$counts

# tz_form_dis <- tz_form_dis %>% filter(sum_travel <500000)
# tz_form_dis <- tz_form_dis %>% group_by(wid) %>% summarise(mean_forms = mean(counts), 
# mean_travel = mean(sum_travel))
options(scipen = '999')


# choose individual case and plot
ggplot(tz_form_dis ,aes(wid,km_to_form)) + geom_bar(stat='identity') +
  labs(x = 'Individual fieldworker days',
       y='km traveled to form ratio') +
  theme_bohemia() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

# TZ:44, 72, 7, 3, 85, 20, 38, 51, 77,25,27,90
# plot corelation
ggplot(tz_form_dis %>% filter(wid=='90'), aes(counts, sum_travel)) + geom_point() +
  geom_smooth(method = 'lm', se = FALSE, lty=2) +
  labs(x='Forms submitted', 
       y='Distance Traveled (meters)')

################
# code for intro to slides 
################
library(lubridate)
library(tidyverse)
# average weekly forms by both countries 
moz_census$week <- lubridate::week(ymd(moz_census$date))
tz_census$week <- lubridate::week(ymd(tz_census$date))

# group by week and get counts 
moz_day <- moz_census %>% group_by(wid,date) %>% summarise(counts =n()) %>%
  group_by(wid) %>% summarise(mean_day = mean(counts))
tz_day <- tz_census %>% group_by(wid,date) %>% summarise(counts =n()) %>%
  group_by(wid) %>% summarise(mean_day = mean(counts))

# find days with very few forms submitted
moz_day <- moz_census%>% group_by(wid,date) %>% summarise(counts =n()) %>%
  filter(counts <= 5)
nrow(moz_day)/nrow(moz_census)
tz_day <- tz_census%>% group_by(wid,date) %>% summarise(counts =n()) %>%
  filter(counts <= 5)
nrow(tz_day)/nrow(tz_census)

# avg distance travelled
moz_dis <- traccar_moz %>% group_by(unique_id, date) %>% summarise(sum_dis = sum(distance, na.rm = TRUE))
moz_cen <- moz_census %>% group_by(wid, date) %>% summarise(forms_submitted = n())
moz_dates <- unique(moz_cen$date)
joined_moz <- inner_join(moz_cen, moz_dis, by=c('wid'='unique_id', 'date'))
joined_moz <- joined_moz %>% group_by(wid) %>% summarise(mean_dis = mean(sum_dis,na.rm = TRUE))
mean(joined_moz$mean_dis)

# tz
tz_dis <- traccar_tz %>% group_by(unique_id, date) %>% summarise(sum_dis = sum(distance, na.rm = TRUE))
tz_cen <- tz_census %>% group_by(wid, date) %>% summarise(forms_submitted = n())
tz_dates <- unique(tz_cen$date)
joined_tz <- inner_join(tz_cen, tz_dis, by=c('wid'='unique_id', 'date'))
joined_tz <- joined_tz %>% group_by(wid) %>% summarise(mean_dis = mean(sum_dis,na.rm = TRUE))
mean(joined_tz$mean_dis)

# how many fws have collected at least one form, but have no recent traccar data (december)
moz_fw <- moz_census %>% filter(date>'2020-11-30') %>% group_by(wid) %>% summarise(counts = n())
tz_fw <- tz_census %>% filter(date>'2020-11-30') %>%group_by(wid) %>% summarise(counts = n())

# get recent traccar data
trac_moz_dec <- traccar_moz %>% filter(date>'2020-11-30') %>% group_by(unique_id) %>% summarise(counts =n()) 
trac_tz_dec <- traccar_tz %>% filter(date>'2020-11-30') %>% group_by(unique_id) %>% summarise(counts =n()) 

# how many have submitted a form
length(which(!moz_fw$wid %in% trac_moz_dec$unique_id))
length(which(!tz_fw$wid %in% trac_tz_dec$unique_id))

# make a stacked bar plot
temp <- tibble(`Active FWs in December`= c(84, 74),
       `Using traccar`= c(19, 27),
       `Country`= c('Mozambique', 'Tanzania'))
library(reshape2)
temp <- melt(temp, id.vars = 'Country')
ggplot(temp, aes(Country, value, fill= variable)) + geom_bar(stat='identity', alpha = 0.6) +
  scale_fill_manual(name = '', values = c('darkred', 'darkgreen')) +
  labs(y='# of FWs') +
  theme_bohemia()
