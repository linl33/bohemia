#' Enroll worker
#'
#' Enroll a new worker by (a) inputting information about that worker and (b) receiving an ID number and a list of households. By running this function, you will both create one new row in the "workers" table of the "ids" database, and 1000 new rows in the "households" table of the "ids" database
#' @param name_first First name of the worker
#' @param name_last Last name of the worker
#' @param location Country of the worker (either Tanzania or Mozambique)
#' @return A QR code
#' @import tidyverse
#' @import RPostgres
#' @import DBI
#' @export

enroll_worker <- function(name_first = 'Jane',
                          name_last = 'Doe',
                          location = 'Tanzania'){
  
  # Connect to the db
  con <- dbConnect(RPostgres::Postgres(), 
                   dbname = 'ids')  
  
  # Get previous workers
  previous <- dbGetQuery(conn = con,
                             "SELECT * FROM workers")
  
  # See if the first name last name combination already exists
  already_exists <- previous %>%
    filter(first_name == name_first,
           last_name == name_last)
  if(nrow(already_exists) > 0){
    stop(paste0(name_first, ' ',
                name_last, ' already exists. ID: ',
                already_exists$wid))
  }
  
  # If the name does not already exist, move forward with creating it
  # Define the highest id so far
  suppressWarnings({
    high_id <-max(as.numeric(as.character(previous$wid)), na.rm = TRUE)
  })
  if(is.na(high_id)){
    high_id <- -1
  }
  # Create a new id
  new_id <- high_id + 1
  # Put into the 3 digit format
  new_id <- add_zero(new_id, 3)
  # Create a table for adding info to database
  new_row <- tibble(wid = new_id,
                    first_name = name_first,
                    last_name = name_last,
                    location = location)
  # Add to database
  dbWriteTable(conn = con,
               name = 'workers',
               new_row, 
               append = TRUE)
  message('Just wrote the following data to the "workers" table of the "ids" database:')
  print(new_row)
  
  # Now that a worker has been added, also add the appropriate ids
  # To the households table
  new_row <- tibble(wid = new_id,
                    subid = add_zero(0:999, 3)) %>%
    mutate(hhid = paste0(wid, '-', subid))
  dbWriteTable(conn = con,
               name = 'households',
               new_row, 
               append = TRUE)
  message('Just wrote the following data to the "households" table of the "ids" database:')
  print(head(new_row))
  message('...')
  dbDisconnect(conn = con)
}
