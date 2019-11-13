#' Render QR pdf
#'
#' Render a pdf of QR codes
#' @param ids A character vector of ID numbers. If \code{NULL} (the
#' default), all IDs will be used
#' @param output_dir The directory to which the file should be written. If
#' \code{NULL} (the default), the current working directory will be used.
#' @param output_file The name of the file to be written.
#' @return An html will be written
#' @importFrom rmarkdown render
#' @export

render_qr_pdf <- function(ids = NULL,
                           output_dir = NULL,
                           output_file = 'paper.pdf'){

  # If no output directory, make current wd
  if(is.null(output_dir)){
    output_dir <- getwd()
  }

  # If not date, use today's
  if(is.null(date)){
    ids <- 1:10
  }

  # Combine parameters into a list, so as to pass to Rmd
  parameters <- list(ids = ids)

  # Find location the rmd to knit
  file_to_knit <-
    system.file('rmd/qr.Rmd',
                package='bohemia')

  # Knit file
  rmarkdown::render(file_to_knit,
                    output_dir = output_dir,
                    output_file = output_file,
                    params = parameters)
}
