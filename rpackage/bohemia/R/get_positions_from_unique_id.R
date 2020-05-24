#' Get device id from unique id
#'
#' Retrieve device id from api/devices using unique id
#' @param user The username for your traccar api
#' @param pass The password for your traccar api
#' @param url The url of your traccar api
#' @param path API path
#' @param unique_id The unique id 
#' @return A dataframe
#' @export
#' @import dplyr
#' @import httr
#' @import tidyverse
#' @import yaml
get_device_id_from_unique_id <- function(url, 
                                         user, 
                                         pass, 
                                         unique_id,
                                         path = 'api/devices'){
  path <- paste0(path, '?', 'uniqueId=', unique_id)
  r <- GET(url = url, 
           path = path, 
           authenticate(user, pass))
  out <- as.character(content(r)[[1]]$id)
  return(out)
}

#' Get positions from device id
#'
#' Retrieve positions from api/positions using device_id
#' @param user The username for your traccar api
#' @param pass The password for your traccar api
#' @param url The url of your traccar api
#' @param path API path
#' @param device_id The id for a registered HCW on the traccar api
#' @return A dataframe
#' @export
#' @import dplyr
#' @import httr
#' @import tidyverse
#' @import yaml
get_positions_from_device_id <- function(url, 
                                         user, 
                                         pass, 
                                         device_id, 
                                         path = 'api/positions?from=2010-01-01T22%3A00%3A00Z&to=2020-12-31T22%3A00%3A00Z'){
  # add id to path
  path <- paste0(path, '&', 'deviceId=', device_id)
  r <- GET(url = url, 
           path = path, 
           authenticate(user, pass), 
           accept('text/csv'))
  
  out = read_delim(r$content, delim =';')
  
  return(out)
}

#' Get positions from unique id
#'
#' Retrieve positions using a unique id
#' @param user The username for your traccar api
#' @param pass The password for your traccar api
#' @param url The url of your traccar api
#' @param unique_id The unique id for a regestered HCW on the traccar api
#' @return A dataframe
#' @export
#' @import dplyr
#' @import httr
#' @import tidyverse
#' @import yaml
#' @import readr
get_positions_from_unique_id <- function(url, 
                                         user, 
                                         pass, 
                                         unique_id){
  
  # first fetch device_id 
  device_id <- get_device_id_from_unique_id(url = url,
                               user = user,
                               pass = pass,
                               unique_id = unique_id)
  # fetch positions
  out <- get_positions_from_device_id(url = url,
                                      user = user,
                                      pass = pass,
                                      device_id =device_id)
  return(out)
  
}
