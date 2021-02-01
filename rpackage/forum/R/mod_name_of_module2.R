#' name_of_module2 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_name_of_module2_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' name_of_module2 Server Function
#'
#' @noRd 
mod_name_of_module2_server <- function(input, output, session){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_name_of_module2_ui("name_of_module2_ui_1")
    
## To be copied in the server
# callModule(mod_name_of_module2_server, "name_of_module2_ui_1")
 
