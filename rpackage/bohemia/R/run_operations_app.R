#' Run operations app
#' 
#' Run the Bohemia operations app
#' @return An application running
#' @import shiny
#' @export

run_operations_app <- function(){
  shiny::shinyAppDir(appDir = system.file('shiny/operations', package = 'bohemia'))
}