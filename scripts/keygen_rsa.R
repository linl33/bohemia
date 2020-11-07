#' Generate public private key pairs
#' 
#' @return A pair of pem key files
#' @import PKI
#' @export 

# generate 2048-bit RSA key
key <- PKI.genRSAkey(bits = 2048L)
# extract private and public parts as PEM
priv.pem <- PKI.save.key(key)
pub.pem <- PKI.save.key(key, private=FALSE)
# save the key parts into file
write(priv.pem, file='bohemia_priv.pem')
write(pub.pem, file='bohemia_pub.pem')
# compute SHA1 hash (fingerprint) of the public key
PKI.digest(PKI.save.key(key, "DER", private=FALSE))