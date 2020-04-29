#' Post traccar data
#'
#' Upload data to your traccar server
#' @param user The username for your traccar database
#' @param pass The password for your traccar database
#' @param name The name of the individual you are adding to your traccar server
#' @param unique_id The id of the individual you are adding to your traccar server
#' @param url The url of your traccar server
#' @return A dataframe
#' @export
#' @import dplyr
#' @import httr

post_traccar_data <- function(user,
                             pass,
                             name,
                             unique_id,
                             url){
  
  # Combine the name and number
  combined_name <- paste0(unique_id, '. ', name)
  path <- 'api/devices'
  r <- POST(url = url, authenticate(user, pass),
            path = path,
            body = list(name=combined_name, uniqueId = unique_id),
            encode = 'json')
  if(r$status_code == 200){
    message('Status code is 200, successful')
  } else {
    message('Status code is ', r$status_code, ' unsuccessful (likely because worker already added)')
  }

}
