#' Encrypt data provided using the provided public key
#' 
#' @param data The private data to be encrypted
#' @param keyfile The filename (plus full file path) where the key to be used is stored
#' @return A 256 char encoded string
#' @import PKI
#' @import yaml
#' @export

encrypt_private_data <- function(data='Wanjiru Kimani', keyfile='bohemia_pub.pem'){
  pub.pem <- read.delim(keyfile) #@joe to advise on how to read from file correctly, getting error - key must be a raw vector on L13
  # load the public key
  pub.k <- PKI.load.key(pub.pem)
  # encrypt with the public key
  x <- PKI.encrypt(charToRaw(data), pub.k)
  print(x)
  return x
}
  