#' Get traccar data
#'
#' Retrieve data from your traccar server
#' @param user The username for your traccar database
#' @param password The password for your traccar database
#' @param url The url of your traccar server
#' @param path API path
#' @return A dataframe
#' @export
#' @import dplyr
#' @import httr
#' @import tidyr

get_traccar_data <- function(url, user, pass, path = 'api/devices/'){
  r <- GET(url = url, path = path, authenticate(user, pass))
  output <- content(r)
  values <- unlist(output)
  keys <- names(values)
  out <- tibble(key = keys, value = values)
  out$group_id <- NA
  for(i in 1:nrow(out)){
    counter <- i
    this_row <- out[counter,]
    key <- this_row$key
    while(key != 'id'){
      counter <- counter - 1
      this_row <- out[counter,]
      key <- this_row$key
    }
    out$group_id[i] <- this_row$value
  }

  final <- out %>% spread(key = key, value = value) %>%
    mutate(id = as.numeric(id)) %>% dplyr::select(-group_id) %>%
    arrange(id)

  return(final)
}
