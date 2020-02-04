library(shiny)
library(shinydashboard)
library(ggplot2)
library(tidyverse)
library(RPostgreSQL)
library(DT) # devtools::install_github('rstudio/DT')
library(readxl)
library(shinyjs)

# # source scripts
source('credentials_connect.R')
source('credentials_extract.R')

# define whether creating locally or remotely 
local <- TRUE
if(local){
  credentials <- credentials_extract(credentials_file = 'credentials/credentials_local.yaml', 
                                     all_in_file = TRUE)
} else {
  credentials <- credentials_extract(credentials_file = 'credentials/credentials.yaml', 
                                     all_in_file = TRUE)
}

# create a connection object with credentials
co <- credentials_connect(options_list = credentials)
# Function for checking log-in
check_password <- function(user, password, the_users){
  ok <- FALSE
  
  if(tolower(user) %in% tolower(the_users$email)){
    # User exists, now check password
    this_user <- tolower(user)
    this_row <- the_users[tolower(the_users$email) == tolower(this_user),] %>% filter(!is.na(email))
    if(nrow(this_row) == 0){ 
      return(FALSE)
    } else {
        this_row <- this_row[1,]
      }
    this_password <- this_row$password
    message('this row is')
    print(this_row)
    message('password is ', password)
    message('this_password is ', this_password)
    if(password == this_password){
      ok <- TRUE
    } else {
      ok <- FALSE
    }
  } else {
    ok <- FALSE
  }
  if(ok){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# Function for adding new user
add_user <- function(user, password, first_name, last_name, position, institution, users){
  if(user %in% users$email){
    x <- FALSE
    message(paste0('---A database entry for ', user, ' already exists. Skipping.'))
  } else {
    message('---A database entry has just been created for ', user)
    # Add code here to add user to database
    df <- tibble(first_name,
                 last_name,
                 position, institution,
                 email = user, tags = NA,
                 admin = FALSE,
                 password,
                 contact_added = Sys.Date())
    dbWriteTable(conn = co, 
                 name = 'users', 
                 value = df, 
                 row.names = FALSE,
                 overwrite = FALSE,
                 append = TRUE)
    x <- TRUE
    # x <- paste0('Just created an account for user: ',
    #             user, ', with password: ', password)
  }
  return(x)
}

# Define an empty csv for upload
upload_csv <- tibble(Email = '',
                     `First name` = '',
                     `Last name` = '',
                     `Position` = '',
                     Institution = '')
# upload_csv <- upload_csv[0,]
# write_csv(upload_csv, 'upload_csv.csv')


# Read in the users data from the database
get_users <- function(){
  dbGetQuery(conn = co,statement = 'SELECT * FROM users',
             connection_object = co)
}
users <- get_users()
users <- users %>% arrange(first_name)


