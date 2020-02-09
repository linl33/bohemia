#' Generate data dictionary
#' 
#' Generate a data dictionary from a XLSform
#' @param path
#' @param language Language (default English)
#' @return A data dictionary
#' @import readxl
#' @import dplyr
#' @export




generate_data_dictionary <- function(path, language = 'English'){
  # library(readxl)
  # library(dplyr)
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
  
  # Loop
  counter <- 0
  out_list <- list()
  for(i in 1:nrow(survey)){
    this_row <- survey[i,]
    
    if(!is.na(this_row$type_label)){
      message(i)
      counter <- counter + 1
      out <- tibble(
        `Variable name` = this_row$name,
        `Variable type` = this_row$type_label,
          Question = this_row$question,
          Options = ' '
      )
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
          the_choices <- external_choices %>% dplyr::filter(list_name == choice_name) %>% .$choice
          the_choice_levels <- external_choices %>% dplyr::filter(list_name == choice_name) %>% .$name
        } else {
          the_choices <- choices %>% dplyr::filter(list_name == choice_name)  %>% .$choice
          the_choice_levels <- choices %>% dplyr::filter(list_name == choice_name) %>% .$name
        }
        # Now concatenate
        combined_choices <-
          ifelse(the_choice_levels == the_choices,
                 the_choice_levels,
                 paste0(the_choice_levels, 
                        ' (',
                        the_choices, ')'))
        the_choices <- paste0(combined_choices, collapse = ' | ')
        out$Options <- the_choices
      }
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
                    "Chaguzi")
  }
  if(language == 'Portuguese'){
    names(out) <- c("Nome variável",
                    "Tipo variável",
                    "Questão",
                    'Opções')
  }

  return(out)
}


# x = generate_data_dictionary(path = '../../../forms/xls/census.xls', language = 'Portuguese')
