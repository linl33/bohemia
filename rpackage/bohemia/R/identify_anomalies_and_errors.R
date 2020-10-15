#' Identify anomalies and errors
#'
#' Given a clean Bohemia database, identify anomalies and errors 
#' @param data A named list of dataframes. It should have the structure of named dataframes sharing names with the names of the tables in the database (excluding the "clean_" prefix)
#' @param anomalies_registry Dataframe of anomalies registry. If NULL, fetched from google
#' @param locs Dataframe of locations hierarchy
#' @return Data will be modified in the database
#' @import dplyr
#' @import gsheet
#' @export

identify_anomalies_and_errors <- function(data,
                                          anomalies_registry = NULL,
                                          locs = NULL){
  message('Beginning anomalies and errors identification...')
  
  # Read in the anomalies_and_errors table
  if(is.null(anomalies_registry)){
    ae <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1MH4rLmmmQSkNBDpSB9bOXmde_-n-U9MbRuVCfg_VHNI/edit#gid=0')
  } else {
    ae <- anomalies_registry
  }
  
  # Read in locations hierarchy
  if(is.null(locs)){
    locs <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765')
  }  
  
  
  message('...', nrow(ae), ' anomalies and errors in the registry')
  
  ae <- ae %>% dplyr::filter(!is.na(identification_code))
  message('...', nrow(ae), ' have associated code snippets')
  
  # Go through each code snippet and execute
  out_list <- list()
  counter <- 0
  for(i in 1:nrow(ae)){
    this_row <- ae[i,]
    message('......Snippet ', i, ' of ', nrow(ae), ': ', this_row$name)
    this_snippet <- this_row$identification_code
    this_incident_code <- this_row$incident_code
    this_fid_code <- this_row$fid_code
    suppressMessages({
      eval(parse(text = this_snippet))
    })
    no_pass <- nrow(result) > 0
    if(no_pass){
      message('.........Did not pass: ', nrow(result), ' anomalous incidents.')
      for(j in 1:nrow(result)){
        counter <- counter + 1
        result_row <- result[j,]
        # Incident code (ie, description of the specific incident)
        suppressMessages({
          eval(parse(text = this_incident_code))
        })
        # Fid code (ie, the fieldworker involved)
        suppressMessages({
          eval(parse(text = this_fid_code))
        })
        out <- this_row %>%
          dplyr::mutate(id = paste0(this_row$name, '_',result_row$instance_id)) %>%
          dplyr::select(id,  description) %>%
          mutate(incident = incident) %>%
          mutate(wid = fid)
        out_list[[counter]] <- out
      }
    }
  }
  out <- bind_rows(out_list)
  return(out)
}
