#' Update ODKX
#'
#' Update the ODKX server with new forms
#' @param suitcase_file The path to the ODK suitcase jar file
#' @param bohemia_dir The path to the cloned, updated bohemia github repo
#' @param cloud_endpoint The cloud endpoint
#' @param username The username
#' @param password The password
#' @param reset_server Whether to reset the server
#' @param push_new_forms Whether to push new forms to the server
#' @return Data will be updated
#' @import dplyr
#' @import tidyr
#' @export

update_odkx <- function(suitcase_file,
                        bohemia_dir,
                        cloud_endpoint = 'https://databrew.app',
                        username = 'dbrew',
                        password = 'admin',
                        reset_server = TRUE,
                        push_new_forms = TRUE){
  
  # Get current directory 
  suitcase_dir <- paste0(unlist(lapply(strsplit(suitcase_file, '/'), function(x){x[1:(length(x)-1)]})), collapse = '/')
  owd <- getwd()
  setwd(suitcase_dir)

  # Fix bohemia directory if not with trailing /
  last_symbol <- substr(bohemia_dir, nchar(bohemia_dir), nchar(bohemia_dir))
  if(last_symbol != '/'){
    bohemia_dir <- paste0(bohemia_dir, '/')
  }
  
  # Reset the server
  if(reset_server){
    the_command <- 
      paste0('java -jar ',
             suitcase_file,
             ' -reset  -cloudEndpointUrl "',
             cloud_endpoint,
             '" -appId "default" -username "', username, '" -password "', password, '" -dataVersion 2')
    system(the_command)
  }
  
  
  # Push the new forms
  if(push_new_forms){
    the_command <- 
      paste0('java -jar ',
             suitcase_file,
             ' -cloudEndpointUrl "', cloud_endpoint,
             '" -dataVersion 2 -appId "default" -username "', username, 
             '" -password "',
             password, '" -upload -uploadOp RESET_APP -path ', bohemia_dir, 'odkx/app/config')
    system(the_command)
  }
  
  # Return to current working directory
  setwd(owd)
}