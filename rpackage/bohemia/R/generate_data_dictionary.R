#' Generate data dictionary
#' 
#' Generate a data dictionary from a XLSform
#' @param path
#' @param language Language (default English)
#' @param include_variable_names Whether to include variable names
#' @param include_relevant Whether to include relevance
#' @param shorten_many At what number of choices should "etc" appear (instead of further choices)
#' @param choices_names_too Whether to include choice names too
#' @param invisibilize Whethr to invisiblize repeated rows in the question/type columns
#' @return A data dictionary
#' @import readxl
#' @import dplyr
#' @import stringr
#' @export




generate_data_dictionary <- function(path, language = 'English', include_variable_names = FALSE, include_relevant = TRUE, shorten_many = 15, choice_names_too = FALSE,
                                     invisibilize = FALSE){
  # library(readxl)
  # library(dplyr)
  # library(stringr)
  # path = '../../../forms/xls/census.xls'
  
  # Read in the data
  survey <- readxl::read_xlsx(path, sheet = 'survey') %>% filter(!is.na(type))
  choices <- readxl::read_xlsx(path, sheet = 'choices') %>% filter(!is.na(name))
  external_choices <- readxl::read_xlsx(path, sheet = 'external_choices') %>% filter(!is.na(name))
  
  # Define a types dictionary
  dict_types <- tibble(variable_type = c('barcode',
                                'date',
                                'dateTime',
                                'geopoint',
                                'image',
                                'integer',
                                'select_multiple',
                                'select_one',
                                'select_one_external',
                                'text',
                                'time'),
                       type_label = c('Barcode',
                                 'Date',
                                 'Date-Time',
                                 'Geographic coordinates',
                                 'Image',
                                 'Integer',
                                 'Multiple choice (multiple)',
                                 'Multiple choice (single)',
                                 'Multiple choice (single)',
                                 'Text',
                                 'Time'))
  
  # Define function for getting type
  get_type <- function(x){
    unlist(lapply(strsplit(x, ' '), function(y){y[1]}))
  }
  
  # Define function for rewording relevance
  relevance_reworder <- function(input_string){
    # return(paste0('`', input_string, '`'))
    return(input_string)
  }
  
  # Get the type of each var
  survey$variable_type <- NA
  for(i in 1:nrow(survey)){
    survey$variable_type[i] <- get_type(survey$type[i])
  }
  
  # Get the variable label
  survey <- left_join(survey, dict_types, by = 'variable_type')
  
  # Deal with language
  survey$question <- unlist(survey[,paste0('label::', language)])
  survey$hint <- unlist(survey[,paste0('hint::', language)])
  choices$choice <- unlist(choices[,paste0('label::', language)])
  external_choices$choice <- unlist(external_choices[,paste0('label::', language)])
  # Loop
  counter <- 0
  out_list <- list()
  the_choices <- ' '
  for(i in 1:nrow(survey)){
    this_row <- survey[i,]
    
    if(!is.na(this_row$type_label) & !is.na(this_row$question)){
      message(i)
      counter <- counter + 1
      
      # relevance
      if(is.na(this_row$relevant)){
        relevance <- ' '
      } else {
        relevance <- this_row$relevant
        relevance <- relevance_reworder(relevance)
      }
      
      the_choices <- ' '
      
      if(this_row$variable_type %in% c('select_one', 'select_one_external', 'select_multiple')){
        
        external <- FALSE
        if(this_row$variable_type %in% c('select_one', 'select_multiple')){
          choice_name <- unlist(lapply(strsplit(this_row$type, ' '), function(x){x[2]}))
        }
        if(this_row$variable_type %in% 'select_one_external'){
          external <- TRUE
          choice_name <- unlist(lapply(strsplit(this_row$type, ' '), function(x){x[2]}))
        }
        if(external){
          the_choices <- external_choices %>% dplyr::filter(list_name == choice_name)  %>% dplyr::filter(!duplicated(choice)) %>% .$choice
          the_choice_levels <- external_choices %>% dplyr::filter(list_name == choice_name)  %>% dplyr::filter(!duplicated(choice)) %>% .$name
        } else {
          the_choices <- choices %>% dplyr::filter(list_name == choice_name)  %>% dplyr::filter(!duplicated(choice)) %>% .$choice
          the_choice_levels <- choices %>% dplyr::filter(list_name == choice_name)  %>% dplyr::filter(!duplicated(choice)) %>% .$name
          if(choice_name == 'household_members'){
            the_choices <- the_choice_levels <- '(Drop-down of household members)'
          } 
        }
        # Now concatenate
        if(length(the_choices) > shorten_many){
          the_choices <- c(the_choices[1:shorten_many], '...')
          the_choice_levels <- c(the_choice_levels[1:shorten_many], ', continued')
        }
        if(choice_names_too){
          the_choices <-
            ifelse(the_choice_levels == the_choices,
                   the_choice_levels,
                   paste0(the_choice_levels, 
                          ' (',
                          the_choices, ')'))
        } 
        # the_choices <- paste0(the_choices, collapse = ' | ')
        
        
      }
      out <- tibble(
        `Variable name` = this_row$name,
        `Variable type` = this_row$type_label,
        Question = this_row$question,
        Options = the_choices,
        Relevance = relevance
      )
      
      out_list[[counter]] <- out
    }
  }
  out <- bind_rows(out_list)
  out$Options <- ifelse(grepl('$', out$Options, fixed = TRUE),
                        '',
                        out$Options)
  if(language == 'Swahili'){
    names(out) <- c("Jina linaloweza kutekelezwa",
                    "Aina inayobadilika",
                    "Swali",
                    "Chaguzi",
                    'Relevance')
  }
  if(language == 'Portuguese'){
    names(out) <- c("Nome variável",
                    "Tipo variável",
                    "Questão",
                    'Opções',
                    'Relevance')
  }

  if(!include_variable_names){
    out <- out[,!names(out) %in% names(out)[1]]
  }
  if(!include_relevant){
    out <- out[,1:(ncol(out)-1)]
  }
  
  if(invisibilize){
    if(include_variable_names){
      col_numbers <- 1:3
    } else {
      col_numbers <-1:2
    }
    if(include_relevant){
      col_numbers <- c(col_numbers, ncol(out))
    }
    deletesa <-  rep(FALSE, nrow(out))
    for(i in 2:nrow(out)){
      # message(i)
      samea <- as.character(unlist(out[i,col_numbers[1]])) == as.character(unlist(out[i-1,col_numbers[1]]))
      sameb <- as.character(unlist(out[i,col_numbers[2]])) == as.character(unlist(out[i-1,col_numbers[2]]))
      if(length(col_numbers) == 3){
        samec <- as.character(unlist(out[i,col_numbers[3]])) == as.character(unlist(out[i-1,col_numbers[3]]))
      }
      if(length(col_numbers) == 4){
        samec <- as.character(unlist(out[i,col_numbers[4]])) == as.character(unlist(out[i-1,col_numbers[4]]))
      }
      
      if(!is.na(samea) & !is.na(sameb)){
        if(samea & sameb){
          deletesa[i] <- TRUE
        }
      }
    }
    
    out[deletesa,1] <- ' '
    out[deletesa,2] <- ' '
    if(length(col_numbers) == 3){
      out[deletesa,3] <- ' '
    }
    if(length(col_numbers) == 4){
      out[deletesa,4] <- ' '
    }
  }
  
  return(out)
}


# x = generate_data_dictionary(path = '../../../forms/xls/census.xls', language = 'Portuguese')
