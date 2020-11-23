library(bohemia)
library(dplyr)
library(RPostgres)
library(DBI)
is_local <- TRUE
the_country <- 'Mozambique'
source('../R/app_functions.R')
data <- load_odk_data(the_country = the_country, local = is_local, efficient = FALSE)
for(i in 1:length(data)){
  assign(
    names(data)[i],
    data[[i]],
    envir = .GlobalEnv
  )
}
con <- get_db_connection(local = is_local)
anomalies <- dbGetQuery(conn = con,
                        statement = paste0("SELECT * FROM anomalies WHERE country = '", the_country, "'"))
dbDisconnect(con)

# Join corrections and anomalies
corrections_sub <- corrections
corrections_sub$is_in <- corrections_sub$id %in% anomalies$id

corrections_sub %>% filter(!is_in) %>% View

x = anomalies %>%
  left_join(corrections)
