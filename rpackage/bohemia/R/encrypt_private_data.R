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
  
  ll <- length(data)
  out_vector <- c()
  for(j in 1:ll){
    this_data <- data[j]
    if(is.na(this_data)){
      this_encrypted <- ''
    } else {
      this_encrypted <- PKI.encrypt(charToRaw(this_data), pub_key)
      this_encrypted <- paste0(this_encrypted, collapse = ' ') 
    }
    out_vector[j] <- this_encrypted
  }
  return(out_vector)
}
