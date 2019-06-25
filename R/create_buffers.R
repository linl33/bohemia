#' Create buffers
#'
#' Generate buffers of size \code{meters} around points or polygons
#' @param shp The spatialPolygonsDataFrame (projected in lat/long)
#' @param meters The size of the buffer in meters
#' @param crs The coordinate reference system for projecting the data
#' @param ids A vector of ids (the same length as the number of rows of shp) with intervention status
#' @return A SpatialPolygonsDataFrame
#' @export
#' @import dplyr
#' @import rgeos
#' @import sp
#' @import gpclib
#' @import maptools

create_buffers <- function(shp,
                           meters = 1000,
                           crs = "+init=epsg:3347",
                           ids = NULL){

  # # Delete the below; for testing only
  # library(dplyr);library(rgeos);library(sp); library(gpclib); library(maptools)
  # source('generate_fake_locations.R')
  # source('create_borders.R')
  # df <- generate_fake_locations()
  # shp <- create_borders(df = df)
  # crs = "+init=epsg:3347"
  # meters = 1000

  # Project the shp
  crs_ll <- "+init=epsg:4326"
  proj4string(shp) <-CRS(crs_ll)
  shp_projected <- spTransform(shp, crs)

  # If there are ids, address accordingly
  if(!is.null(ids)){
    suppressWarnings(gpclibPermit())
    suppressWarnings(shp_projected <- unionSpatialPolygons(shp_projected,
                                                           ids,
                                                           avoidGEOS=TRUE))
  } else {
    shp_projected$data$id <- shp_projected@data$cluster
  }

  # Add the buffer
  buffered <- rgeos::gBuffer(spgeom = shp_projected,
                             width = meters,
                             byid = TRUE)

  # Project back to latlong
  out <- spTransform(buffered, crs_ll)
  return(out)
}
