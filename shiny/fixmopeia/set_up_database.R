library(dplyr)
library(DBI)
library(RPostgres)
# # Get the starting bad houses
# out <- tibble(id = c(1234567890))
# write_csv(out, 'data/bh.csv')
starting_bad_houses <- readr::read_csv('data/bh.csv')
con <- dbConnect(drv = RPostgres::Postgres(),
                 dbname = 'fixmopeia')

dbWriteTable(conn = con,
             name = 'starting_bad_houses',
             value = starting_bad_houses, 
             overwrite = TRUE)
dbDisconnect(conn = con)


