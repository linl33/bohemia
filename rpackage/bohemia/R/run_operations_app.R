#' Run operations app
#' 
#' Run the Bohemia operations app
#' @param x The vector to be modified
#' @param n The number of characters that the resulting vector should have
#' @return A character vector of identical length to \code{x} in which all elements have n characters (or more, for those which already had more prior to processing)
#' @import shiny
#' @export

run_operations_app <- function(){
  shiny::shinyAppDir(appDir = system.file('shiny/operations', package = 'bohemia'))
}