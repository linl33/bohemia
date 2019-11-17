#' Create location choices
#' 
#' Generate cascading options for location choices appropriate for the correct location hierarchy in ODK
#' @param country Which country to use. If \code{NULL} (the default), both will be used.
#' @param add_other Whether to add an "other" option
#' @param add_ids Whether to add an ID section
#' @param other_word The name of the word to be used to mark "Other"
#' @param other_only_levels Whether the other option should be applied only to certain geographical levels. If \code{NULL}, all levels get an "other" option. Otherwise, only the named vector.
#' @return A list of two tables named "survey" and "choices"
#' @import dplyr
#' @import gsheet
#' @import tidyr
#' @export

odk_create_location_choices <- function(country = NULL, add_other = TRUE, add_ids = FALSE, other_word = 'Other',
                                        other_only_levels = c('Village', 'Hamlet')){
  
  # country = NULL; add_other = TRUE; add_ids = FALSE; other_word = 'Other';
  # other_only_levels = c('Village', 'Hamlet')
  require(dplyr)
  require(gsheet)
  require(tidyr)
  # Define the url of the location hierachy spreadsheet (contains all locations for both sites)
    url <- 'https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit?usp=sharing'
  # Fetch the data
  locations <- gsheet::gsheet2tbl(url = url)
  
  # Views for openhds creation
  moz <- locations %>%
    filter(Country == 'Mozambique') %>%
    group_by(Ward, Village, Hamlet) %>% tally
  
  # Filter for country
  if(!is.null(country)){
    locations <- locations %>% filter(Country == country)
  }
  # Ensure no duplicates
  pd <- locations %>%
    group_by(Country, Region, District, Ward, Village, Hamlet) %>%
    tally %>% 
    arrange(desc(n))
  duplicates <- any(pd$n > 1)
  if(duplicates){
    message('There are duplicates for the following locations. Fix at https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY before continuing.')
    print(pd %>% filter(n >1))
    stop('Stopped processing')
  }
  # Define some helpers
  the_levels <- names(locations)
  n_levels <- length(the_levels)
  
  if(add_other){
    # Add an "other" option for each level
    new_rows <- list()
    for(i in 1:(n_levels-1)){
      this_level <- the_levels[i]
      previous_levels <- the_levels[1:(i-1)]
      next_levels <- the_levels[(i+1):length(the_levels)]
      levels_til_here <- the_levels[1:i]
      pd <- locations %>%
        group_by(.dots = levels_til_here) %>%
        tally %>% dplyr::select(-n)
      if(i == 1){
        pd <- bind_rows(pd, tibble(Country = 'Other'))
      }
      for(j in 1:length(next_levels)){
        pd[,next_levels[j]] <- other_word
      }
      new_rows[[i]] <- pd
    }
    new_rows <- bind_rows(new_rows)
    # Add the "other" options to the dataset
    locations <- bind_rows(locations, new_rows)
    
    # Filter for other levels
    if(!is.null(other_only_levels)){
      which_indices <- which(!names(locations) %in% other_only_levels)
      for(j in which_indices){
        locations <- locations[locations[,j] != other_word,]
      }
    }
    # Make sure that the "other" ones are ordered last
    is_other <- function(x){x == 'Other'}
    
    # Hamlet
    other_hamlets <- locations[is_other(locations$Hamlet),]
    locations <- locations[!is_other(locations$Hamlet),]
    # Village
    other_villages <- locations[is_other(locations$Village),]
    locations <- locations[!is_other(locations$Village),]
    # Ward
    other_wards <- locations[is_other(locations$Ward),]
    locations <- locations[!is_other(locations$Ward),]
    # District
    other_districts <- locations[is_other(locations$District),]
    locations <- locations[!is_other(locations$District),]
   
    # Combine locations with the (ordered) others:
    locations <- bind_rows(
      locations,
      other_hamlets,
      other_wards,
      other_villages,
      other_districts
    )
    
    # Make factor
    other_factor <- function(x){factor(x, levels = c(sort(unique(x[x !=  'Other'])), 'Other'))}
    locations <- locations %>%
      mutate(Country  = other_factor(Country),
             District = other_factor(District),
             Ward = other_factor(Ward),
             Village = other_factor(Village),
             Hamlet = other_factor(Hamlet))
      
  }
  
  # Put into correct format for choices
  choices_list <- list()
  counter <- 0
  for(j in 2:length(the_levels)){
    counter <- counter + 1
    previous_levels <- the_levels[1:(j-1)]
    this_level <- the_levels[j]
    out <- locations %>% group_by(.dots = as.list(c(previous_levels, this_level))) %>% tally %>% dplyr::select(-n) %>% ungroup %>%
      mutate(list_name = this_level)
    out$name <- out$label <- as.character(unlist(out[,(ncol(out)-1)]))
    keep_columns <- c('list_name', 'name', 'label', previous_levels)
    out <- out[,keep_columns]
    choices_list[[counter]] <- out
  }
  choices <- bind_rows(choices_list)
  # Add the countries
  choices <- choices %>%
    bind_rows(tibble(list_name = 'Country',
                     name = sort(unique(locations$Country)),
                     label = sort(unique(locations$Country))) %>%
                mutate(Region = NA, District = NA, Ward = NA, Village = NA)) 
  choices <- choices %>% dplyr::distinct(.keep_all = TRUE)
  

  
  if(add_ids){
    # Add id numbers for creating hhids
    # Village: 3 digits
    # Ward: 2 digits
    # District: 1 digit
    
    ids <- choices %>%
      dplyr::filter(!is.na(Village)) %>%
      arrange(Country, Region, District, Ward, Village) %>%
      dplyr::mutate(Hamlet = name)
    ids$list_name <- 'id'
    ids$name <- ids$label <-  add_zero(1:nrow(ids), nchar(nrow(ids)))
    choices <- bind_rows(choices, ids)
  }
  

  # Create the survey portion
  survey <- tibble(type = paste0('select_one ', the_levels),
                   name = paste0(the_levels),
                   label = the_levels,
                   choice_filter = NA)
  for(j in 2:n_levels){
    this_level <- the_levels[j]
    previous_levels <- the_levels[1:(j-1)]
    the_filters <- paste0(previous_levels, '=${',previous_levels, '}', collapse = ' and ')
    survey$choice_filter[j] <- the_filters
  }
  
  out <- list(survey, choices)
  names(out) <- c('survey', 'choices')
  return(out)
}
library(readr)
x <- odk_create_location_choices()
write_csv(x$survey, '~/Desktop/1.csv', na = '')
write_csv(x$choices, '~/Desktop/2.csv')
