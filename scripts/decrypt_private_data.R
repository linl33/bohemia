#' Decrypt data provided using the provided private key
#' 
#' @param data The private data to be decrypted
#' @param key The filename where the key to be used is stored
#' @return A plain text string
#' @import PKI
#' @export

decrypt_private_data <- function(data, key='bohemia_priv.pem'){
  priv.pem <- load(key, envir = parent.frame(), verbose = FALSE)
  # load the public key
  priv.k <- PKI.load.key(priv.pem)
  # decrypt with private key
  x <- rawToChar(PKI.decrypt(data, priv.k))
  print(x)
  return x
}