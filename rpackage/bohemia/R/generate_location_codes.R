#' Generate location codes
#' 
#' Generate unique 3 letter location given a locations hierarchy
#' @param locations A dataframe in the format of the locations hierarchy (ie, the bohemia::locations object, with the following 6 columns: Country, region, District, Ward, Village, Hamlet)
#' @return A dataframe in the input format, but with an additional "code" column, and columns indicating the degrees of change required
#' @import dplyr
#' @export

generate_location_codes <- function(locations){
  out <- locations
  clean_up <- function(x){
    gsub("'", "", gsub('-', '', gsub('/', '', gsub(' ', '', x), fixed = TRUE), fixed = TRUE), fixed = TRUE)
  }
  first_try <- substr(clean_up(out$Hamlet),
                      start = 1,
                      stop = 3) %>% toupper()
  out$code <- first_try
  out$degrees <- NA
  # See if there are duplicates
  any_duplicates <- any(duplicated(out$code))
  if(any_duplicates){
    which_duplicates <- which(duplicated(out$code))
    out$degrees[!which_duplicates] <- 'None'
    for(i in which_duplicates){
      message(i)
      this_row <- out[i,]
      old_name <- this_row$code
      is_duplicated <- TRUE
      index <- 3
      counter <- 0
      while(is_duplicated){
        counter <- counter + 1
        message('---trying: ', counter)
        index <- index + 1
        
        # If already been through 100, replace all three letters
        if(index > 100){
          out$degrees[i] <- 'Major++'
          # new_code <- paste0(sample(LETTERS, 3), collapse = '')
          new_code <- paste0(sample(unique(unlist(strsplit(toupper(clean_up(this_row$Hamlet)), split = ''))), 3), collapse = '')
          # If already been through 50, replace two letters
        } else if(index > 50){
          out$degrees[i] <- 'Major'
          # new_letter <- paste0(sample(LETTERS, 2), collapse = '')
          new_letter <- paste0(sample(unique(unlist(strsplit(toupper(clean_up(this_row$Hamlet)), split = ''))), 2), collapse = '')
          new_code <- paste0(substr(old_name, 1, 1), new_letter, collapse = '')
        } else {
          new_letter <- toupper(substr(clean_up(this_row$Hamlet), index, index))
          out$degrees[i] <- 'Minor'
          if(nchar(new_letter) == 0){
            out$degrees[i] <- 'Minor++'
            # new_letter <- sample(LETTERS, 1)
            new_letter <- sample(unique(unlist(strsplit(toupper(clean_up(this_row$Hamlet)), split = ''))), 1)
          } 
          new_code <- paste0(substr(old_name, 1, 2), new_letter, collapse = '')
        }
        is_duplicated <- new_code %in% out$code
      }
      message('Replacing ', old_name, ' with ',
              new_code)
      out$code[i] <- new_code
    }
  }
  return(out)
}
