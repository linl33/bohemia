#' Sync workers traccar
#'
#' Syncronize between (a) the workers who have registered via google sheets and (b) the workers whose information has been registered on the Traccar server app
#' @param credentials A list with named elements. If \code{NULL} these arguments can be specified individually
#' @param delete_from_traccar Whether to delete from Traccar those workers who don't show up in the shiny database. Be careful with this!
#' @param traccar_url The URL where the Traccar server application is being run
#' @param traccar_user The administrator's username for the Traccar server application
#' @param traccar_pass The administrator's password for the Traccar server application
#' @return The function will send updates from the Shiny-generated MySQL database to the Traccar server via an HTTP post request
#' @export
#' @import dplyr
#' @import httr
#' @import yaml
#' @import gsheet
#' @import tidyr
#' @examples 
#' \dontrun{
#' # Read in credentials
#' credentials <- yaml::yaml.load_file('../../../credentials/credentials.yaml')
#'sync_workers(credentials = credentials)
#'}

sync_workers_traccar <- function(credentials = NULL,
                         delete_from_traccar = FALSE,
                         traccar_url,
                         traccar_user,
                         traccar_pass){
  # Check to see if there is a credentials file supplied
  # If not, use explicit arguments
  if(is.null(credentials)){
    credentials <- list(traccar_server = traccar_url,
                        traccar_user = traccar_user,
                        traccar_pass = traccar_pass)
  } 
  
  # Get users data already registered on the traccar server
  registered_workers_tza <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=0') %>% dplyr::select(-tablet_id)  %>% mutate(phone = as.character(phone))
  registered_workers_moz <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=490144130') %>% dplyr::select(-tablet_id)  %>% mutate(phone = as.character(phone))
  registered_workers_other <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=179257508') %>% dplyr::select(-tablet_id)  %>% mutate(phone = as.character(phone))
  
  registered_workers <- bind_rows(registered_workers_tza,
                                  registered_workers_moz,
                                  registered_workers_other)
  registered_workers <- registered_workers %>%
    filter(!is.na(first_name),
           !is.na(last_name))
  
  # Get users who have registered on the shiny app
  in_traccar <- get_traccar_data(url = credentials$traccar_server,
                                 user = credentials$traccar_user,
                                 pass = credentials$traccar_pass)
  
  # Message
  message('Workers enrolled:')
  message('---Via google sheet: ', nrow(registered_workers))
  message('---In Traccar: ', nrow(in_traccar))
  
  # Define a subset of those that are already regiestered in the shiny
  # app, but not yet registered on the traccar server
  need_to_register <- registered_workers %>%
    filter(!as.numeric(as.character(bohemia_id)) %in% as.numeric(as.character(in_traccar$uniqueId)))
  
  # Loop through each person and register on traccar
  if(nrow(need_to_register) > 0){
    go <- TRUE
    message('Porting data from the google registration sheet to the Traccar server:')
  } else {
    message('No new registrations')
    go <- FALSE
  }
  if(go){
    for(i in 1:nrow(need_to_register)){
      this_row <- need_to_register[i,]
      this_name <- paste0(this_row$first_name, ' ', this_row$last_name)
      this_id <- this_row$bohemia_id
      message('---Adding worker ', i, ': ', 
              need_to_register$first_name[i], ' ',
              need_to_register$last_name[i], ' ',
              '(id: ', need_to_register$bohemia_id[i], ')\n')
      post_traccar_data(user = credentials$traccar_user,
                        pass = credentials$traccar_pass,
                        name = this_name,
                        unique_id = this_id,
                        url = credentials$traccar_server)
    }
  }
  
  # Carry out deletions if necessary
  if(delete_from_traccar){
    message('Delete functionality not yet implemented')
    delete_these <- in_traccar %>%
      filter(!as.numeric(as.character(uniqueId)) %in% as.numeric(as.character(registered_workers$bohemia_id)))
    if(nrow(delete_these) > 0){
      message('For now, you can manually delete the following users from the web interface at ',
              credentials$traccar_server)
      message(paste0(delete_these$name, collapse = '\n'))
    } else {
      message('But don\'t worry, there are no users to delete anyway')
    }
  }
  out <- list(added = need_to_register)
  if(delete_from_traccar){
    out$deleted <- tibble()
  }
}


