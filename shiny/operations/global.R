library(leaflet)
library(sp)
# library(leaflet.providers)
library(leaflet.extras)
library(bohemia)

# rdir <- '../../rpackage/bohemia/R/'
# funs <- dir(rdir)
# for(i in 1:length(funs)){
#   source(paste0(rdir, funs[i]))
# }

# at the time of writing, version 1.8.0
# pd <- providers_default()


## Retrieve data using bohemia package
# mopeia2 <- bohemia::mopeia2
# rufiji2 <- bohemia::rufiji2
# mopeia_health_facilities <- bohemia::mopeia_health_facilities
# rufiji_health_facilities <- bohemia::rufiji_health_facilities
# locations <- bohemia::locations
# save(locations, file = 'data/locations.RData')
# save(mopeia2, file = 'data/mopeia2.rda')
# save(rufiji2, file = 'data/rufiji2.rda')
# save(mopeia_health_facilities, file = 'data/mopeia_health_facilities.rda')
# save(rufiji_health_facilities, file = 'data/rufiji_health_facilities.rda')

# load('data/mopeia2.rda')
# load('data/rufiji2.rda')
# load('data/mopeia_health_facilities.rda')
# load('data/rufiji_health_facilities.rda')
# load('data/locations.RData')
# load('data/mopeia_hamlets.RData')
# load('data/rufiji_hamlets.RData')
# # Load the location hierarchy
# if(!'locations.RData' %in% dir('data')){
#   locations <- bohemia::locations
#   save(locations, file = 'data/locations.RData')
# } else {
#   load('data/locations.RData')
# }
# 
# # Load the spatial data
# 
# # Mopeia (needs cleaning up)
# if(!'mopeia_hamlets.RData' %in% dir('data')){
#   mopeia_hamlets <- bohemia::mopeia_hamlets
#   save(mopeia_hamlets, file = 'data/mopeia_hamlets.RData')
# } else {
#   load('data/mopeia_hamlets.RData')
# }
# 
# # Rufiji (doesn't yet exist!)
# if(!'rufiji_hamlets.RData' %in% dir('data')){
#   # rufiji_hamlets <- bohemia::rufiji_hamlets
#   rufiji_hamlets <- bohemia::rufiji3
#   save(rufiji_hamlets, file = 'data/rufiji_hamlets.RData')
# } else {
#   load('data/rufiji_hamlets.RData')
# }
rufiji_hamlets <- bohemia::rufiji3
rufiji_hamlets@data$village <- rufiji_hamlets@data$NAME_3
rufiji_hamlets@data$population <- 'Unknown'

# Define function for filtering locations based on inputs
filter_locations <- function(locations,
                             country = NULL,
                             region = NULL,
                             district = NULL,
                             ward = NULL,
                             village = NULL,
                             hamlet = NULL){
  out <- locations
  if(!is.null(country)){
    if(country != ''){
      out <- out %>% filter(Country %in% country) 
    }
  }
  if(!is.null(region)){
    if(region != ''){
      out <- out %>% filter(Region %in% region)
    }
  }
  if(!is.null(district)){
    if(district != ''){
      out <- out %>% filter(District %in% district)
    }
  }
  if(!is.null(ward)){
    if(ward != ''){
      out <- out %>% filter(Ward %in% ward) 
    }
  }
  if(!is.null(village)){
    if(village != ''){
      out <- out %>% filter(Village %in% village)
    }
  }
  if(!is.null(hamlet)){
    if(hamlet != ''){
      out <- out %>% filter(Hamlet %in% hamlet) 
    }
    
  }
  return(out)
}

# add_nothing <- function(x){c('', x)}
add_nothing <- function(x){x}
