#' Decrypt data provided using the provided private key
#' 
#' @param data The private data to be decrypted
#' @param keyfile The filename where the key to be used is stored
#' @return A plain text string
#' @import PKI
#' @export

decrypt_private_data <- function(data, keyfile){
  # load the private key
  priv_key <- PKI.load.key(format="PEM", file=keyfile)
  # decrypt with private key
  ll <- length(data)
  out_vector <- c()
  for(j in 1:ll){
    this_data <- data[j]
    this_data <- unlist(strsplit(this_data, ' '))
    this_data <- as.raw(as.hexmode(this_data))
    this_decrypted <- rawToChar(PKI.decrypt(this_data, priv_key), multiple = FALSE)
    out_vector[j] <- this_decrypted
  }
  return(out_vector)
}