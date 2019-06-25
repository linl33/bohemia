#' Create borders
#' 
#' Generate borders around clusters of points
#' @param df A dataframe with variables named \code{x}, \code{y}, and \code{cluster}
#' @return A SpatialPolygonsDataFrame
#' @export
#' @import dplyr
#' @import rgeos
#' @import sp

create_borders <- function(df){
  
  # # Delete the below; for testing only
  # library(dplyr);library(rgeos);library(sp)
  # source('generate_fake_locations.R')
  # df <- generate_fake_locations(n = 100) 
  
  # Ensure that the input data contains the required variables
  if(!'x' %in% names(df) |
     !'y' %in% names(df) |
     !'cluster' %in% names(df)){
    stop('df must contain variables named "x", "y", and "cluster"')
  }
  
  # Convert to spatial
  df_sp <- df
  coordinates(df_sp) <- ~x+y
  
  # Loop through each cluster and get the convex hull
  cluster_numbers <- sort(unique(df_sp@data$cluster))
  out_list <- list()
  for(i in 1:length(cluster_numbers)){
    this_cluster <- cluster_numbers[i]
    this_sub_data <- df_sp[df_sp@data$cluster == this_cluster,]
    this_boundary <- rgeos::gConvexHull(spgeom = this_sub_data)
    # eval(parse(text = eval(expression(paste(pasted_slot_path, "<-", value)))))
    slot(slot(this_boundary, "polygons")[[1]], "ID") <- as.character(this_cluster)
    
    out_list[[i]] <- this_boundary
  }
  the_boundaries <- SpatialPolygons(lapply(out_list,
                                 function(x) slot(x, "polygons")[[1]]))
  # Turn the SpatialPolygons into a SpatialPolygonsDataFrame
  out <- SpatialPolygonsDataFrame(Sr = the_boundaries,
                                  data = data.frame(cluster = cluster_numbers))
  return(out)
}