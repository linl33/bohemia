#' Print worker QRs
#'
#' Render a document of pds for a worker
#' @param wid The 3 digit id of the worker (or a vector of IDs)
#' @param size The size of the image
#' @param n The number of images per QR
#' @param output_dir The directory to which the file should be written. If
#' \code{NULL} (the default), the current working directory will be used.
#' @param output_file The name of the file to be written.
#' @import tidyverse
#' @import RPostgres
#' @import DBI
#' @return A pdf will be written
#' @importFrom rmarkdown render
#' @export

print_worker_qrs <- function(wid = seq(0, 999, 1),
                             size = 2,
                             n = 1,
                           output_dir = NULL,
                           output_file = 'qrs.pdf'){

  # If no output directory, make current wd
  if(is.null(output_dir)){
    output_dir <- getwd()
  }
  
  # Adjust the worker id to ensure its the right 3-digit format
  ids <- add_zero(wid, 3)
  
  # Pass them on to the pdf generator
  render_qr_pdf(ids = ids,
                size = size,
                n = n,
                output_dir = output_dir,
                output_file = output_file)
}
