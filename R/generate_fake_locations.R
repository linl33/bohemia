#' Generate fake locations
#' 
#' Generate some random x y locations for testing spatial methods
#' @param n The number of points
#' @param n_clusters The number of clusters. If 0, points will be completely random; if greater than 0, points will be distributed in clusters (ideal for simulating villages, for example)
#' @param sd The standard deviation of the distance from cluster centroid to each point. Note that clusters are distributed in a 0-1 (x and y) space.
#' @return A \code{tibble} of \code{n} points with x and y values
#' @export
#' @import dplyr

generate_fake_locations <- function(n = 1000,
                                    n_clusters = 10,
                                    sd = 0.02){
  
  # Ensure that inputs are coherent
  if(n_clusters < 0){
    stop('n_clusters must be an integer greater than or equal to 0.')
  }
  if(n < 0){
    stop('n must be an integer greater than or equal to 0.')
  }
  if(n_clusters > n){
    stop('The number of clusters (n_clusters) cannot be greater than the number of points (n).')
  }
  
  # Generate cluster centroids
  if(n_clusters > 0){
    centroids <- tibble(x = runif(n = n_clusters),
                        y = runif(n = n_clusters))
  } else {
    centroids <- tibble(x = runif(n = 1),
                        y = runif(n = 1))
  }
  
  # Generate a vector of centroid association
  # (ie, which point belongs to which centroid)
  belonging <- (1:n %% n_clusters) + 1
  
  # Establish a location for each point
  out_list <- list()
  for(i in 1:n){
    # Define the belonging
    this_belonging <- belonging[i]
    # Define the centroid
    this_centroid <- centroids[this_belonging,]
    # Add some jitter
    this_location <- this_centroid %>%
      mutate(x = x + rnorm(n = 1, sd = sd),
             y = y + rnorm(n = 1, sd = sd),
             cluster = this_belonging)
    out_list[[i]] <- this_location
  }
  # Combine all the new points 
  out <- bind_rows(out_list)
  # Return the tibble of points
  return(out)
}
