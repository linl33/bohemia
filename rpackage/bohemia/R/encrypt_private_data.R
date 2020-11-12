#' Encrypt data provided using the provided public key
#' 
#' @param data The private data to be encrypted
#' @param keyfile The filename (plus full file path) where the key to be used is stored
#' @return A 256 char encoded string
#' @import PKI
#' @export

encrypt_private_data <- function(data, keyfile){
  # load the public key
  pub_key <- PKI.load.key(format="PEM", private="FALSE", file=keyfile)
  # encrypt with the public key
  anon_d <- PKI.encrypt(charToRaw(data), pub_key)

  return anon_d
}
  