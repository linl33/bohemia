#' Make animal map
#'
#' Make animal map from the recon / animal annex data
#' @param the_country Either Mozambique or Tanzania
#' @param include_animals Character vector of animals to include
#' @param granularity How granular
#' @param weighter weighting function
#' @param interpolate Whether to interpolate values or not
#' @param df A dataframe with combined animal and household info, as generated in global.R of operations app
#' @return A list
#' @import rgeos
#' @import sp
#' @import ggplot2
#' @import dplyr
#' @import geosphere


make_animal_map <- function(the_country = 'Tanzania',
                            include_animals = c('goats', 'cattle', 'pigs'),
                            granularity = 0.02,
                            weighter = function(distance){1 / distance},
                            interpolate = FALSE,
                            df = NULL){
  
  # source('global.R')
  # library(rgeos)
  # library(sp)  
  # library(ggplot2)
  # library(dplyr)
  # library(geosphere)
  # the_country = 'Tanzania'
  # include_animals = c('goats', 'cattle', 'pigs')
  # granularity = 0.02
  # weighter = function(distance){1 / distance}
  # interpolate = FALSE
  
  # Define the shp based on the country
  if(the_country == 'Tanzania'){
    shp <- ruf2
  } else {
    shp <- mop2
  }
  shp_fort <- fortify(shp, group = 'GID_0')
  
  # Get the dataframe of animal values
  right <- animal %>%
    filter(Country == the_country) %>%
    dplyr::select(lon, lat, n_cattle, n_goats, n_pigs)
  # Recode categorical variables so as to get approximate numbers
  recodify <- function(x){
    x <- as.character(x)
    x <- ifelse(x == '0', 0,
                ifelse(x == '1 to 5', 3,
                       ifelse(x == '6 to 19', 12,
                              ifelse(x == '20 or more', 35, NA))))
    return(x)
  }
  n_names <- c('n_cattle', 'n_goats', 'n_pigs')
  for(j in 1:length(n_names)){
    this_column <- n_names[j]
    right[,this_column] <- recodify(as.character(unlist(right[,this_column])))
  }
  # Get total animals (depending on the input variable)
  right$value <- NA
  if('cattle' %in% include_animals){
    right$value <- ifelse(is.na(right$n_cattle), 0, right$n_cattle)
  } else {
    right$value <- 0
  }
  if('goats' %in% include_animals){
    right$value <- right$value + ifelse(is.na(right$n_goats), 0, right$n_goats)
  }
  if('pigs' %in% include_animals){
    right$value <- right$value + ifelse(is.na(right$n_pigs), 0, right$n_pigs)
  }
  
  if(interpolate){
    # Get a grid based on the shapefile
    bb <- bbox(shp)
    xs <- as.numeric(bb[1,])
    ys <- as.numeric(bb[2,])
    gr <- expand.grid(x = seq(min(xs), max(xs), by = granularity),
                      y = seq(min(ys), max(ys), by = granularity)) %>%
      mutate(lng = x, lat = y)
    # Make spatial
    coordinates(gr) <- ~x+y; proj4string(gr) <- proj4string(shp)
    # Reduce to the borders of the district
    message('Getting intersection, takes a bit of time.')
    gr <- gIntersection(gr, shp, byid = FALSE)
    # Revert back to dataframe
    grdf <- coordinates(gr)
    grdf <- data.frame(grdf)
    names(grdf) <- c('x', 'y')
    grdf$val <- NA
    
    # Get a spatial version of right
    rightsp <- right %>% filter(!is.na(lon))
    coordinates(rightsp) <- ~lon+lat
    proj4string(rightsp) <- proj4string(shp)
    # Get a matrix of distances between (a) all the points in gr and (b) all the points in right
    distance_matrix <- spDists(x = gr, y = rightsp, longlat = TRUE)
    
    # Loop through each point getting the weighted nearby values
    for(i in 1:nrow(grdf)){
      these_distances <- distance_matrix[i,]
      these_values <- weighter(these_distances) * rightsp@data$value
      this_value <- mean(these_values, na.rm = TRUE)
      grdf$val[i] <- this_value
    }
    
    g <- ggplot() +
      geom_tile(data = grdf,
                aes(x = x, y = y, fill = val)) +
      scale_fill_gradientn(colors = c('beige', 'darkred')) +
      geom_polygon(data = shp_fort,
                   aes(x = long,
                       y = lat,
                       group = group),
                   fill = NA,
                   color = 'black') +
      ggthemes::theme_map() +
      theme(legend.position = 'none')
  } else {
    g <- ggplot() +
      geom_point(data = right,
                 aes(x = lon, y = lat, color = value,
                     size = value),
                 alpha = 0.6) +
      scale_color_gradientn(colors = c('white', 'orange', 'red', 'darkred')) +
      geom_polygon(data = shp_fort,
                   aes(x = long,
                       y = lat,
                       group = group),
                   fill = NA,
                   color = 'black') +
      ggthemes::theme_map() +
      scale_size_continuous(name = 'Value',
                            limits=range(right$value, na.rm = TRUE), breaks=seq(min(right$value, na.rm = TRUE), 
                                                                                max(right$value, na.rm = TRUE), length = 5)) +
      guides(color = FALSE)
      
  }
  # Done
  return(g)
}

