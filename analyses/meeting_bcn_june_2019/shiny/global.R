library(shinydashboard)
library(googlesheets)
library(ggplot2)
library(dplyr)
library(Hmisc)
library(ggridges)


source('functions.R')
# Read data
use_old <- FALSE
if(use_old){
  load('df.RData')
} else {
  sheet <- gs_title('ECTMIH survey (Responses)')
  df <- gs_read_csv(sheet)
  
  
  # Changes names
  names(df) <- c('timestamp', 'years', 'sex',
                 'km_rufiji', 'km_mopeia', 'gps')
  
  df$date <- as.Date(substr(df$timestamp, 1, 10), format = '%m/%d/%Y')
  df$time <- paste0(df$date,
                    ' ',
                    unlist(lapply(strsplit(x = df$timestamp, split = ' '), function(x){x[2]})))
  df$time <- as.POSIXct(df$time)
  
  
  df <- df %>% filter(time > '2019-06-26 11:00:00 CEST')
  
  df <- 
    df %>%
    mutate(years = make_numeric(years),
           km_rufiji = make_numeric(km_rufiji),
           km_mopeia = make_numeric(km_mopeia))
  
  df <- df %>%
    mutate(gps = ifelse(gps == 'Yes', 'Has a\nGPS watch',
                        'Does not have\na GPS watch'))
  
  
  save(df, file = 'df.RData')  
}
