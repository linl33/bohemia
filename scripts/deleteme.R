make <- function(n){
  out <- paste0('concat(${first_name', n, '},";",${last_name', n, '},";",${pid', n, '})\n')
  out <- gsub(' ', '_', out)
  out
}

for(i in 1:20){
  cat(make(i))
}


old <-   paste0('concat(${first_name', n, '}, " ", ${last_name', n, '}, " (", ${pid', n, '}, ")")')

concat(substring-before(${idv_id_permid_label}, ';'))