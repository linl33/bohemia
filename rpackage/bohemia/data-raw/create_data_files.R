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

# Previous Mopeia census
# The ID number is correct, the village names, etc. are sometimes wrong
# Need to use the ID to correct the names from COST_SprayStatus_by_Village_Id_18.07.2019.EE.csv
correct <- read_csv('mopeia_census_cost/COST_SprayStatus_by_Village_Id_10.12.2019.EE.csv') %>%
  dplyr::select(id = VILLAGE_ID,
                administrative_post = ADMINISTRATIVE_POST,
                locality = LOCALITY_NAME,
                village = VILLAGE_NAME,
                population = POPULATION) %>%
  mutate(locality = bohemia::update_mopeia_locality_names(locality))


cen1 <- read_csv('mopeia_census_cost/Census_2016_10-12-2019.csv')
cen1 <- cen1 %>% mutate(
  id = `village number_final`,
  # ap = administrative_post_final,
  # locality = locality_Final,
  # village = village_final,
  lng = gpc_lng,
  lat = gpc_lat
) %>% dplyr::select(id, lng, lat)
cen2 <- read_csv('mopeia_census_cost/COST_Censo2017_Core.10.12.2019.csv')
cen2 <- cen2 %>%
  mutate(
    id = unlist(lapply(strsplit(FAMILY_ID, split = '-'), function(x){x[1]})),
    # administrative_post = ADMINISTRATIVE_POST,
    # locality = LOCALITY,
    # village = LOCAL_VILLAGENAME,
    lng = LOCALITY_GPS_LNG,
    lat = LOCALITY_GPS_LAT
  ) %>% dplyr::select(id, 
                      # administrative_post, locality, village, 
                      lng, lat) %>%
  mutate(id = as.numeric(as.character(id)))
# Combine
cen <- bind_rows(cen1, 
                 cen2) %>% 
  left_join(correct) %>%
  mutate(locality = toupper(locality),
         administrative_post = toupper(administrative_post),
         village = toupper(village))

# # For eldo to correct:
# sort(unique(cen$id[!cen$id %in% correct$id]))

# Now use the cen object to create shapefiles
library(rgeos)
library(geosphere)
df <- cen %>% mutate(x = lng, y = lat)
df <- df %>% filter(!is.na(id))
# Make spatial
coordinates(df) <- ~x+y

proj4string(df) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Filter out the suspicious ones
df@data$idx <- 1:nrow(df)
df@data$suspect <- FALSE
# Get unique bairros
bairros <- data_frame(id = sort(unique(df$id)))
# Remove form our household data, those points which 
# are suspiciously far from others
for (i in 1:nrow(bairros)){
  # Get info just for this bairro
  this_bairro <- bairros$id[i]
  sub_df <- df[df@data$id == this_bairro,]
  # Get distances between points in bairro
  distances <- geosphere::distm(sub_df, fun = distVincentySphere)
  # Get the average distance from the house to other houses in the bairro
  avg_distance_to_others <- apply(distances, 1, function(x){mean(x, na.rm = TRUE)})
  
  # Get distance to points OUTSIDE of bairro
  outside <- df[df@data$id != this_bairro,]
  distances_out <- geosphere::distm(x = sub_df,
                                    y = outside,
                                    fun = distVincentySphere)
  # Flag those which are particularly close to other bairros
  min_distances_out <- apply(distances_out, 1,
                             min, na.rm = TRUE)
  flag_out <- min_distances_out < quantile(min_distances_out, 0.25, na.rm = T)
  # Flag those which are particularly far from points in this bairro
  flag_in <- avg_distance_to_others >= quantile(avg_distance_to_others, 0.75, na.rm = TRUE)
  flag <- flag_in | flag_out

  # Flag those which are suspicious
  bad <- sub_df[flag,]
  df$suspect[df$idx %in% bad$idx] <- TRUE
  # plot(sub_df)
  # Sys.sleep(0.5)
  # points(bad, col = 'red')
  # Sys.sleep(1)
}
# Remove those which are suspicious
df <- df[!df@data$suspect,]

