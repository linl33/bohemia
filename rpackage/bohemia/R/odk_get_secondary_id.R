#' ODK get secondary ID
#' 
#' Get the secondary ID of an ODK form list from an aggregate server. This is useful in the rare case that the xls used to generate the xml was not named identically to the \code{formId}. The secondary ID is used for inserting into a \code{downloadSubmission} http request (see \code{odk_get_submission})
#' @param url The URL of the ODK Aggregate server, default being https://bohemia.systems, without a trailing dash
#' @param id The primary id fo the form
#' @import httr
#' @import xml2
#' @import dplyr
#' @return A character vector of length 1
#' @export

odk_get_secondary_id <- function(url = 'https://bohemia.systems',
                                 id = 'recon'){
  
  # Create the url for the request
  rurl <- paste0(url, '/formXml?formId=', id)

  # Carry out the GET request
  r <- GET(rurl)
  
  # Provide info on the request (and stop if error)
  stop_for_status(r) 
  warn_for_status(r)
  message_for_status(r)
  
  # Define the content of the return page
  contingut <- content(r)
  
  # Ensure that we have indeed retrieved forms 
  xname <- xml_name(contingut)
  if(xname != 'html'){
    stop('Something went wrong. Tried to fetch html, but instead got ', xname)
  }
  
  # Get the content, unlist, and pull out the secondary id
  # (there is almost certainly a faster way to do this, using nodes rather than the 
  # slow unlist function, but this works, albeit slowly)
  xnens <- xml_children(contingut)
  a <- as_list(xnens[1])
  b <- a[[1]]$model$instance
  id2 <- names(b)
  
  # Return the id
  return(id2)
}

