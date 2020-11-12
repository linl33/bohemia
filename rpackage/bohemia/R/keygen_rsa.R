#' Generate public private key pairs
#' 
#' @return A pair of pem key files
#' @import PKI
#' @export 

# generate 2048-bit RSA key
key <- PKI.genRSAkey(bits = 2048L)

# extract private and public parts as PEM and save the key parts into files
bohemia_priv.pem <- PKI.save.key(key, format="PEM", target="bohemia_priv.pem")
bohemia_pub.pem <- PKI.save.key(key, format="PEM", private=FALSE, target="bohemia_pub.pem")

# compute SHA1 hash (fingerprint) of the public key
PKI.digest(PKI.save.key(key, "DER", private=FALSE))