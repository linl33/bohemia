#' Optimization of cluster formation
#' 
#' Use the brute force method to assign households to clusters in a way that minimizes inter-cluster distance.
#' @param cluster_size The size of each cluster
#' @param plot_map Whether to plot a map after each cluster formation (slows down operations significantly)
#' @param locations a SpatialPointsDataFrame containing 3 columns: id, lat, and lon
#' @param shp The shapefile to plot (only if plot_map is TRUE)
#' @param sleep How many seconds to sleep between plots
#' @param locations locations
#' @param start The start strategy
#' @param rest The rest strategy
#' @param messaging Whether to message or not, boolean
#' @return A dataframe of size \code{times} times the number of points in \code{locations}, with columns indicating each \code{simulation_number}
#' @export
#' @import dplyr


create_clusters <- function(cluster_size = 10,
                             plot_map = FALSE,
                             sleep = 0,
                             locations, 
                             shp = NULL, 
                             start= 'close', #c("far", "close", "random"),
                             rest=  'close', #c("far", "close", "random"),
                             messaging = FALSE){
  
  require(dplyr)
  require(sp)
  
  # Make locations a spatial object
  locations$dummy <- 1:nrow(locations)
  coordinates(locations) <- ~x+y
  proj4string(locations) <- CRS("+init=epsg:4326")
  
  # Get a distance matrix between all points
  distance_matrix <-
    spDists(x = locations,
            longlat = TRUE)
  
  # # Repeat [times] times the search
  # for (time in 1:times){
  
  ## We are adding a colum with a numeric index for each of the points id
  locations$index<-1:nrow(locations)
  # Create a fresh copy of locations
  locations_fresh <- locations
  # Specify that none of the points have yet been selected
  locations_fresh$selected <- FALSE
  # Create a column for clusters
  locations_fresh$cluster <- NA
  # # Create column for simulations
  # locations_fresh$simulation_number <- time
  # Create column for indication of whether full sized cluster or not
  locations_fresh$complete_cluster <- TRUE
  
  # Pick a start point
  # ONLY IF THERE ARE MORE THINGS TO BE SELECTED 
  # (we need to add conditionality here)
  # (the point which is furthest from all other points)
  possibles <- distance_matrix[!locations_fresh$selected, !locations_fresh$selected]
  # possibles <- spDists(x = locations_fresh[!locations_fresh$selected,],
  #                      longlat = TRUE)
  
  if(start=="far") {
    start_index <- locations_fresh$index[!locations_fresh$selected][which.max(rowSums(possibles))][1]  
  } else if(start=="close"){
    start_index <- locations_fresh$index[!locations_fresh$selected][which.min(rowSums(possibles))][1]  
  }else if(start=="random") {
    start_index <- sample(which(!locations_fresh$selected),1)
  }else {
    stop("start must be one of (far, close, random)")
  }
  
  # Start the cluster counter 
  cluster <- 1
  
  # Go until all the points are filled
  while(length(which(!locations_fresh$selected)) > 0){
    if(messaging){
      message(paste0('making cluster number ', cluster,'\n',
                     length(which(!locations_fresh$selected)),
                     ' points remaining'))   
    }
    
    # Use the start index to get a start point
    start_point <- locations_fresh[locations_fresh$index == start_index,]
    # Remove that start point from the list of eligibles
    locations_fresh$selected[locations_fresh$index == start_index] <- TRUE
    # Assign the cluster to the start point
    locations_fresh$cluster[locations_fresh$index == start_index] <- cluster
    
    # Get the distance of all remaining points from the start_point
    # all_distances <- spDistsN1(pts = locations, 
    #                            pt = start_point,
    #                            longlat = TRUE)
    all_distances <- distance_matrix[start_index,]
    all_distances <- data.frame(index = 1:nrow(locations),
                                distance = all_distances)
    # Remove those rows which are ineligible (already selected/start_point)
    all_distances <- 
      all_distances[! all_distances$index %in% which(locations_fresh$selected),]
    
    # Order by distance
    all_distances <- all_distances[order(all_distances$distance),]
    
    # Get the cluster_size nearest points
    # (or fewer, if not enough eligible points still remain)
    incomplete_cluster <- (nrow(all_distances) + 1) < cluster_size
    if(incomplete_cluster){
      # Just get whatever is left
      nearest <- all_distances
    } else {
      nearest <- all_distances[1:(cluster_size - 1),]
    }
    
    # Mark those nearest points as part of the same cluster
    locations_fresh$cluster[nearest$index] <- cluster
    # And mark them as selected
    locations_fresh$selected[nearest$index] <- TRUE
    # Mark if it's a full size cluster or not
    locations_fresh$complete_cluster[nearest$index] <- !incomplete_cluster
    locations_fresh$complete_cluster[locations_fresh$index == start_index] <-
      !incomplete_cluster
    
    # Get the start_point for the next round 
    # possibles <- spDists(x = locations_fresh[!locations_fresh$selected,],
    #                      longlat = TRUE)
    possibles <- distance_matrix[!locations_fresh$selected,
                                 !locations_fresh$selected]
    # Ensure that it remains a matrix regardless of size
    possibles <- as.matrix(possibles)
    if(nrow(possibles) > 0){
      if (rest=="far") {
        start_index <- locations_fresh$index[!locations_fresh$selected][which.max(rowSums(possibles))][1]  
      } else if(rest=="close") {
        start_index <- locations_fresh$index[!locations_fresh$selected][which.min(rowSums(possibles))][1]  
      } else if(rest=="random") {
        remaining <- locations_fresh$index[!locations_fresh$selected]
        if(length(remaining) == 0){
          start_index <- NA
        } else {
          start_index <- sample(remaining, 1)       
        }
      } else {
        stop("rest must be one of (far, close, random)")
      }
      
      # Move the cluster counter up
      cluster <- cluster + 1
      
      # Plot if necessary
      if(plot_map){
        colors <- ifelse(locations_fresh$selected, 'red', 'grey')
        plot(shp)
        points(locations_fresh, col = colors, pch = 3)
        points(locations_fresh[nearest$index,], col = 'blue', pch = 1)
        legend('topleft',
               legend = c('This cluster',
                          'Already selected',
                          'Not selected yet'),
               pch = c(1, 3, 3),
               col = c('blue', 'red', 'grey'),
               border = FALSE,
               bty = 'n')
        title(main = paste0('Simulation number ', 
                            # time, 
                            '\n',
                            'Cluster number ', cluster))
        Sys.sleep(sleep)
      }
    }
    
  } # all locations have now been selected
  # return the dataframe
  return(data.frame(locations_fresh))
}