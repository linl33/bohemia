#' Google to ODK
#'
#' Fetch an xlsform from google docs, convert to xml, and push to an ODK Aggregate server. The google sheet must have been "published to the web" via the file menu in the upper-left. Note, before running this script, one should have installed ODK Briefcase per the instructions at https://github.com/databrew/bohemia/blob/master/guides/guide_briefcase.md. Note, this is unstable, and proper functioning still requires manually deleting form definitions from the Aggregate server.
#' @param url The url of the google sheet
#' @param briefcase Location on the local machine of the briefcase jar file
#' @param aggregate Location of the ODK Aggregate server
#' @param download_as The file location to be downloaded to
#' @param convert_to The file location of the converted xml
#' @import googlesheets
#' @import readxl
#' @return Nothing
#' @export

google_to_odk <- function(url = 'https://docs.google.com/spreadsheets/d/16_drw-35haLaBlB6tn92mr6zbIuYorAUDyieGONyGTM/edit#gid=141178862',
                          briefcase = '~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar',
                          form_id = NULL,
                          form_title = NULL,
                          storage_directory = '~/Documents/briefcase',
                          aggregate_url = 'https://bohemia.systems',
                          odk_username = 'data',
                          odk_password = 'data',
                          download_as = 'temp.xlsx',
                          convert_to = 'temp.xml'){
  
  # Download form
  gsurl <- gs_url(x = url)
  gs_download(from = gsurl,
              to = download_as, overwrite = TRUE)
  
  # Get the form id if null
  if(is.null(form_id)){
    temp <- read_excel(download_as, sheet = 'settings')
    form_id <- temp$form_id
  }
  # Get the form title if null
  if(is.null(form_title)){
    temp <- read_excel(download_as, sheet = 'settings')
    form_title <- temp$form_title
  }
  
  # Convert to xml
  system(paste0('xls2xform ',
                download_as, ' ',
                convert_to))

  # Remove the old version
  to_location <- paste0(storage_directory, '/ODK Briefcase Storage/forms/', form_title, '/', form_title, '.xml')
  file.remove(to_location)
  
  # Move the file to the area of the form title
  file.copy(from = convert_to,
            to = to_location,
            overwrite = TRUE)
  
  
  # Push to aggregate
  system(paste0(
    "java -jar ", briefcase,
    " --push_aggregate",
    " --form_id ", form_id,
    " --storage_directory ", storage_directory, 
    " --aggregate_url ", aggregate_url, 
    " --odk_username ", odk_username,
    " --odk_password ", odk_password,
    " --force_send_blank"
  ))
  
}