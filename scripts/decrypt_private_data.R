#' Decrypt data provided using the provided private key
#' 
#' @param data The private data to be decrypted
#' @param keyfile The filename where the key to be used is stored
#' @return A plain text string
#' @import PKI
#' @export

decrypt_private_data <- function(data, keyfile='bohemia_priv.pem'){
  priv.pem <- read.delim(keyfile)
  # load the public key
  priv.k <- PKI.load.key(priv.pem)
  # decrypt with private key
  x <- rawToChar(PKI.decrypt(data, priv.k))
  print(x)
  return x
}