library(leaflet)
library(sp)
library(raster)
library(deldir)
library(rgeos)
# library(leaflet.providers)
# library(leaflet.extras)

# at the time of writing, version 1.8.0
# pd <- providers_default()


## Retrieve data using bohemia package
# mopeia2 <- bohemia::mopeia2
# rufiji2 <- bohemia::rufiji2
# mopeia_health_facilities <- bohemia::mopeia_health_facilities
# rufiji_health_facilities <- bohemia::rufiji_health_facilities
# save(mopeia2, file = 'data/mopeia2.rda')
# save(rufiji2, file = 'data/rufiji2.rda')
# save(mopeia_health_facilities, file = 'data/mopeia_health_facilities.rda')
# save(rufiji_health_facilities, file = 'data/rufiji_health_facilities.rda')

# load('data/mopeia2.rda')
# load('data/rufiji2.rda')
# load('data/mopeia_health_facilities.rda')
# load('data/rufiji_health_facilities.rda')

# Get a fake polygon
polygon <- getData(name = 'GADM',
                   country = 'ESP',
                   level = 4)
polygon <- polygon[polygon@data$NAME_2 == 'Navarra',]
halven <- function(p, fun = mean){
  bbp <- bbox(p)
  meds <- apply(bbp, 1, fun)
  p <- p[coordinates(p)[,1] > meds[1] &
                       coordinates(p)[,2] > meds[2],]
  return(p)
}
# polygon <- halven(polygon)
polygon <- halven(polygon)
polygon <- halven(polygon, fun = function(x){quantile(x, 0.37)})
bbp <- bbox(polygon)

add_zero <- function (x, n) {
  x <- as.character(x)
  adders <- n - nchar(x)
  adders <- ifelse(adders < 0, 0, adders)
  for (i in 1:length(x)) {
    if (!is.na(x[i])) {
      x[i] <- paste0(paste0(rep("0", adders[i]), collapse = ""), 
                     x[i], collapse = "")
    }
  }
  return(x)
}

generate_fake_locations <- function(bbp, nn = 1000){
  # Generate fake locations
  samplify <- function(x, n = 100, replace = TRUE){
    out <- seq(x[1], x[2], length = 10000)
    sample(out, size = n, replace = replace)
  }
  xs <- as.numeric(bbp[1,])
  ys <- as.numeric(bbp[2,])
  
  
  xs <- samplify(xs, n = nn)
  ys <- samplify(ys, n = nn)
  
  locations <- tibble(x = xs,
                      y = ys) %>%
    mutate(lng = x,
           lat = y)
  coordinates(locations) <- ~x+y
  proj4string(locations) <- proj4string(polygon)
  
  # Keep only those which are in the polygon
  locations <- locations[!is.na(over(locations, polygons(polygon))),]
  
  # Get the comarcas of the locations
  x <- over(locations, polygons(polygon))
  locations$comarca <- polygon@data$NAME_4[x]
  locations$id <- locations$comarca
  
  # Assign fake qr codes
  part1 <- sample(add_zero(1:10, n = 3), size = nrow(locations) + 100, replace = TRUE)
  part2 <- sample(add_zero(0:1000, n = 3), size = nrow(locations) + 100, replace = TRUE)
  combined <- paste0(part1, '-', part2)
  combined <- combined[!duplicated(combined)]
  combined <- combined[1:nrow(locations)]
  locations$qr <- combined
  
  return(locations)
}

# Create delaunay triangulation / voronoi tiles for entire surface
voronoi <- function(shp, poly = NULL){
  require(rgeos)
  shp@data <- data.frame(shp@data)
  
  # Make sure required columns exist
  spd <- shp@data
  for(i in c('lng', 'lat', 'id')){
    if(!i %in% names(spd)){
      stop(paste0(i, ' not in the names of the shp file. Required column names: lng, lat, id'))
    }
  }
  
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
  jdata = gUnaryUnion(tile_polys, id = tile_polys$id)

  # Use poly borders if applicable
  if(!is.null(poly)){
    proj4string(jdata) <- proj4string(poly)
    poly <- gUnaryUnion(poly)
    original_names <- names(jdata)
    jdata <- rgeos::gIntersection(jdata, poly, byid = TRUE)
    row.names(jdata) <- original_names
  }
  jdata = SpatialPolygonsDataFrame(Sr=jdata, 
                                   data=data.frame(id = as.character(names(jdata))),FALSE)
  return(jdata)
}

# Function for retrieving spatial info
get_space <- function(loc){
  out <- loc@data %>% 
    arrange(qr) %>%
    dplyr::select(qr, id, lng, lat) %>%
    mutate(lng = round(lng, digits = 4),
           lat = round(lat, digits = 4)) %>%
    dplyr::rename(hamlet = id)
  return(out)
}