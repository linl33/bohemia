#' ODK get data
#' 
#' Retrieve data from the ODK server, parse, organize, and return as dataframes
#' @param url The URL of the ODK Aggregate server, default being https://bohemia.systems, without a trailing dash
#' @param id The primary id of the form
#' @param id2 The secondary id of the form
#' @param unknown_id2 Set to TRUE only if the id2 is unknown. If it is known to be the same as id, set to FALSE. If it is known to be different from id, and is known, set to FALSE and make the id2 argument non-null.
#' @param uuids The uuid(s) (including the "uuid:" prefix) of the particular submission(s) to be retrieved. If NULL (the default), all uuids available will be retrieved
#' @param exclude_uuids The uuid(s) to exclude from retrieval. If NULL (the default), no uuids will be excluded
#' @param user The ODK Aggregate username
#' @param password The ODK Aggregate password
#' @param widen Whether to widen
#' @import httr
#' @import xml2
#' @import dplyr
#' @return A list of dataframes
#' @export


odk_get_data <- function(url = 'https://bohemia.systems',
                              id = 'recon',
                              id2 = NULL,
                              unknown_id2 = FALSE,
                              uuids = NULL,
                              exclude_uuids = NULL,
                              user = NULL,
                              password = NULL,
                              widen = TRUE){
  
  # Ensure that username and password are provided
  if(is.null(user) | is.null(password)){
    stop('A user and password are required.')
  }
  
  # Get the forms available at the url given
  message('---Fetching the forms list at ', url)
  fl <- odk_list_forms(url = url, user = user, password = password)
  # If the requested id is not available, stop
  if(!id %in% fl$id){
    message('The form with id "', id, '" is not listed at ', url, '.\nThe listed form ids are:\n')
    message(paste0(paste('-', fl$id), collapse = '\n'))
    stop('Try again with one of the above ids, or a different url.')
  }
  
  # Get the id2 if needed
  if(unknown_id2){
    message('---Fetching the secondary id for ', id)
    id2 <- odk_get_secondary_id(id = id)
  } else if(is.null(id2)){
    id2 <- id
  }
  
  # Get the list of submissions
  submissions <- odk_list_submissions(url = url,
                                      id = id,
                                      user = user,
                                      password = password)
  # If no submissions, stop
  if(length(submissions) == 0){
    message('No submissions are available for the form with id: ', id, ' at ', url, '.\nReturning an empty vector')
    return(c())
  } 
  
  # If there are submissions, we need to conform them to the list of given uuids and exclude_uuids
  if(!is.null(uuids)){
    submissions <- submissions[submissions %in% uuids]
  }
  # If no remaining submissions, stop
  if(length(submissions) == 0){
    message('After filtering the uuids to keep only those supplied in the uuids argument, there were none remaining.\nConsider re-running with the uuids argument set to NULL.\nReturning an empty vector...')
    return(c())
  } 
  if(!is.null(exclude_uuids)){
    submissions <- submissions[!submissions %in% exclude_uuids]
  }
  if(length(submissions) == 0){
    message('After filtering the uuids to remove those in the exclude_uuids argument, there were no remaining submissions. Consider re-running with the exclude_uuids argument set to NULL.\nReturning an empty vector...')
    return(c())
  } 
  
  # Now loop through each uuid and get the data
  data_list <- list()
  for(i in 1:length(submissions)){
    Sys.sleep(0.15)
    message('| Working on retrieving submission ', i, ' of ', length(submissions))
    this_uuid <- submissions[i]
    # Capture the data for this uuid
    submission <- odk_get_submission(url = url, 
                                     id = id,
                                     id2 = id2,
                                     uuid = this_uuid, 
                                     user = user, 
                                     password = password)
    # Parse the submission into R format
    parsed <- odk_parse_submission(xml = submission)
   
    # Pop reformatted data into list
    data_list[[i]] <- parsed
  }
  
  # Combine all of the data into respective dataframes
  repeats <- bind_rows(lapply(data_list, function(x){x$repeats}))
  non_repeats <- bind_rows(lapply(data_list, function(x){x$non_repeats}))
  # Combine into one list
  combined <- list()
  combined$repeats <- repeats
  combined$non_repeats <- non_repeats
  
  # Widen
  if(widen){
    combined <- odk_make_wide(long_list = combined)
  }
  
  # Return
  return(combined)
  
}


