#' Clean choices
#' 
#' Identify the extra "choices" in the choices tab of a xlsform
#' @param url The url of the document
#' @return A dataframe
#' @export
#' @import dplyr, gsheet, tidyr


clean_choices <- function(url_survey = 'https://docs.google.com/spreadsheets/d/1uB2a2Lr7D32Bh2vZsP88-mp4borI8mA6Nct-SkQSNyQ/edit#gid=141178862',
                          url_choices = 'https://docs.google.com/spreadsheets/d/1uB2a2Lr7D32Bh2vZsP88-mp4borI8mA6Nct-SkQSNyQ/edit#gid=286602728'){
  
  # Urls
  # censushouse: https://docs.google.com/spreadsheets/d/1uB2a2Lr7D32Bh2vZsP88-mp4borI8mA6Nct-SkQSNyQ/edit#gid=141178862
  # choices: https://docs.google.com/spreadsheets/d/1uB2a2Lr7D32Bh2vZsP88-mp4borI8mA6Nct-SkQSNyQ/edit#gid=286602728
  # censusmember: https://docs.google.com/spreadsheets/d/1Z1nQ7RvbiP_YBOth62AoOUDVB9WcMDsIu3jJEnaSNbo/edit#gid=141178862
  # choices: https://docs.google.com/spreadsheets/d/1Z1nQ7RvbiP_YBOth62AoOUDVB9WcMDsIu3jJEnaSNbo/edit#gid=286602728
  
  require(dplyr)
  require(gsheet)
  require(tidyr)
  # Define the url of the location hierachy spreadsheet (contains all locations for both sites)

  # Fetch the data
  survey <- gsheet::gsheet2tbl(url = url_survey)
  choices <- gsheet::gsheet2tbl(url = url_choices)
  
  # Identify the survey choices
  is_choice <- unlist(lapply(strsplit(survey$type, split = ' '), function(x){x[1]}))
  is_choice <- which(is_choice %in% c('select_one', 'select_multiple', 'select_one_external'))
  survey_choices <- unlist(lapply(strsplit(survey$type, split = ' '), function(x){x[2]}))
  survey_choices <- survey_choices[is_choice]
  survey_choices <- unique(survey_choices)
  
  # Identify those fields that appear in choices but not in the survey
  remove_these <- unique(choices$`list name`[!choices$`list name` %in% survey_choices])
  
  # Perform the removal
  choices <- choices %>%
    filter(!`list name` %in% remove_these)
  
  # Return the new choices
  return(choices)
}

# library(readr)
# x = clean_choices(url_survey = 'https://docs.google.com/spreadsheets/d/1uB2a2Lr7D32Bh2vZsP88-mp4borI8mA6Nct-SkQSNyQ/edit#gid=141178862',
#                   url_choices = 'https://docs.google.com/spreadsheets/d/1uB2a2Lr7D32Bh2vZsP88-mp4borI8mA6Nct-SkQSNyQ/edit#gid=286602728')
# write_csv(x, '~/Desktop/censushouse_choices.csv')
# 
# x = clean_choices(url_survey = 'https://docs.google.com/spreadsheets/d/1Z1nQ7RvbiP_YBOth62AoOUDVB9WcMDsIu3jJEnaSNbo/edit#gid=141178862',
#                   url_choices = 'https://docs.google.com/spreadsheets/d/1Z1nQ7RvbiP_YBOth62AoOUDVB9WcMDsIu3jJEnaSNbo/edit#gid=286602728')
# write_csv(x, '~/Desktop/censusmember_choices.csv')


