#' Update Mopeia locality names
#' 
#' Mopeia locality names changed from 2016 to 2017. Specifically, the number of localities were reduced by absorbing some localities (now non-existent) into others. This function is meant to take a vector of "old" localities, and when applicable, update them to the name naming schema
#' @param x The vector to be modified
#' @return A character vector of identical length to \code{x} 
#' @import dplyr
#' @export

update_mopeia_locality_names <- function(x){
 # Make x into a tibble
  df <- dplyr::tibble(old_name = as.character(toupper(x)))
  # Create a joiner table
  joiner <- dplyr::tibble(old_name = toupper(c('Sangalaza',
                                        'Mugurrumba',
                                        'Nzero',
                                        'Chimuara',
                                        'Nzanza')),
                   new_name = toupper(c('MOPEIA SEDE',
                                        'MOPEIA SEDE',
                                        'SAMBALENDO',
                                        'SAMBALENDO',
                                        'SAMBALENDO')))
  # Join them together
  joined <- dplyr::left_join(df, joiner, by = 'old_name')
  # If no join, it means no name change
  joined$out <- ifelse(is.na(joined$new_name),
                            joined$old_name,
                            joined$new_name)
  return(joined$out)
}
