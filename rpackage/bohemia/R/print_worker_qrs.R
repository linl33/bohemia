#' Print worker QRs
#'
#' Render a document of pds for a worker
#' @param wid The 3 digit id of the worker
#' @param restrict Restrict to only some ids. If
#' \code{NULL} (the default), all 1000 ids assigned to the worker will be used. Otherwise, this should be a vector of either (a) the three character subids to be kept or (b) the 7 character hhids to be kept (3 digits, dash, 3 digits)
#' @param output_dir The directory to which the file should be written. If
#' \code{NULL} (the default), the current working directory will be used.
#' @param output_file The name of the file to be written.
#' @import tidyverse
#' @import RPostgres
#' @import DBI
#' @return A pdf will be written
#' @importFrom rmarkdown render
#' @export

print_worker_qrs <- function(wid = 1,
                             restrict = NULL,
                           output_dir = NULL,
                           output_file = 'qrs.pdf'){

  # If no output directory, make current wd
  if(is.null(output_dir)){
    output_dir <- getwd()
  }
  
  # Adjust the worker id to ensure its the right 3-digit format
  the_wid <- wid <- add_zero(wid, 3)
  
  # Get the data in the database pertaining to the worker in question
  # Connect to the db
  con <- dbConnect(RPostgres::Postgres(), 
                   dbname = 'ids')  
  
  # Get previous workers
  previous <- dbGetQuery(conn = con,
                         "SELECT * FROM workers")
  
  if(nrow(previous) <1){
    stop('There are no entries in the workers table of the id database. Stopping.')
  }
  
  # Get the row for the worker
  previous <- previous %>% filter(wid == the_wid)
  
  # Get the rows of the hids
  hids <- dbGetQuery(conn = con,
                     paste0("SELECT * FROM households WHERE wid ='",
                            the_wid, "'"))
  if(nrow(previous) <1){
    stop('There are no entries in the households table of the id database for this worker. Stopping.')
  }
  
  # Filter if relevant
  if(!is.null(restrict)){
    hids <- hids %>%
      filter(!subid %in% restrict,
             !hhid %in% restrict)
  }
  
  # Get the ids
  ids <- hids$hhid
  
  # Pass them on to the pdf generator
  render_qr_pdf(ids = ids,
                output_dir = output_dir,
                output_file = output_file)
}
