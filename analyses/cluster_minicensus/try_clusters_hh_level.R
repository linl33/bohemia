#' Try creating clusters HH level
#'
#' Try creating clusters from the recon / animal annex data
#' @param the_country Either Mozambique or Tanzania
#' @param include_clinical Whether to include hamlets which are part of another ongoing clinical trial
#' @param minimum_children The minimum number of children required for a cluster
#' @param minimum_humans The minimum number of humans required for a cluster
#' @param minimum_animals The minimum number of animals required for a cluster 
#' @param minimum_cattle The minimum number of cattle required for a cluster
#' @param minimum_pigs The minimum number of pigs required for a cluster
#' @param minimum_goats The minimum number of goats required for a cluster
#' @param km The distance in kilometers between two clusters of different assignment groups
#' @param max_km_from_hq Maximum distance from HQ
#' @param start_at_hq Make the start point be whatever is nearest to HQ so as to get clusters as close to HQ as possible
#' @param df A dataframe with one row for each household and other variables like n_children, n_goats, etc.
#' @return A list
#' @import rgeos
#' @import deldir
#' @import dplyr
#' @import sp
#' @import geosphere
#' @import htmlTable

try_clusters_hh_level <- function(the_country = 'Tanzania',
                         include_clinical = TRUE,
                         minimum_households = 0,
                         minimum_children = 30,
                         minimum_humans = 0,
                         minimum_animals = 35,
                         minimum_cattle = 0,
                         minimum_pigs = 0,
                         minimum_goats = 0,
                         km = 2,
                         max_km_from_hq = 1000,
                         start_at_hq = FALSE,
                         df = NULL){
  set.seed(1)
  # the_country = 'Tanzania'
  # include_clinical = TRUE
  # interpolate_animals = TRUE
  # interpolate_humans = TRUE
  # humans_per_household = 5
  # p_children = 30
  # minimum_households = 0
  # minimum_children = 35
  # minimum_humans = 0
  # minimum_animals = 35
  # minimum_cattle = 0
  # minimum_pigs = 0
  # minimum_goats = 0
  # km = 2
  # max_km_from_hq = 100
  # start_at_hq = FALSE
  
  # save(the_country,
  #      include_clinical,
  #      interpolate_animals,
  #      interpolate_humans,
  #      humans_per_household,
  #      p_children,
  #      minimum_households,
  #      minimum_children,
  #      minimum_humans,
  #      minimum_animals,
  #      minimum_cattle,
  #      minimum_pigs,
  #      minimum_goats,
  #      km,
  #      df,
  #      file = '~/Desktop/temp.RData')
# #   # Temporary, just for testing
  # the_country = 'Tanzania'
  # include_clinical = TRUE
  # interpolate_animals = TRUE
  # interpolate_humans = TRUE
  # humans_per_household = 5
  # p_children = 30
  # minimum_households = 0
  # minimum_children = 35
  # minimum_humans = 0
  # minimum_animals = 35
  # minimum_cattle = 0
  # minimum_pigs = 0
  # minimum_goats = 0
  # km = 2
  # max_km_from_hq = 100
  # start_at_hq = FALSE

  # Define the shp based on the country
  if(the_country == 'Tanzania'){
    shp <- ruf2
  } else {
    shp <- mop2
  }

  # Define the sufficiency rules
  human_sufficiency_rule <- paste0('n_children >= ', minimum_children, ' & ',
                                   'n_humans >= ', minimum_humans)
  # animal_sufficiency_rule <- paste0('n_animals >= ', minimum_animals, ' & ',
  #                                   'n_cattle >= ', minimum_cattle, ' & ',
  #                                   'n_pigs >= ', minimum_pigs, ' & ',
  #                                   'n_goats >= ', minimum_goats)
  # sufficiency_rule <- paste0(animal_sufficiency_rule, ' & ',
  #                            human_sufficiency_rule)
  sufficiency_rule <- human_sufficiency_rule
  suffiency_text <- paste0(
    "this_cluster <- this_cluster %>% summarise(n_households = sum(n_households), n_humans = sum(n_humans),  n_children = sum(n_children)) %>%
  dplyr::mutate(is_sufficient = ", sufficiency_rule, ")"
  )

  # Get the locations filtered
  xdf <- df %>% filter(country == the_country) %>% filter(!is.na(lng))
  
  if(!include_clinical){
    xdf <- xdf %>% filter(!as.logical(clinical_trial))
  }
  # xdf <- xdf %>% filter(Country == the_country) 
  

  if(the_country == 'Tanzania'){
    hq <- data.frame(x = 38.990643,
                     y = -7.933194)
  } else {
    hq <- data.frame(x = 35.710587,
                     y = -17.980314)
  }
  coordinates(hq) <- ~x+y
  ss <- xdf
  coordinates(ss) <- ~lng+lat
  proj4string(ss) <- proj4string(hq) <- proj4string(shp)
  hqll <- hq
  CRS("+proj=utm +zone=36 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
  ss <- spTransform(ss, CRS("+proj=utm +zone=36 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
  hq <- spTransform(hq, CRS("+proj=utm +zone=36 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
  hq_distance <- as.numeric(unlist(gDistance(hq, ss, byid = TRUE)))
  xdf <- xdf[(hq_distance/(max_km_from_hq * 1000)) <= max_km_from_hq,]
  

  # Define number of people variable
  xdf$n_humans <- xdf$n_people
  xdf$n_households <- 1
  # Define an animal variable
  # xdf$n_animals <- xdf$n_cattle + xdf$n_goats + xdf$n_pigs

  # Remove any data with missing animals or humans
  xdf <- xdf %>%
    filter(#!is.na(n_households),
           # !is.na(n_cattle),
           # !is.na(n_pigs),
           # !is.na(n_goats),
           !is.na(n_children),
           !is.na(n_humans)
           # !is.na(n_animals)
           )


  # Create a space for indicating whether the hamlet
  # has already been assigned to a cluster or not
  xdf$assigned <- FALSE
  xdf$cluster <- 0

  # Spatial section ######################################
  
  # Create a spatial version of xdf
  xdf$id <- 1:nrow(xdf)# as.numeric(factor(xdf$code))
  xdf_sp <- xdf
  coordinates(xdf_sp) <- ~lng+lat
  proj4string(xdf_sp) <- CRS("+init=epsg:4326") # define as lat/lng
  zone <- 36
  new_proj <- CRS(paste0("+proj=utm +zone=",
                         zone,
                         " +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
  xdf_sp <- spTransform(xdf_sp, new_proj)

  # Pre-assign (before creating clusters) the treatment groups
  # (so as to not have the necessity of buffers between clusters of identical
  # treatment groups)
  assignment_vector <- c(rep(1, 49), rep(2, 49), rep(3, 49))
  assignment_vector <- sample(assignment_vector, length(assignment_vector))
  # Add to it in case we have more than 3*48 clusters
  part2 <- sample(1:3, size = 1000000 - length(assignment_vector), replace = TRUE)
  assignment_vector <- c(assignment_vector, part2) # this is now unnecessarily long, but at least has perfect uniform distribution for the first 144 elements, which is needed
  
  done <- FALSE
  cluster_counter <- 1
  poly_list <- complete_clusters <- list()
  next_hamlet_id <- polys <-  NULL
  while(!done){
    message('Cluster number: ', cluster_counter)
    # Get a starting point
    if(is.null(next_hamlet_id)){
      if(start_at_hq){
        # Start at the nearest hamlet to HQ
        next_hamlet_id <- which.min(hq_distance)[1]
      } else {
        # Just randomly pick a start point
        next_hamlet_id <- sample(1:nrow(xdf_sp), 1)
      }
      
    }
    this_cluster_sp <- this_hamlet_sp <- xdf_sp[next_hamlet_id,]
    this_hamlet_id <- this_hamlet_sp@data$id
    xdf$assigned[xdf$id == this_hamlet_id] <- TRUE
    xdf$cluster[xdf$id == this_hamlet_id] <- cluster_counter
    # See if it's sufficient
    this_cluster <- this_cluster_sp@data
    eval(parse(text = suffiency_text))
    is_sufficient <- this_cluster$is_sufficient
    # Turn the cluster into a convex
    radius <- 0.0000001
    cluster_convex <- SpatialPolygonsDataFrame(Sr = gConvexHull(spgeom = gBuffer(this_cluster_sp, width = radius)), 
                                               data = data.frame(cluster = cluster_counter))
    if(is_sufficient){
      message('---sufficient with just one hamlet')
    }
    # If not sufficient, get nearby hamlets
    hamlet_counter <- 2
    done_with_overlap_test <- FALSE
    while(!is_sufficient & !done){
      message('---adding household ', hamlet_counter)
      the_distances <- rgeos::gDistance(spgeom1 = cluster_convex,
                                        spgeom2 = xdf_sp, byid = TRUE)
      the_distances <- as.numeric(unlist(the_distances))
      the_distances <- data.frame(distance = the_distances,
                                  id = xdf$id,
                                  assigned = xdf$assigned)
      # Identify the closest, not yet assigned hamlet
      closest <- the_distances %>%
        filter(id != this_hamlet_id,
               !assigned,
               distance < 10000) %>% # 10k cut-off
        arrange(distance)
      done_with_overlap_test <- FALSE
      if(nrow(closest) == 0){
        done_with_overlap_test <- TRUE
      }
      this_hamlet_id <- closest$id[1]
      
      # Try adding the closest hamlet to the current cluster and see if it creates an overlap
      if(!is.null(polys) & !done_with_overlap_test){ # on the first round, this will be skipped
        this_cluster_sp <- xdf_sp[xdf$cluster == cluster_counter | xdf$id == this_hamlet_id,]
        has_overlap <- gOverlaps(spgeom1 = gConvexHull(spgeom = gBuffer(this_cluster_sp, width = radius)), # this used to be 300
                                 spgeom2 = polys)
        # If it has overlap, remove the hamlet and question and try another one
        while(has_overlap & !done_with_overlap_test){
          if(nrow(closest) > 1){
            closest <- closest[2:nrow(closest),]
            this_hamlet_id <- closest$id[1]
            this_cluster_sp <- xdf_sp[xdf$cluster == cluster_counter | xdf$id == this_hamlet_id,]
            has_overlap <- gIntersects(spgeom1 = gConvexHull(spgeom = gBuffer(this_cluster_sp, width = 300)),
                                     spgeom2 = polys)
          } else {
            # No more hamlets to try. Need to mark this cluster as done, but incomplete 
            done_with_overlap_test <- TRUE
          }
        }
      }
      
      if(done_with_overlap_test){
        # This will be an incomplete cluster. Can't finish it without overlapping
        complete_clusters[[cluster_counter]] <- FALSE
        is_sufficient <- TRUE
      } else {
        # Add the closest hamlet to the current cluster
        xdf$assigned[xdf$id == this_hamlet_id] <- TRUE
        xdf$cluster[xdf$id == this_hamlet_id] <- cluster_counter
        this_cluster_sp <- xdf_sp[xdf$cluster == cluster_counter,]
        this_cluster <- this_cluster_sp@data
        eval(parse(text = suffiency_text))
        is_sufficient <- this_cluster$is_sufficient
        # Turn the cluster into a convex
        cluster_convex <- SpatialPolygonsDataFrame(Sr = gConvexHull(spgeom = gBuffer(this_cluster_sp, width = 300)), 
                                                   data = data.frame(cluster = cluster_counter))
        done <- all(xdf$assigned)
        hamlet_counter <-hamlet_counter + 1
      }
    }
    # Now is sufficient. So, save polygons, record sufficiency, and bump up cluster counter
    poly_list[[cluster_counter]] <- cluster_convex
    if(is_sufficient & !done_with_overlap_test){complete_clusters[[cluster_counter]] <- TRUE} else { complete_clusters[[cluster_counter]] <- FALSE}
    cluster_counter <- cluster_counter + 1
    # See if we're done. 
    done <- all(xdf$assigned)
    # If not done, get the next starting point (ie, a point away from all previous clusters with a different assignment)
    if(!done){
      # Identify the nearest hamlet which is at least 2km from any poly with a different assignment group
      this_assignment_group <- assignment_vector[cluster_counter]
      # Identify already filled polygons and get their assignment groups and keep only those with DIFFERENT assignment groups
      polys <- do.call('rbind', poly_list)
      polys@data$assignment_group <- assignment_vector[1:nrow(polys@data)]
      polys <- polys[polys@data$assignment_group != this_assignment_group,]
      # if there are not any areas of a different assignment group, then we can
      # just get the nearest point to the most recent cluster
      if(nrow(polys@data) == 0){
        the_distances <- rgeos::gDistance(spgeom1 = cluster_convex,
                                          spgeom2 = xdf_sp, byid = TRUE)
        the_distances <- as.numeric(unlist(the_distances))
        the_distances <- data.frame(distance = the_distances,
                                    id = xdf$id,
                                    assigned = xdf$assigned)
        # Identify the closest, not yet assigned hamlet
        closest <- the_distances %>%
          filter(!assigned) %>%
          arrange(distance)
        next_hamlet_id <- closest$id[1]
      } else {
        # Get distance from the different assignment groups to the hamlets
        # first make polys one ID
        polys <- rgeos::gUnaryUnion(spgeom = polys)
        # give it a x km buffer
        polys <- rgeos::gBuffer(polys, width = km * 1000)
        the_distances <- rgeos::gDistance(spgeom1 = polys,
                                          spgeom2 = xdf_sp, byid = TRUE)
        the_distances <- as.numeric(unlist(the_distances))
        the_distances <- data.frame(distance = the_distances,
                                    id = xdf$id,
                                    assigned = xdf$assigned)
        # Identify the closest, not yet assigned hamlet
        closest <- the_distances %>%
          filter(!assigned,
                 distance > 0) %>%
          arrange(distance)
        next_hamlet_id <- closest$id[1]
      }
      # If there aren't any more hamlets to get, we're done
      if(is.na(next_hamlet_id)){
        done <- TRUE
      }
    }
  }
  # Done with clustering, combine all the spatial stuff
  polys <- do.call('rbind', poly_list)
  polys <- spTransform(polys, proj4string(shp))
  
  # Check about complete clusters
  complete_clusters <- unlist(complete_clusters)
  complete_clusters <- data.frame(cluster = 1:length(complete_clusters),
                                  complete_cluster = complete_clusters)
  
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
              # n_cattle = sum(n_cattle),
              # n_pigs = sum(n_pigs),
              # n_goats = sum(n_goats),
              # n_animals = sum(n_animals),
              n_children = sum(n_children))
  hamlet_xdf <- left_join(hamlet_xdf, cluster_xdf %>% dplyr::select(cluster, assignment_group, n_hamlets_in_cluster = n_hamlets))
  
  # Bring in complete cluster info
  polys@data <- left_join(polys@data, complete_clusters)
  hamlet_xdf <- left_join(hamlet_xdf, complete_clusters)
  cluster_xdf <- left_join(cluster_xdf, complete_clusters)
  polys@data <- left_join(polys@data, cluster_xdf)
  
  # Get a summary text
  summary_text <- paste0(
    1-nrow(cluster_xdf[cluster_xdf$complete_cluster,]), ' complete clusters were able to be formed with the given rules. ', 'These were made up of ',
    nrow(hamlet_xdf), ' hamlets, of which ',
    length(which(hamlet_xdf$cluster == 0)), ' fall into "buffer" areas. '
  ) 
  # Make a leaflet object
  cols <- rainbow(max(cluster_xdf$cluster) + 1)
  cols <- sample(cols, length(cols))
  cols[1] <- 'black'
  assignment_cols <- c('blue', 'red', 'green')
  map <- leaflet() %>%
    addProviderTiles(providers$Esri.WorldImagery) %>%
    addPolygons(data = shp, 
                stroke = TRUE,
                fillOpacity = 0,
                color = 'white') %>%
    addPolygons(data = polys,
                # fillColor = cols[2:length(cols)],
                fillColor = assignment_cols[polys@data$assignment_group],
                color = assignment_cols[polys@data$assignment_group],
                stroke = TRUE,
                fillOpacity = 0.2,
                popup = paste0('Cluster number: ', polys@data$cluster, '<br>',
                               polys@data$n_hamlets, ' hamlets:<br>',
                               polys@data$hamlet_codes))
  for(i in 1:nrow(hamlet_xdf)){
    this_row <- hamlet_xdf[i,]
    map <- map %>%
      addCircleMarkers(data = this_row,
                       radius = 5,
                       fillOpacity = 0.5,
                       stroke = FALSE,
                       color = assignment_cols[this_row$assignment_group],  #cols[this_row$cluster + 1],
                       popup = paste0(this_row$code, '<br>',
                                      ifelse(this_row$cluster > 0, paste0('Cluster number: ', this_row$cluster, ' (which has ', this_row$n_hamlets_in_cluster, ' hamlets).<br>Treatment assignment group (1-3): ', cluster_xdf$assignment_group), 'No cluster (buffer zone).'),
                                      '.<br>',
                                      this_row$n_cattle, ' cattle.',
                                      this_row$n_goats, ' goats. ',
                                      this_row$n_pigs, ' pigs. ',
                                      this_row$n_animals, ' animals.<br>',
                                      this_row$n_households, ' households. ',
                                      this_row$n_humans, ' humans. ', 
                                      this_row$n_children, ' children.'))
  }
  map <- map %>%
    addMarkers(data = hqll,
               popup = 'Headquarters')
     
  
  out_list <- list(summary_text,
                   map,
                   hamlet_xdf,
                   cluster_xdf)
  names(out_list) <- c('summary_text', 'map', 'hamlet_xdf', 'cluster_xdf')
  return(out_list)
}

