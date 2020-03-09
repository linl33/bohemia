library(dplyr)
library(leaflet)
library(readr)
library(rgeos)
library(DBI)
library(RPostgres)

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

# Read in the bad houses
con <- dbConnect(drv = RPostgres::Postgres(),
                 dbname = 'fixmopeia')
starting_bad_houses <- dbReadTable(conn = con, name = 'starting_bad_houses')

starting_bad_houses <- starting_bad_houses$id
