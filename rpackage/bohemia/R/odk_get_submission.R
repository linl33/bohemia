#' ODK get submission
#' 
#' Get the data from a particular submission
#' @param url The URL of the ODK Aggregate server, default being https://bohemia.systems, without a trailing dash
#' @param id The primary id of the form
#' @param id2 The secondary id of the form
#' @param uuid The uuid (including the "uuid:" prefix) of the particular submission to be retrieved
#' @param user The ODK Aggregate username
#' @param password The ODK Aggregate password
#' @import httr
#' @import xml2
#' @import dplyr
#' @return An xml of the submission's content
#' @export

odk_get_submission <- function(url = 'https://bohemia.systems',
                                 id = 'recon',
                                 id2 = NULL,
                                 uuid = NULL,
                                 user = NULL,
                                 password = NULL){
  
  # Ensure that username and password are provided
  if(is.null(user) | is.null(password)){
    stop('A user and password are required.')
  }
  
  # Ensure that a uuid is there
  if(is.null(uuid)){
    stop('A uuid argument is required')
  }
  
  # Message about handling of id2 if relevant
  if(is.null(id2)){
    message('The id2 argument is empty. Will use the id argument in both places when constructing the uri.')
    id2 <- id
  }
  
  # Create the url for the request
  # https://github.com/opendatakit/opendatakit/wiki/Briefcase-Aggregate-API#get-viewdownloadsubmission
  rurl <- paste0(url,
                 "/view/downloadSubmission?formId=",
                id,
                "%5B@version=null%20and%20@uiVersion=null%5D/",
                ifelse(id == 'census', 'data', id2),
                # id2, # this works for recon, but not for census
                # 'data', # this works for census (online converted) but not odk
                "%5B@key=",
                uuid,
                "%5D")
  r = GET(rurl,
          authenticate(user = user,
                       password = password, 
                       type = 'digest'))
  
  # Provide info on the request (and stop if error)
  stop_for_status(r) 
  warn_for_status(r)
  message_for_status(r)
  
  # Return the fetched submission
  return(r)
}

