#' Create QR
#'
#' Generate a QR code for an ID number
#' @param id The id number for which the qr code is being created
#' @return A QR code
#' @import qrcode
#' @export

create_qr <- function(id = '01234567'){
  require(qrcode)
  qrcode::qrcode_gen(dataString = as.character(id),
                     ErrorCorrectionLevel = 'H')
}
