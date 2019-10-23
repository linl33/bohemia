#' Create location hierarchy
#' 
#' Generate cascading options for location hierarchy for insertion into openhds database and the ODK "choices" sheet. This assumes that location levels have been configured in the openhds web app under "Configuration"->"Location Levels", and have been set to the following: Country, District, Ward, Village, Hamlet (1-5).
#' @param output_file Where to write the file (.sql and .csv will be appended)
#' @return SQL code (in a .sql file) and tabular data (in a .csv file). The sql code is meant to be run on the OpenHDS database, and the .csv file is meant to be copy-pasted into the census choices
#' @import dplyr, gsheet, tidyr, readr
#' @export

openhds_create_location_hierarchy <- function(output_file = "../scripts/locations"){
  require(dplyr); require(gsheet); require(tidyr); require(readr)
  # Define the url of the location hierachy spreadsheet (contains all locations for both sites)
  url <- 'https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit?usp=sharing'
  # Fetch the data
  locations <- gsheet::gsheet2tbl(url = url)
  # Define some helpers
  the_levels <- names(locations)
  the_levels <- the_levels[the_levels != 'Region'] # not necessary since only one per country
  n_levels <- length(the_levels)
  
  # Loop through each level and create the corresponding tables
  counter <- 0
  out_list <- list()
  key_table <- tibble(uuid = NA,
                      key = NA,
                      value = NA)
  key_table <- key_table[0,]
  odk_list <- list(); odk_counter <- 0
  for(i in 1:length(the_levels)){
    
    # Get a unique list of the values of this level (with associated hierarchy)
    this_level <- the_levels[i]
    previous_levels <- the_levels[1:(i-1)]
    next_levels <- the_levels[(i+1):length(the_levels)]
    levels_til_here <- the_levels[1:i]
    pd <- locations %>%
      group_by(.dots = levels_til_here) %>%
      tally %>% dplyr::select(-n) %>% ungroup
    these_values <- as.character(unlist(pd[,ncol(pd)]))
    
    # Generate a key row
    nkt <- nrow(key_table) +1
    key_rows <- tibble(uuid = paste0('hierarchy',nkt:(nkt+(nrow(pd)-1))),
                      key = this_level,
                      value = these_values)
    # Add the key row(s) to the key table
    key_table <- bind_rows(key_table, key_rows)
    
    # Generate into table
    inner_list <- list()
    for(j in 1:nrow(pd)){
      odk_counter <- odk_counter + 1
      this_row <- pd[j,]
      odk_list[[odk_counter]] <- this_row
      this_value <- as.character(unlist(this_row[,i]))
      parent_value <- as.character(unlist(this_row[,i-1]))
      parent_key <- previous_levels[length(previous_levels)]
      this_out <- 
        tibble(uuid = NA,
               extId = NA,
               name = this_value,
               level_uuid = paste0('hierarchyLevelId', i),
               parent_uuid = ifelse(i == 1, 'hierarchy_root',
                                    key_table$uuid[key_table$value == parent_value & key_table$key == parent_key]))
      inner_list[[j]] <- this_out
    }
    out <- bind_rows(inner_list)
    out_list[[i]] <- out
  }  
  done <- bind_rows(out_list)
  odk <- bind_rows(odk_list)
  # Generate uuids
  done$uuid <- paste0('hierarchy', 1:nrow(done))
  
  # Generate extIds
  for(i in 1:nrow(done)){
    message(i, ' of ', nrow(done))
    # Get the default 3 character id
    this_name <- done$name[i]
    this_name <- gsub("'", "\'", this_name)
    default <- toupper(substr(gsub("'", "", this_name), 1, 3))
    # See if it's already there
    previous_defaults <- unique(done$extId)
    already_there <- default %in% previous_defaults
    if(already_there){
      message('found a duplicate, working on it: ', default)
    }
    counter <- 0
    while(already_there){
      counter <- counter + 1
      if(counter < 30){
        new_character <- sample(toupper(unlist(strsplit(gsub("'", "", this_name), ''))), 1)
        default <- c(substr(gsub("'", "", this_name), 1, 2), new_character)
      } else {
        # stop(i)
        default <- sample(LETTERS, 3)
        # new_character <- sample(toupper(unlist(strsplit(this_name, ''))), 2)
        # default <- c(substr(this_name, 1, 1), new_character)
        
      }
      default <- toupper(paste0(default, collapse = ''))
      already_there <- default %in% previous_defaults
    }
    done$extId[i] <- default
  }
  
  x <- done
  # Bring the IDs into the ODK table too
  odk$extId <- x$extId
  odk <- odk %>% dplyr::select(extId, Country, District, Ward, Village, Hamlet)
  

  # Convert to SQL insert commands
  the_lines <- c()
  for (i in 1:nrow(x)){
    this_row <- x[i,]
    this_text <-
      paste0(
        "INSERT INTO `locationhierarchy` VALUES ('",
        this_row$uuid, "', '",
        this_row$extId, "', '",
        gsub("'", "\\'", this_row$name, fixed = T), "', '",
        this_row$level_uuid,"', '",
        this_row$parent_uuid, "');"
      )
    the_lines[i] <- this_text
  }
  
  sql_file <- paste0(output_file, '.sql')
  csv_file <- paste0(output_file, '.csv')

  message('Writing sql code to ', sql_file)
  fileConn<-file(sql_file, encoding='UTF-8')
  writeLines(the_lines, fileConn)
  close(fileConn)
  
  message('Writing tabular data to ', csv_file)
  write_csv(odk, csv_file)
}
