#' List the forms on an ODK server
#' 
#' List the forms on an ODK server
#' @param url The URL of the ODK Aggregate server, default being https://bohemia.systems, without a trailing dash
#' @import httr
#' @import xml2
#' @import dplyr
#' @return A tibble with columns name, id, and url
#' @export

odk_list_forms <- function(url = 'https://bohemia.systems'){
  
  # Create the url for the forms list
  fl_url <- paste0(url, '/formList')
  
  # Carry out the GET request
  r <- GET(fl_url)
  
  # Provide info on the request (and stop if error)
  stop_for_status(r) 
  warn_for_status(r)
  message_for_status(r)
  
  # Define the content of the return page
  contingut <- content(r)
  
  # Ensure that we have indeed retrieved forms 
  xname <- xml_name(contingut)
  if(xname != 'forms'){
    stop('Something went wrong. Tried to fetch forms, but instead got ', xname)
  }
  
  # Get the form list nodeset
  xnens <- xml_children(contingut)
  
  # Get the names of the forms
  form_names <- xml_text(xnens)

  # Get the urls
  urls <- xml_attr(xnens, 'url')
  
  # Get the form ids
  get_id <- function(x){
    out <- strsplit(x, 'formId=', fixed = TRUE)
    out <- lapply(out, function(z){
      z[2]
    })
    out <- unlist(out)
    return(out)
  }
  ids <- get_id(urls)
  
  # Combine it all into a dataframe and return
  out <- tibble(name = form_names,
                id = ids,
                url = urls)
  return(out)
}

