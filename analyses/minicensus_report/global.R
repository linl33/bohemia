library(leaflet)
library(sp)
# library(leaflet.providers)
library(leaflet.extras)
library(bohemia)
library(knitr)
library(kableExtra)
library(tidyverse)
library(yaml)
library(gsheet)
library(geosphere)
library(sf)
library(rgeos)
library(htmlTable)
library(readxl)

# Read in xls form
xf <- read_excel('../../forms/minicensus/minicensus.xlsx') %>% dplyr::select(name,
                                                      en = `label::English`,
                                                      sw = `label::Swahili`)

# read in creds
creds <- read_yaml('../../credentials/credentials.yaml')

# Read in answer key
if(!'data.RData' %in% dir()){
  data <- odk_get_data(
    url = creds$tza_odk_server,
    id = 'minicensus',
    id2 = NULL,
    unknown_id2 = FALSE,
    # uuids = NULL,
    exclude_uuids = c("uuid:06e9b414-4c82-4097-bd4a-e31065f1265e",
                      "uuid:641eaadd-1e47-4e48-99c2-02c13de93b0a",
                      "uuid:bab37889-d8a8-4b6c-984c-a99e2b9926ce"),
    user = creds$tza_odk_user,
    password = creds$tza_odk_pass
  )
  save(data, file = 'data.RData')
} else {
  load('data.RData')
}

