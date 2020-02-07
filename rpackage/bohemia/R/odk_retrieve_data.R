#' ODK retrieve data
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
#' @import httr
#' @import xml2
#' @import dplyr
#' @return A list of dataframes
#' @export


odk_retrieve_data <- function(url = 'https://bohemia.systems',
                              id = 'recon',
                              id2 = NULL,
                              unknown_id2 = FALSE,
                              uuids = NULL,
                              exclude_uuids = NULL,
                              user = NULL,
                              password = NULL){
  
  # Ensure that username and password are provided
  if(is.null(user) | is.null(password)){
    stop('A user and password are required.')
  }
  
  # Get the forms available at the url given
  message('---Fetching the forms list at ', url)
  fl <- odk_list_forms(url = url)
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
  submissions <- odk_list_submissions(url = 'https://bohemia.systems',
                                      id = id,
                                      user = user,
                                      password = password)
  # If no submissions, stop
  if(length(submissions) == 0){
    message('No submissions are available for the form with id: ', id, ' at ', url, '.\nReturning an empty vector')
    return(c())
  }
  
  # If there are submissions, we need to conform them to the list of given uuids and exclude_uuids

  #' # Get a list of the submissions for the form in question
  #' 
  #' # Capture an individual submission
  #' submission <- odk_get_submission(url = 'https://bohemia.systems', id = recon$id, id2 = id2, uuid = submissions[1], user = 'data', password = 'data')
  #' # Parse the submission into R format
  #' odk_parse_submission(xml = submission)
  
  # Get the content
  contingut <- content(xml)

  # Ensure that it is indeed a submission
  xname <- xml_name(contingut)
  if(xname != 'submission'){
    stop('Something went wrong. Tried to fetch a submission, but instead got ', xname)
  }
  
  # Get down to the data node
  xnen <- xml_child(contingut)
  xdata <- xml_children(xnen)
  child <- xml_children(xdata)
  children <- xml_children(child)
  
  # Get the names and values
  keys <- xml_name(children)
  values <- xml_text(children)
  
  # Combine into a dataframe
  df <- tibble(key = keys,
               value = values)
  
  # Return the dataframe
  return(df)
  
  
  # # Define function to loop through xml children and extract content
  # xloop <- function(child){
  #   out_list <- list()
  #   for(i in 1:length(child)){
  #     this_sub_child <- xml_child(child[i])
  #     has_children <- length(xml_children(this_sub_child)) > 0
  #     if(has_children){
  #       message('More!')
  #       x <- xloop(this_sub_child)
  #       counter <- length(out_list) + 1
  #       out_list[[counter]] <- x
  #     } else {
  #       message('No more, here it is:')
  #       the_name <- xml_name(this_sub_child)
  #       the_value <- xml_text(this_sub_child)
  #       message('---', the_name)
  #       message('---', the_value)
  #       df <- tibble(key = the_name,
  #                    value = the_value)
  #       counter <- length(out_list) +1
  #       out_list[[counter]] <- df
  #     }
  #   }
  #   out <- bind_rows(out_list)
  #   return(out)
  # }
  # 
  # # Run and return
  # out <- xloop(child)
  # return(out)
}


