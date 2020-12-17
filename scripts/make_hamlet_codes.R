library(gsheet)
library(dplyr)

locations <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765')

prohibited <- locations$code

try_code <- function(hamlet, prohibited = c()){
  splat <- toupper(unlist(strsplit(hamlet, split = '')))
  asnum <- as.numeric(splat)
  splat <- splat[is.na(asnum)]
  splat <- gsub(' ', '', splat)
  splat <- splat[splat != '']
  out <- paste0(splat[1:3], collapse = '')
  while(out %in% prohibited){
    out <- paste0(sample(splat, 3, replace = TRUE), collapse = '')
  }
  return(out)
}

need_code <- locations[is.na(locations$code),]

for(i in 1:nrow(need_code)){
  this_hamlet <- need_code$Hamlet[i]
  new_code <- try_code(this_hamlet, prohibited = prohibited)
  need_code$code[i] <- new_code
  prohibited <- c(prohibited, new_code)
}
