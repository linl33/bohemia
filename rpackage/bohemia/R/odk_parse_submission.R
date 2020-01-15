#' ODK parse submission
#' 
#' Convert the xml data from an ODK form submission to a dataframe
#' @param xml
#' @import httr
#' @import xml2
#' @import dplyr
#' @return A character vector of length 1 with the uuids (including the prefix "uuid:") of the submitted forms
#' @export
#' @examples
#' # Get a list of forms
#' fl <- odk_list_forms()
# # Keep only the one named "Recon"
#' recon <- fl %>% filter(name == 'Recon')
#' # Capture its secondary idea (slow)
#' id2 <- odk_get_secondary_id(id = recon$id)
#' # Get a list of the submissions for the form in question
#' submissions <- odk_list_submissions(url = 'https://bohemia.systems', id = 'recon', user = 'data', password = 'data')
#' # Capture an individual submission
#' submission <- odk_get_submission(url = 'https://bohemia.systems', id = recon$id, id2 = id2, uuid = submissions[1], user = 'data', password = 'data')
#' # Parse the submission into R format
#' odk_parse_submission(xml = submission)


odk_parse_submission <- function(xml){

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


