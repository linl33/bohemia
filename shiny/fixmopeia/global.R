library(dplyr)
library(leaflet)
library(readr)
library(rgeos)

# Get mopeia raw (imperfect) data
# library(bohemia)
# mopeia_hamlet_details <- bohemia::mopeia_hamlet_details
# save(mopeia_hamlet_details, file = 'data/mopeia_hamlet_details.RData')
# dir.create('data')
# file.copy(from = '../../rpackage/bohemia/data-raw/mopeia_households_uncorrected.RData',
#           to = 'data/mopeia_households_uncorrected.RData', overwrite = T)
# mopeia2 <- bohemia::mopeia2
# save(mopeia2, file = 'data/mopeia2.RData')
load('data/mopeia_hamlet_details.RData')
load('data/mopeia_households_uncorrected.RData')
load('data/mopeia2.RData')


# Define ids
ids <- sort(unique(mopeia_hamlet_details$id))

# # Get the starting bad houses
# out <- tibble(id = c(1234567890))
# write_csv(out, 'data/bh.csv')
starting_bad_houses <- readr::read_csv('data/bh.csv')
starting_bad_houses <- starting_bad_houses$id
