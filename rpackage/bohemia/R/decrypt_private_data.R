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
  plain_d <- rawToChar(PKI.decrypt(data, priv_key))
  
  return plain_d
}