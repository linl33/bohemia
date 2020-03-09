#' Run BohemiApp
#' 
#' Run the BohemiaApp shiny application
#' @return An application running
#' @import shiny
#' @export

run_bohemiapp <- function(){
  shiny::shinyAppDir(appDir = system.file('shiny/bohemiapp', package = 'bohemia'))
}