#' Get location code
#' 
#' Get the unique 3 letter location given a location
#' @param country Country
#' @param region Region
#' @param district District
#' @param ward Ward
#' @param village Village
#' @param hamlet Hamlet
#' @param allow_all Allow the all option
#' @return A character vector of length 1 or a NULL object
#' @import dplyr
#' @export

get_location_code <- function(country = NULL,
                              region = NULL,
                              district = NULL,
                              ward = NULL,
                              village = NULL,
                              hamlet = NULL,
                              allow_all = FALSE){
  
  locs <- bohemia::locations
  
  # country = 'Tanzania'
  # region = 'Pwani'
  # district = 'Kibiti DC'
  # ward = 'All'   #'Bungu'
  # village = 'Bungu A'
  # hamlet = 'Mkundi'
  # allow_all = T
  
  # Some adjustment for alls/nulls
  if(!is.null(country)){
    if(country == 'All'){
      region <- district <- ward <- village <- hamlet <- NULL
    }
  }
  if(!is.null(region)){
    if(region == 'All'){
      district <- ward <- village <- hamlet <- NULL
    }
  }
  if(!is.null(district)){
    if(district == 'All'){
      ward <- village <- hamlet <- NULL
    }
  }
  if(!is.null(ward)){
    if(ward == 'All'){
      village <- hamlet <- NULL
    }
  }
  if(!is.null(village)){
    if(village == 'All'){
      hamlet <- NULL
    }
  }
  
  if(allow_all){
    out <- locs
    if(is.null(country)){
      out <- out
    } else if(is.null(region)){
      if(country != 'All'){
        out <- out %>% filter(Country == country)
      }
    } else if(is.null(district)){
      out <- out %>% filter(Country == country)
      if(region != 'All'){
        out <- out %>% filter(Region == region)
      }
    } else if(is.null(ward)){
      out <- out %>% filter(Country == country,
                            Region == region)
      if(district != 'All'){
        out <- out %>% filter(District == district)
      }
      
    } else if(is.null(village)){
      out <- out %>% filter(Country == country,
                            Region == region,
                            District == district)
      if(ward != 'All'){
        out <- out %>% filter(Ward == ward)
      }
    } else if(is.null(hamlet)){
      out <- out %>% filter(Country == country,
                            Region == region,
                            District == district,
                            Ward == ward)
      if(village != 'All'){
        out <- out %>% filter(Village == village)
      }
    } else {
      if(hamlet == 'All'){
        out <- out <- out %>%
          filter(Country == country,
                 Region == region,
                 District == district,
                 Ward == ward,
                 Village == village)
      } else {
        out <- out %>%
          filter(Country == country,
                 Region == region,
                 District == district,
                 Ward == ward,
                 Village == village,
                 Hamlet == hamlet)
      }
    }
    if(nrow(out) == 0){
      out <- NULL
    } else {
      out <- out$code
    }
    
    return(out)
  } else {
    if(is.null(country) |
       is.null(region) |
       is.null(district) |
       is.null(ward) |
       is.null(village) |
       is.null(hamlet)){
      return(NULL)
    }
    
    out <- locs %>%
      filter(Country == country,
             Region == region,
             District == district,
             Ward == ward,
             Village == village,
             Hamlet == hamlet)
    
    if(nrow(out) == 1){
      out <- out$code
      return(out)
    }
    if(nrow(out) > 1){
      warning('More than 1 location code matches the parameters. Returning NULL')
      return(NULL)
    }
    if(nrow(out) < 1){
      warning('No location code found for the parameters. Returning NULL')
      return(NULL)
    }
  }


  
  
}