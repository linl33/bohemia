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
#' # # Keep only the one named "Recon"
#' recon <- fl %>% filter(name == 'Recon')
#' # Capture its secondary idea (slow)
#' id2 <- odk_get_secondary_id(id = recon$id)
#' # Get a list of the submissions for the form in question
#' submissions <- odk_list_submissions(url = 'https://bohemia.systems', id = 'recon', user = 'data', password = 'data')
#' # Capture an individual submission
#' submission <- odk_get_submission(url = 'https://bohemia.systems', id = recon$id, id2 = id2, uuid = submissions[1], user = 'data', password = 'data')
#' #' # Parse the submission into R format
#' #' odk_parse_submission(xml = submission)


odk_parse_submission <- function(xml){
  
  # Define helper functions
  name_clean <- function(x){
    out <- strsplit(x, split = '.', fixed = TRUE)
    out <- unlist(lapply(out, function(z){
      z[length(z)]
    }
    ))
    return(out)
  }
  extract_repeat_name <- function(x){
    out <- strsplit(x, split = '.', fixed = TRUE)
    out <- unlist(lapply(out, function(z){
      z[grepl('repeat', z)][1]
    }
    ))
    return(out)
  }
  get_repeat_count <- function(x){
    data.frame(key = x) %>%
      mutate(dummy = 1) %>%
      group_by(key) %>%
        mutate(cs = cumsum(dummy)) %>%
      .$cs
  }

  # Get the content
  contingut <- content(xml)

  # Ensure that it is indeed a submission
  xname <- xml_name(contingut)
  
  if(xname != 'submission'){
    stop('Something went wrong. Tried to fetch a submission, but instead got ', xname)
  }
  
  # Define helper function for getting children, grandchildren, etc.
  descend <- function(x){
    counter <- 0
    out <- xml_children(x)
  }
  
  # Get down to the data node
  xnen <- xml_child(contingut)
  # Get the data (one node for each group / repeat, etc.)
  xdata <- xml_children(xnen)
  
  # Experimental
  xlist <- as_list(xdata)
  xunlist <- unlist(xlist)
  # extract results
  values <- xunlist
  keys <- names(xunlist)
  out <- tibble(key = keys,
                value = values)
  # Define which are repeats (need to do this before cleaning names)
  repeats <- grepl('repeat', names(xunlist))

  # For repeats, go through and get in separate df
  out_repeats <- out[repeats,]
  out_non_repeats <- out[!repeats,]
  
  # For the repeats, extract the repeat name
  if(nrow(out_repeats) > 0){
    out_repeats$repeat_name <- extract_repeat_name(out_repeats$key)
    # Clean name
    out_repeats$key <- name_clean(out_repeats$key)
    # Get a repeat id
    out_repeats$repeated_id <- get_repeat_count(out_repeats$key)
  }
  # For the non repeats, just clean up the name by removing the group prefix
  if(nrow(out_non_repeats) > 0){
    out_non_repeats$key <- name_clean(out_non_repeats$key)
  }
  
  # Return a list of dataframes (the repeats and non-repeats)
  out <- list(non_repeats = out_non_repeats,
              repeats = out_repeats)
  return(out)
}


