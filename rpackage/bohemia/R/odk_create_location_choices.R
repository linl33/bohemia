#' Create location choices
#' 
#' Generate cascading options for location choices appropriate for the correct location hierarchy in ODK
#' @param country Which country to use. If \code{NULL} (the default), both will be used.
#' @param add_other Whether to add an "other" option
#' @param add_ids Whether to add an ID section. Defunct. Keep as FALSE
#' @param add_codes Whether to add the hamlet code. TRUE as default
#' @param other_word The name of the word to be used to mark "Other"
#' @param other_only_levels Whether the other option should be applied only to certain geographical levels. If \code{NULL}, all levels get an "other" option. Otherwise, only the named vector.
#' @param lower_it Whether to lowercase the names of the levels (ie "village", not "Village"). Default is False
#' @return A list of two tables named "survey" and "choices"
#' @import dplyr
#' @import gsheet
#' @import tidyr
#' @export

odk_create_location_choices <- function(country = NULL, 
                                        add_other = TRUE, 
                                        add_ids = FALSE, 
                                        add_codes = TRUE,
                                        other_word = 'Other',
                                        other_only_levels = c('Village', 'Hamlet'),
                                        lower_it = TRUE){
  
  # country = NULL; add_other = TRUE; add_ids = FALSE; other_word = 'Other';
  # other_only_levels = c('Village', 'Hamlet')
  # require(dplyr)
  # require(gsheet)
  # require(tidyr)
  # Define the url of the location hierachy spreadsheet (contains all locations for both sites)
  url <- 'https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit?usp=sharing'
  # Fetch the data
  locations <- locations_original <-  gsheet::gsheet2tbl(url = url)
  locations$clinical_trial <- NULL
  locations$code <- NULL
  
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
  the_levels <- the_levels[the_levels != 'code']
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
    new_rows <- bind_rows(new_rows) #%>% mutate(code = NA)
    # Add the "other" options to the dataset
    locations <- bind_rows(locations, new_rows)
    
    # Filter for other levels
    if(!is.null(other_only_levels)){
      which_indices <- which(!names(locations) %in% c(other_only_levels))
      for(j in which_indices){
        keep_these <- as.logical(unlist(locations[,j]) != other_word)
        message(j, ': keeping ', length(which(keep_these)), ' of ', nrow(locations))
        locations <- locations[keep_these,]
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
  
  # Add more rows for the code. 
  # Unlike the location hierarchy (which does not include hamlet), this DOES
  if(add_codes){
    glc <- get_location_code
    glc <- Vectorize(glc)
    sub_choices <- choices %>% filter(list_name == 'Hamlet',
                                      name != 'Other') %>%
      dplyr::mutate(Hamlet = name) %>%
      mutate(list_name = 'code')
    x <- glc(country = sub_choices$Country,
             region = sub_choices$Region,
             district = sub_choices$District,
             ward = sub_choices$Ward,
             village = sub_choices$Village,
             hamlet = sub_choices$Hamlet)
    xout <- c(); for(i in 1:length(x)){xout[i] <- ifelse(is.null(x[[i]]), NA, x[[i]])}
    sub_choices$code <- sub_choices$name <- sub_choices$label <- xout
    choices <- bind_rows(choices %>% mutate(Hamlet = NA), sub_choices)  
  }
  
  # Reformat to match the columns in census
  choices <- choices %>%
    mutate(`label::English` = label,
           `label::Portuguese` = label,
           `label::Swahili` = label) %>%
    dplyr::select(list_name, name, `label::English`, `label::Portuguese`, `label::Swahili`, Country,
                  Region, District, Ward, Village, Hamlet, code)
  

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
  
  if(lower_it){
    choices$list_name <- tolower(choices$list_name)
    names(choices)[names(choices) == 'Country'] <- 'country'
    names(choices)[names(choices) == 'Region'] <- 'region'
    names(choices)[names(choices) == 'District'] <- 'district'
    names(choices)[names(choices) == 'Ward'] <- 'ward'
    names(choices)[names(choices) == 'Village'] <- 'village'
    names(choices)[names(choices) == 'Hamlet'] <- 'hamlet'
    
  }
  
  # Remove the all NAs from choices
  choices <- choices %>% filter(!is.na(name))
  
  # Add other options in other language
  choices$`label::Portuguese`[choices$`label::English` == 'Other'] <- 'Outro'
  choices$`label::Swahili`[choices$`label::English` == 'Other'] <- 'Nyingine'
  
  out <- list(survey, choices)
  names(out) <- c('survey', 'choices')
  return(out)
}
# library(readr)
# x <- odk_create_location_choices()
# write_csv(x$survey, '~/Desktop/1.csv', na = '')
# write_csv(x$choices, '~/Desktop/2.csv')
