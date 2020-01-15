#' ODK list submissions
#' 
#' Get a list of the submissions of a particular form ID to a particular server
#' @param url The URL of the ODK Aggregate server, default being https://bohemia.systems, without a trailing dash
#' @param id The primary id fo the form
#' @param user The ODK Aggregate username
#' @param password The ODK Aggregate password
#' @import httr
#' @import xml2
#' @import dplyr
#' @return A character vector of length 1 with the uuids (including the prefix "uuid:") of the submitted forms
#' @export

odk_list_submissions <- function(url = 'https://bohemia.systems',
                                 id = 'recon',
                                 user = NULL,
                                 password = NULL){
  
  # Ensure that username and password are provided
  if(is.null(user) | is.null(password)){
    stop('A user and password are required.')
  }
  
  # Create the url for the request
  rurl <- paste0(url, '/view/submissionList?formId=', id)
  url3 = 'https://bohemia.systems/view/submissionList?formId=recon'
  r = GET(rurl,
          authenticate(user = user,
                       password = password, 
                       type = 'digest'))
  
  # Provide info on the request (and stop if error)
  stop_for_status(r) 
  warn_for_status(r)
  message_for_status(r)
  
  # Define the content of the return page
  contingut <- content(r)
  
  # Ensure that we have indeed retrieved uuids 
  xname <- xml_name(contingut)
  if(xname != 'idChunk'){
    stop('Something went wrong. Tried to fetch idChunk, but instead got ', xname)
  }
  
  # Get the uuids
  xnens <- xml_children(contingut)
  xuuids <- xml_children(xnens)
  uuids <- xml_text(xuuids)

  # Return the uuids
  return(uuids)
}

