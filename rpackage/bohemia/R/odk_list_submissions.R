#' ODK list submissions
#' 
#' Get a list of the submissions of a particular form ID to a particular server
#' @param url The URL of the ODK Aggregate server, default being https://bohemia.systems, without a trailing dash
#' @param id The primary id fo the form
#' @param user The ODK Aggregate username
#' @param password The ODK Aggregate password
#' @param pre-auth Pre-authenticate (needed for Manhica server)
#' @import httr
#' @import xml2
#' @import dplyr
#' @return A character vector of length 1 with the uuids (including the prefix "uuid:") of the submitted forms
#' @export

odk_list_submissions <- function(url = 'https://bohemia.systems',
                                 id = 'recon',
                                 user = NULL,
                                 password = NULL,
                                 pre_auth = FALSE){
  
  # Ensure that username and password are provided
  if(is.null(user) | is.null(password)){
    stop('A user and password are required.')
  }
  
  # authenticate
  if(pre_auth){
    auth_url <- paste0(url, '/local_login.html?redirect=formList')
    r <- POST(auth_url,
              authenticate(user = user,
                           password = password,
                           type = 'basic'))
  }
  
  # Create the url for the request
  rurl <- paste0(url, '/view/submissionList?formId=', id, '&numEntries=1000')
  r = GET(rurl,
          authenticate(user = user,
                       password = password, 
                       type = 'digest'))
  
  
  # Provide info on the request (and stop if error)
  stop_for_status(r) 
  warn_for_status(r)
  message_for_status(r)
  
  # Define sub-function for getting values from response
  vr <- function(r){
    # Define the content of the return page
    contingut <- content(r)
    
    # Get the cursor section
    cursor_section <- xml_text(xml_children(contingut))[2]
    cursor_date  <- stringr::str_extract(cursor_section, "<attributeValue>(.+)</attributeValue>")
    cursor_date <- gsub('<attributeValue>', '', cursor_date, fixed = TRUE)
    cursor_date <- gsub('</attributeValue>', '', cursor_date, fixed = TRUE)
    cursor_date <- lubridate::as_datetime(cursor_date, tz = 'UTC')
    cursor_date <- as.character(cursor_date)
    cursor_date <- gsub(' ', 'T', cursor_date)
    cursor_date <- paste0(cursor_date, 'Z')
    # Get actual form lists
    xname <- xml_name(contingut)
    if(xname != 'idChunk'){
      stop('Something went wrong. Tried to fetch idChunk, but instead got ', xname)
    }
    
    # Get the uuids
    xnens <- xml_children(contingut)
    xuuids <- xml_children(xnens)
    uuids <- xml_text(xuuids)
    
    # Return a list of values and cursor
    done <- list()
    done[[1]] <- uuids
    done[[2]] <- cursor_date
    names(done) <- c('uuids', 'cursor_date')
    return(done)
  }
  
  # Get uuids and cursor date from response
  uuids_list <- c()
  vrx <- vr(r)
  uuids_list <- c(uuids_list, vrx$uuids)
  current_cursor_date <- vrx$cursor_date
  
  # Now go through and re-retrieve in chunks of 1000
  keep_going <- TRUE
  if(length(uuids_list) < 1000){
    keep_going <- FALSE
  }
  counter <- 1000
  while(keep_going){
    message('Working on numbers ', counter, ' to ', counter + 999)
    new_rurl <- paste0(rurl, '&cursor=', 
                       "<cursor xmlns=\"http://www.opendatakit.org/cursor\"><attributeName>_LAST_UPDATE_DATE</attributeName><attributeValue>", current_cursor_date, 
                       '</attributeValue><isForwardCursor>true</isForwardCursor></cursor>', collapse = '')
    new_rurl <- parse_url(new_rurl)
    rx = GET(new_rurl,
             authenticate(user = user,
                          password = password, 
                          type = 'digest'))
    vrx <- vr(rx)
    new_cursor_date <- vrx$cursor_date
    if(new_cursor_date == current_cursor_date){
      keep_going <- FALSE
    } else {
      uuids_list <- c(uuids_list, vrx$uuids)
      current_cursor_date <- vrx$cursor_date
      counter <- counter + 1000
    }
  }
  
  # Remove any duplicates
  original_length <- length(uuids_list)
  uuids_list <- unique(uuids_list)
  new_length <- length(uuids_list)
  if(original_length != new_length){
    message('Duplicates. Reduced list of uuids from ', original_length, ' to ', new_length)
  }
  
  # Return the uuids
  return(uuids_list)
}