# Create convex hulls
ch <- list()
bairros <- sort(unique(cen$id))
for (i in 1:length(bairros)){
  this_bairro <- bairros[i]
  sub_df <- df[which(df@data$id == this_bairro),]
  x <- rgeos::gConvexHull(sub_df)
  ch[[i]] <- x
}
# Create delaunay triangulation / voronoi tiles for entire surface
voronoi <- function(shp = df){
  
  shp@data <- data.frame(shp@data)
  
  # Fix row names
  row.names(shp) <- 1:nrow(shp)
  
  # Remove any identical ones
  shp <- shp[!duplicated(shp$lng,
                         shp$lat),]
  
  # Helper function to create coronoi polygons (tesselation, not delaunay triangles)
  # http://carsonfarmer.com/2009/09/voronoi-polygons-with-r/
  voronoipolygons = function(layer) {
    require(deldir)
    crds = layer@coords
    z = deldir(crds[,1], crds[,2])
    w = tile.list(z)
    polys = vector(mode='list', length=length(w))
    require(sp)
    for (i in seq(along=polys)) {
      pcrds = cbind(w[[i]]$x, w[[i]]$y)
      pcrds = rbind(pcrds, pcrds[1,])
      polys[[i]] = Polygons(list(Polygon(pcrds)), ID=as.character(i))
    }
    SP = SpatialPolygons(polys)
    voronoi = SpatialPolygonsDataFrame(SP, data=data.frame(x=crds[,1], 
                                                           y=crds[,2], row.names=sapply(slot(SP, 'polygons'), 
                                                                                        function(x) slot(x, 'ID'))))
  }
  # http://gis.stackexchange.com/questions/180682/merge-a-list-of-spatial-polygon-objects-in-r
  appendSpatialPolygons <- function(x) {
    ## loop over list of polygons
    for (i in 2:length(x)) {
      # create initial output polygon
      if (i == 2) {
        out <- maptools::spRbind(x[[i-1]], x[[i]])
        # append all following polygons to output polygon  
      } else {
        out <- maptools::spRbind(out, x[[i]])
      }
    }
    return(out)
  }
  
  tile_polys <- voronoipolygons(shp)
  # Add the bairro numbers
  tile_polys@data$id <- the_bairros <- shp$id
  cols <- rainbow(as.numeric(factor(tile_polys@data$id)))
  
  # Disolve borders
  x = gUnaryUnion(tile_polys, id = tile_polys$id)
  
  jdata = SpatialPolygonsDataFrame(Sr=x, 
                                   data=data.frame(id = as.numeric(as.character(names(x)))),FALSE)
  
  return(jdata)
}
# Get voronoi tesselations
df <- df[!is.na(df$lng) & !is.na(df$id),]
dfv <- voronoi(shp = df)

# Narrow down so as to only keep those areas which are IN Mopeia
mop2 <- bohemia::mop2
proj4string(dfv) <- proj4string(mop2)
out <- gIntersection(dfv, mop2, byid=TRUE)

# Join with data
bairros <- left_join(data_frame(id = bairros),
                     correct)
ids <- as.numeric(gsub(' 30', '', names(out)))
bairros <- bairros %>% filter(id %in% ids)
row.names(out) <- as.character(1:length(out))
out <- SpatialPolygonsDataFrame(out, bairros, match.ID = TRUE)

# Save
mopeia_hamlets <- out
usethis::use_data(mopeia_hamlets, overwrite = TRUE)

# cols <- rainbow(nrow(mopeia_hamlets))
# cols <- sample(cols, length(cols))
# cols <- sample(cols, length(cols))
# 
# library(leaflet)
# leaflet() %>%
#   addTiles() %>%
#   addPolygons(data = mopeia_hamlets,
#               color = cols,
#               popup = paste0(mopeia_hamlets$id,
#                              ', Village: ',
#                              mopeia_hamlets$village,
#                              ', Locality:',
#                              mopeia_hamlets$locality),
#               weight = 1)


# Write products
library(rgdal)
# writeOGR(obj=out, 
#          dsn="magude_bairros", 
#          layer = 'magude_bairros',
#          driver="ESRI Shapefile")



####
# Health facility locations
####
library(readxl)
rufiji_health_facilities <- read_excel('health_facilities/Health Facilities in Kibiti and Rufiji - Bohemia_iirema_08Dec2019.xlsx') %>%
  dplyr::rename(name = `Facility Name`,
                lng = Longitude,
                lat = Latitude,
                facility_number = `Facility Number`) %>%
  mutate(details = paste0(Ownership)) %>%
  mutate(district = 'Rufiji') %>%
  dplyr::select(name, lng, lat, facility_number, details, district)
# mopeia_health_facilities <- read_csv('health_facilities/mopeia_health_facilities.csv') %>%
#   dplyr::rename(lng = gpc_lng,
#                 lat = gpc_lat,
#                 name = health_facility) %>%
#   mutate(name = gsub('CENTRO DE SAUDE', '', name)) %>% 
#   mutate(name = trimws(name, which = 'both')) %>%
#   mutate(name = gsub('DE', '', name)) %>% 
#   mutate(name = trimws(name, which = 'both')) %>%
#   mutate(district = 'Mopeia') %>%
#   mutate(facility_number = NA) %>%
#   mutate(details = paste0(`Posto Administrativo`, ', ', Localidade)) %>%
#   dplyr::select(name, lng, lat, facility_number, details, district) %>%
#   mutate(name = Hmisc::capitalize(tolower(name)))
mopeia_health_facilities <- read_csv('health_facilities/Mopeia_HealthFacilities_gps_EE.csv') %>%
  dplyr::rename(name = hf_name,
                facility_number = hf_id,
                lng = `_hf_gps_longitude`,
                lat = `_hf_gps_latitude`) %>%
  mutate(district = 'Mopeia') %>%
  mutate(details = NA) %>%
  mutate(facility_number = as.character(facility_number)) %>%
  dplyr::select(name, lng, lat, facility_number, details, district)
health_facilities <- bind_rows(mopeia_health_facilities,
                               rufiji_health_facilities)
usethis::use_data(health_facilities,
                  mopeia_health_facilities,
                  rufiji_health_facilities, 
                  overwrite = TRUE)

# Read in the location hierachy
library(gsheet)
url <- 'https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit?usp=sharing'
# Fetch the data
locations <- gsheet::gsheet2tbl(url = url)
location_hierarchy <- locations
usethis::use_data(locations, location_hierarchy,
                  overwrite = TRUE)

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
