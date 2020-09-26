#' Run the Shiny Application
#'
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
#' @return Nothing
#' @export

run_app <- function(...) {
  golem::with_golem_options(
    app = app(),
    golem_opts = list(...)
  )
}