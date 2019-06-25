#' Create buffers
#' 
#' Generate buffers of size \code{meters} around points or polygons
#' @param shp The spatialPolygonsDataFrame (projected in lat/long)
#' @param meters The size of the buffer in meters
#' @param crs 
#' @return A SpatialPolygonsDataFrame
#' @export
#' @import dplyr
#' @import rgeos
#' @import sp

create_buffers <- function(shp,
                           meters = 1000,
                           crs = "+init=epsg:3347"){
  
  # Delete the below; for testing only
  library(dplyr);library(rgeos);library(sp)
  source('generate_fake_locations.R')
  source('create_borders.R')
  df <- generate_fake_locations()
  shp <- create_borders(df = df)
  
  # Project the shp
  crs_ll <- "+init=epsg:4326"
  proj4string(shp) <-CRS(crs_ll)
  shp_projected <- spTransform(shp, crs)
  
  # Add the buffer
  buffered <- rgeos::gBuffer(spgeom = shp_projected,
                             width = meters,
                             byid = TRUE)
  
  # Project back to latlong
  out <- spTransform(buffered, crs_ll)
  return(out)
}