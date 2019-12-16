#' Create voronoi tiles
#'
#' Create voronoi tiles using Delaunay triangulation for an entire surface based on ID'ed points
#' @param shp A spatial points dataframe with the following columns in the data slot: lng, lat, id (the id being the repeated area signifier)
#' @param poly An optional spatialPolygonsDataFrame by which the triangles will be trimmed
#' @return A spatialPolygonsDataFrame
#' @import rgeos
#' @import deldir
#' @export
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