#' Decrypt fields in a csv file
#' 
#' @param csv_file The path to the csv file with encrypted data
#' @param enc_columns A list of the column headings that contain the encrypted values
#' @param keyfile The path to the secret key pem file
#' @return CSV file with data in specified columns decrypted
#' 

suppressMessages({
    library(bohemia)
})

csv_file <- 'tmp/itemsets.csv'
enc_columns <- list('fname','lname')
keyfile <- 'rpackage/bohemia/bohemia_priv.pem'


csv_contents <- read.csv(csv_file, TRUE, sep=',')
enc_columns <- unlist(enc_columns)
    
for(col_name in enc_columns){
    col_content <- csv_contents[[col_name]]
    dec_content <- decrypt_private_data(col_content, keyfile)
    csv_contents[[col_name]] <- dec_content
}

readr::write_csv(csv_contents, file = "decrypted_csv_data.csv")
message("Decrypted csv file title 'decrypted_csv_data.csv' created at: ", getwd())
