## code to prepare `DATASET` dataset goes here

# Set up geofabrik data
# library(devtools)
library(usethis)
library(raster)
library(rgdal)
library(sp)
library(tidyverse)
library(RColorBrewer)
library(raster)
library(sf)

# # Initiate the raw-data into package session
# usethis::use_data_raw()

# Health facility locations
library(readxl)
rufiji_health_facilities <- read_excel('health_facilities/Health Facilities in Kibiti and Rufiji - Bohemia_iirema_08Dec2019.xlsx') %>%
  dplyr::rename(name = `Facility Name`,
                lng = Longitude,
                lat = Latitude,
                facility_number = `Facility Number`) %>%
  mutate(details = paste0(Ownership)) %>%
  mutate(district = 'Rufiji') %>%
  dplyr::select(name, lng, lat, facility_number, details, district)
mopeia_health_facilities <- read_csv('health_facilities/mopeia_health_facilities.csv') %>%
  dplyr::rename(lng = gpc_lng,
                lat = gpc_lat,
                name = health_facility) %>%
  mutate(name = gsub('CENTRO DE SAUDE', '', name)) %>% 
  mutate(name = trimws(name, which = 'both')) %>%
  mutate(name = gsub('DE', '', name)) %>% 
  mutate(name = trimws(name, which = 'both')) %>%
  mutate(district = 'Mopeia') %>%
  mutate(facility_number = NA) %>%
  mutate(details = paste0(`Posto Administrativo`, ', ', Localidade)) %>%
  dplyr::select(name, lng, lat, facility_number, details, district) %>%
  mutate(name = Hmisc::capitalize(tolower(name)))
  
usethis::use_data(tza3, overwrite = TRUE)

# Creating osm files is time-consuming. Only set to TRUE if a change is needed
redo_osm <- FALSE
if(redo_osm){
  # Get shapefiles
  moz3 <- raster::getData(name = 'GADM',
                          country = 'MOZ',
                          level = 3)
  moz2 <- raster::getData(name = 'GADM',
                          country = 'MOZ',
                          level = 2)
  tza3 <- raster::getData(name = 'GADM',
                          country = 'TZA',
                          level = 3)
  tza2 <- raster::getData(name = 'GADM',
                          country = 'TZA',
                          level = 2)
  mop3 <- moz3[moz3@data$NAME_2 == 'Mopeia',]
  mop2 <- moz2[moz2@data$NAME_2 == 'Mopeia',]
  ruf3 <- tza3[tza3@data$NAME_2 == 'Rufiji',]
  ruf2 <- tza2[tza2@data$NAME_2 == 'Rufiji',]
  shps <- list(moz3, tza3)
  
  countries <- c('mozambique', 'tanzania')
  shps <- list(mop2, ruf2)
  places <- c('mopeia', 'rufiji')
  for(cc in 1:length(countries)){
    this_country <- countries[cc]
    setwd(paste0('geofabrik/',this_country, '-latest-free.shp'))
    # Get OSM data
    files <- dir()
    files <- files[grepl('.shp', files, fixed = TRUE)]
    files <- files[!grepl('zip', files)]
    files <- gsub('.shp', '', files, fixed = TRUE)
    files <- files[grepl('roads|water', files)]
    # dir.create('osm/processed_osms')
    this_shp <- shps[[cc]]
    this_shp <- sf::st_as_sf(this_shp)
    for(i in 1:length(files)){
      this_file <- files[i]
      message(i, ' of ', length(files), ': ', this_file)
      
      processed_file <- paste0('osm/processed_osms/',
                               this_file,
                               '.RData')
      try({
        if(!dir.exists('osm')){
          dir.create('osm')
          setwd('osm')
          dir.create('processed_osms')
          setwd('..')  
        }
        
        # x <- readOGR('osm', this_file)
        y <- st_read('.', this_file)
        valid <- sf::st_is_valid(y)
        y <- y[valid,]
        st_crs(y) <- st_crs(this_shp)
        keep <- st_within(y, this_shp)
        k <- !is.na(as.numeric(keep))
        x <- y[k,]
        x <- as_Spatial(x)
        object_name <- paste0(places[cc],
                              '_',
                              gsub('gis_osm_|_free_1', '', this_file))
        assign(object_name,
               x,
               envir = .GlobalEnv)
      })
    }
    setwd('../..')
  }
  save.image('osm_done.RData')
  
  # Save spatial files
  usethis::use_data(mop2, overwrite = TRUE)
  usethis::use_data(mop3, overwrite = TRUE)
  mopeia2 <- mop2; mopeia3 <- mop3
  usethis::use_data(mopeia2, overwrite = TRUE)
  usethis::use_data(mopeia3, overwrite = TRUE)
  usethis::use_data(mopeia_roads, overwrite = TRUE)
  mopeia_water <- mopeia_water_a
  usethis::use_data(mopeia_water, overwrite = TRUE)
  usethis::use_data(mopeia_waterways, overwrite = TRUE)
  usethis::use_data(moz2, overwrite = TRUE)
  usethis::use_data(moz3, overwrite = TRUE)
  mozambique2 <- moz2; mozambique3 <- moz3
  usethis::use_data(mozambique2, overwrite = TRUE)
  usethis::use_data(mozambique3, overwrite = TRUE)
  rufiji2 <- ruf2; rufiji3 <- ruf3
  usethis::use_data(rufiji2, overwrite = TRUE)
  usethis::use_data(rufiji3, overwrite = TRUE)
  usethis::use_data(ruf2, overwrite = TRUE)
  usethis::use_data(ruf3, overwrite = TRUE)
  usethis::use_data(rufiji_roads, overwrite = TRUE)
  rufiji_water <- rufiji_water_a
  usethis::use_data(rufiji_water, overwrite = TRUE)
  usethis::use_data(rufiji_waterways, overwrite = TRUE)
  tanzania2 <- tza2; tanzania3 <- tza3
  usethis::use_data(tanzania2, overwrite = TRUE)
  usethis::use_data(tanzania3, overwrite = TRUE)
  usethis::use_data(tza2, overwrite = TRUE)
  usethis::use_data(tza3, overwrite = TRUE)
}
