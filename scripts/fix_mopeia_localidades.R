# This is a one-off script. It is not part of the pipeline. Here only for record-keeping.

library(bohemia)

# Get the localities hierarchy
locations <- bohemia::locations

# Replace villages
locations$Village <- bohemia::update_mopeia_locality_names(locations$Village)

locations$Village <- gsub('/', '/ ', locations$Village, fixed = TRUE)
# Fix capitalization
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}
locations$Village <- sapply(tolower(locations$Village), simpleCap)
locations$Village <- gsub('/ ', '/', locations$Village, fixed = TRUE)

# Write a csv for replacing on google sheets
readr::write_csv(locations, '~/Desktop/locations.csv')
