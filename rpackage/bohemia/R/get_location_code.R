#' Get location code
#' 
#' Get the unique 3 letter location given a location
#' @param country Country
#' @param region Region
#' @param district District
#' @param ward Ward
#' @param village Village
#' @param hamlet Hamlet
#' @return A character vector of length 1 or a NULL object
#' @import dplyr
#' @export

get_location_code <- function(country,
                              region,
                              district,
                              ward,
                              village,
                              hamlet){
  
  locs <- bohemia::locations
  
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