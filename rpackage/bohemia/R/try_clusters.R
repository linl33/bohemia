#' Try creating clusters
#'
#' Try creating clusters from the recon / animal annex data
#' @param the_country Either Mozambique or Tanzania
#' @param include_clinical Whether to include hamlets which are part of another ongoing clinical trial
#' @param interpolate_animals Whether to guess the number of animals if they are missing
#' @param interpolate_humans Whether to guess the number of humans if they are missing
#' @param humans_per_household The number of humans per household
#' @param p_children The percentage of people which are considered to be children
#' @param minimum_children The minimum number of children required for a cluster
#' @param minimum_humans The minimum number of humans required for a cluster
#' @param minimum_animals The minimum number of animals required for a cluster 
#' @param minimum_cattle The minimum number of cattle required for a cluster
#' @param minimum_pigs The minimum number of pigs required for a cluster
#' @param minimum_goats The minimum number of goats required for a cluster
#' @param df A dataframe with combined animal and household info, as generated in global.R of operations app
#' @return A list
#' @import rgeos
#' @import deldir
#' @import dplyr
#' @import sp
#' @import geosphere
#' @import htmlTable
#' @export


try_clusters <- function(the_country = 'Tanzania',
                         include_clinical = TRUE,
                         interpolate_animals = TRUE,
                         interpolate_humans = TRUE,
                         humans_per_household = 5,
                         p_children = 30,
                         minimum_households = 0,
                         minimum_children = 35,
                         minimum_humans = 0,
                         minimum_animals = 35,
                         minimum_cattle = 0,
                         minimum_pigs = 0,
                         minimum_goats = 0,
                         df = NULL){

#   # Temporary, just for testing  
  the_country = 'Tanzania'
  include_clinical = TRUE
  interpolate_animals = TRUE
  interpolate_humans = TRUE
  humans_per_household = 5
  p_children = 30
  minimum_households = 0
  minimum_children = 35
  minimum_humans = 0
  minimum_animals = 35
  minimum_cattle = 0
  minimum_pigs = 0
  minimum_goats = 0

  # Define the shp based on the country
  if(the_country == 'Tanzania'){
    shp <- ruf2
  } else {
    shp <- mop2
  }

  # Define the sufficiency rules
  human_sufficiency_rule <- paste0('n_children >= ', minimum_children, ' & ',
                                   'n_humans >= ', minimum_humans, ' & ',
                                   'n_households >= ', minimum_households)
  animal_sufficiency_rule <- paste0('n_animals >= ', minimum_animals, ' & ',
                                    'n_cattle >= ', minimum_cattle, ' & ',
                                    'n_pigs >= ', minimum_pigs, ' & ',
                                    'n_goats >= ', minimum_goats)
  sufficiency_rule <- paste0(animal_sufficiency_rule, ' & ',
                             human_sufficiency_rule)
  suffiency_text <- paste0(
    "this_cluster <- this_cluster %>% summarise(n_households = sum(n_households), n_humans = sum(n_humans), n_cattle = sum(n_cattle), n_pigs = sum(n_pigs), n_goats = sum(n_goats), n_animals = sum(n_animals), n_children = sum(n_children)) %>%
  dplyr::mutate(is_sufficient = ", sufficiency_rule, ")"
  )

  # Get the locations filtered
  xdf <- df
  if(!include_clinical){
    xdf <- xdf %>% filter(!clinical_trial)
  }
  xdf <- xdf %>% filter(Country == the_country) 
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
    xdf[,this_column] <- recodify(as.character(unlist(xdf[,this_column])))
  }

  # Carry out interpolations
  if(interpolate_humans){
    missing_humans <- which(is.na(xdf$n_households))
    message('Going to inerpolate for ', length(missing_humans), ' hamlets with missing number of households')
    if(length(missing_humans) > 0){
      for(i in missing_humans){
        this_row <- missing_humans[i]
        xdf$n_households[i] <- sample(xdf$n_households[!is.na(xdf$n_households)],
                                     1)
      }
    }
  }
  if(interpolate_animals){
    animal_vars <- c('n_cattle', 'n_goats', 'n_pigs')
    for(j in 1:length(animal_vars)){
      animal_var <- animal_vars[j]
      animal_name <- gsub('n_', '', animal_var)
      missing_animals <- which(is.na(unlist(xdf[,animal_var])))
      message('Going to inerpolate for ', length(missing_animals), ' hamlets with missing ', animal_name)
      if(length(missing_animals) > 0){
        for(i in missing_animals){
          this_row <- missing_animals[i]
          good_animals <- as.numeric(unlist(xdf[,animal_var]))
          good_animals <- good_animals[!is.na(good_animals)]
          xdf[i, animal_var] <- sample(good_animals, 1)
        }
      }
    }
  }

  # Define number of people variable
  xdf$n_humans <- xdf$n_households * humans_per_household
  # Define a n_children variable
  xdf$n_children <- xdf$n_households * (0.01 * p_children)
  # Define an animal variable
  xdf$n_animals <- xdf$n_cattle + xdf$n_goats + xdf$n_pigs

  # Remove any data with missing animals or humans
  xdf <- xdf %>%
    filter(!is.na(n_households),
           !is.na(n_cattle),
           !is.na(n_pigs),
           !is.na(n_goats),
           !is.na(n_children),
           !is.na(n_humans),
           !is.na(n_animals))


  # Create a space for indicating whether the hamlet
  # has already been assigned to a cluster or not
  xdf$assigned <- FALSE
  xdf$cluster <- 0

  # Spatial section ######################################
  # Create a spatial version of xdf
  xdf$id <- 1:nrow(xdf)
  xdf_sp <- xdf
  coordinates(xdf_sp) <- ~lng+lat
  proj4string(xdf_sp) <- CRS("+init=epsg:4326") # define as lat/lng
  zone <- 36
  new_proj <- CRS(paste0("+proj=utm +zone=",
                         zone,
                         " +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
  xdf_sp <- spTransform(xdf_sp, new_proj)

  # Get a distance matrix between all points
  distance_matrix <- rgeos::gDistance(spgeom1 = xdf_sp, byid = TRUE)

  # Loop around and build clusters
  cluster_list <- list()
  done_ids  <- c()
  done <- FALSE
  cluster_counter <- 1

  # Pre-assign (before creating clusters) the treatment groups
  # (so as to not have the necessity of buffers between clusters of identical
  # treatment groups)
  assignment_vector <- c(rep(1, 48), rep(2, 48), rep(3, 48))
  assignment_vector <- sample(assignment_vector, length(assignment_vector))
  # Add to it in case we have more than 3*48 clusters
  part2 <- sample(1:3, size = 1000000 - length(assignment_vector), replace = TRUE)
  assignment_vector <- c(assignment_vector, part2) # this is now unnecessarily long, but at least has perfect uniform distribution for the first 144 elements, which is needed

  while(!done){
    message(paste0('Working on cluster ', cluster_counter))
    # If there have been no assignments yet, find a start point
    if(length(which(xdf$assigned)) < 1){
      median_distances <- as.numeric(apply(distance_matrix, 1, median, na.rm = TRUE))
      start_here <- which.min(median_distances)[1]
      this_id <- xdf$id[start_here]
      xdf$assigned[start_here] <- TRUE
      xdf$cluster[start_here] <- cluster_counter
      done_ids <- c(done_ids, this_id)
    }
    # Use whatever the "next_id" is to start building a new cluster
    this_cluster <- this_hamlet <-  xdf %>% filter(id == this_id)
    # See if this hamlet is sufficient by itself
    eval(parse(text = suffiency_text))
    is_sufficient <- this_cluster$is_sufficient
    # if not sufficient, get nearest
    hamlet_counter <- 1
    message('...1 hamlet')
    if(is.na(this_id)){
      done <- TRUE
    }
    while(!is_sufficient & !done){
      hamlet_counter <- hamlet_counter + 1
      message('...', hamlet_counter, ' hamlets')
      this_index <- which(xdf$id == this_id)
      # Get the nearest hamlet
      distances_from_index <- as.numeric(distance_matrix[this_index,])
      # but make sure not to include any hamlets which are already done
      ok_to_use <- which(!xdf$assigned)
      ids <- xdf$id[ok_to_use]
      distances_from_index <- distances_from_index[ok_to_use]
      nearest_index <- which.min(distances_from_index)[1]
      close_id <- ids[nearest_index]
      xdf$assigned[xdf$id == close_id] <- TRUE
      xdf$cluster[xdf$id == close_id] <- cluster_counter
      done_ids <- c(done_ids, close_id)
      this_hamlet <- xdf %>% filter(id == close_id)
      this_cluster <- bind_rows(this_hamlet %>% dplyr::select(n_households,
                                                              n_humans,
                                                              n_cattle,
                                                              n_pigs,
                                                              n_goats,
                                                              n_animals,
                                                              n_children),
                                this_cluster %>% dplyr::select(-is_sufficient))
      eval(parse(text = suffiency_text))
      is_sufficient <- this_cluster$is_sufficient
      # Define the next_id
      if(!is_sufficient){
        ok_to_use <- which(!xdf$assigned)
        ids <- xdf$id[ok_to_use]
        next_near_index <- which(xdf$id == close_id)
        distances_from_index <- as.numeric(distance_matrix[next_near_index,])
        distances_from_index <- distances_from_index[ok_to_use]
        nearest_index <- which.min(distances_from_index)[1]
        close_id <- ids[nearest_index]
        this_id <- close_id
        if(length(which(xdf$assigned)) == nrow(xdf)){
          done <- TRUE
        }
        # message('---Assigning hamlet with id: ', close_id)
        # xdf$assigned[xdf$id == close_id] <- TRUE
        # xdf$cluster[xdf$id == close_id] <- TRUE
        # done_ids <- c(done_ids, close_id)
      }
    }
    # Finished one cluster, start the next one
    cluster_counter <-cluster_counter + 1
    message('Starting work on cluster number ', cluster_counter)
    ok_to_use <- which(!xdf$assigned)
    ids <- xdf$id[ok_to_use]
    distances_from_index <- as.numeric(distance_matrix[this_index,])

    this_group <- assignment_vector[cluster_counter]
    next_group <- assignment_vector[cluster_counter + 1]
    if(length(next_group) == 0){
      is_same <- FALSE
    } else {
      is_same <- this_group == next_group
    }
    if(!is_same){
      not_ok <- which(distances_from_index < 2000)
      not_ok_ids <- ids[not_ok]
      xdf$assigned[xdf$id %in% not_ok_ids] <- TRUE
      done_ids <- c(done_ids, not_ok_ids)
      ok_to_use <- ok_to_use[!ok_to_use %in% not_ok]
    }

    if(length(ok_to_use) > 0){

      distances_from_index <- distances_from_index[ok_to_use]
      nearest_index <- which.min(distances_from_index)[1]
      close_id <- ids[nearest_index]
      this_id <- close_id

      message('---Assigning hamlet with id: ', close_id)
      xdf$assigned[xdf$id == close_id] <- TRUE
      xdf$cluster[xdf$id == close_id] <- cluster_counter
      done_ids <- c(done_ids, close_id)
    } else {
      done <- TRUE
    }

    if(length(which(xdf$assigned)) == nrow(xdf)){
      done <- TRUE
    }
    message(length(which(xdf$assigned)), ' hamlets done')
    message(cluster_counter)
  }

  # Bring in assignment numbers
  assignment_xdf <- tibble(cluster = 1:1000000,
                          assignment_group = assignment_vector)
  # Generate summary dataframes
  hamlet_xdf <- left_join(xdf, assignment_xdf)
  cluster_xdf <- hamlet_xdf %>%
    group_by(cluster) %>%
    summarise(n_hamlets = length(unique(id)),
              assignment_group = dplyr::first(assignment_group),
              hamlet_codes = paste0(code, collapse = ', '),
              n_households = sum(n_households),
              n_cattle = sum(n_cattle),
              n_pigs = sum(n_pigs),
              n_goats = sum(n_goats),
              n_animals = sum(n_animals),
              n_children = sum(n_children))
  # Get a summary text
  summary_text <- paste0(
    nrow(hamlet_xdf), ' total hamlets, of which ',
    length(which(hamlet_xdf$cluster == 0)), ' fall into "buffer" areas. ', 1-nrow(cluster_xdf), ' were able to be formed with the given rules.'
  ) 
  # Make a leaflet object
  cols <- rainbow(max(cluster_xdf$cluster) + 1)
  cols <- sample(cols, length(cols))
  cols[1] <- 'black'
  map <- leaflet() %>%
    addProviderTiles(providers$Esri.WorldImagery) %>%
    addPolygons(data = shp, 
                stroke = TRUE,
                fillOpacity = 0,
                color = 'white') %>%
    addCircleMarkers(data = hamlet_xdf,
                     radius = 5,
                     fillOpacity = 0.5,
                     stroke = TRUE,
                     color = cols[hamlet_xdf$cluster +1],
                     popup = paste0(hamlet_xdf$code, '<br>',
                                    ifelse(hamlet_xdf$cluster > 0, paste0('Cluster number: ', hamlet_xdf$cluster, '.<br>Treatment assignment group (1-3): ', cluster_xdf$assignment_group), 'No cluster (buffer zone).'),
                                     '.<br>',
                                    hamlet_xdf$n_cattle, ' cattle.',
                                    hamlet_xdf$n_goats, ' goats. ',
                                    hamlet_xdf$n_pigs, ' pigs. ',
                                    hamlet_xdf$n_animals, ' animals.<br>',
                                    hamlet_xdf$n_households, ' households. ',
                                    hamlet_xdf$n_humans, ' humans. ', 
                                    hamlet_xdf$n_children, ' children.'))
  
  out_list <- list(summary_text,
                   map,
                   hamlet_xdf,
                   cluster_xdf)
  names(out_list) <- c('summary_text', 'map', 'hamlet_xdf', 'cluster_xdf')
  return(out_list)
  
  # for(i in 1:nrow(hamlet_df)){
  #   this_hamlet <- hamlet_df[i,]
  #   this_table <- this_hamlet %>%
  #     dplyr::select(code, n_cattle, n_goats, n_pigs, n_households,
  #                   n_humans, n_children, n_animals,
  #                   cluster)
  #   a <- gsub('n_', '', names(this_table))
  #   b <- as.character(this_table[1,])
  #   this_table <- tibble(Key = a, Value = b)
  #   map <- map %>%
  #     addCircleMarkers(data = this_hamlet,
  #                      color = cols[this_hamlet$cluster],
  #                      popup = htmlTable(this_table, rnames = FALSE))
  # }
    
  # map
  # # Make a polygonal object for each cluster
  # poly_list <- list()
  # for (i in 2:nrow(cluster_df)){ # skip first row because it is those hamlets with no cluster due to buffers
  #   message(i)
  #   this_cluster_df <- cluster_df[i,]
  #   this_cluster_number <- this_cluster_df$cluster
  #   this_hamlet_df <- hamlet_df %>% filter(cluster == this_cluster_number)
  #   # Get spatial version
  #   this_hamlet_df_sp <- this_hamlet_df
  #   coordinates(this_hamlet_df_sp) <- ~lng+lat
  #   proj4string(this_hamlet_df_sp) <- proj4string(shp)
  #   this_hamlet_df_sp@data$id <- this_hamlet_df_sp@data$cluster
  #   this_hamlet_df_sp@data$lng <- this_hamlet_df$lng
  #   this_hamlet_df_sp@data$lat <- this_hamlet_df$lat
  #   poly <- gConvexHull(spgeom = this_hamlet_df_sp)
  #   if(!class(poly) == 'SpatialPolygons'){
  #     poly <- st_as_sf(poly)
  #     poly <- st_buffer(poly, 0.000001)
  #     poly <- sf::as_Spatial(poly)
  #   }
  # 
  #   poly_df <- SpatialPolygonsDataFrame(Sr = poly, data = data.frame(cluster = this_cluster_number))
  #   poly_list[[i-1]] <- poly_df
  # }
  # polys <- do.call('rbind', poly_list)


}

