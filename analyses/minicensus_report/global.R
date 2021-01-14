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
xf <- read_excel('../../forms/smallcensusb/smallcensusb.xlsx') %>% dplyr::select(name,
                                                      en = `label::English`,
                                                      sw = `label::Swahili`)

# Read in imani results
imani <- read_csv('imani.csv')

# read in creds
creds <- read_yaml('../../credentials/credentials.yaml')



# Read in answer key
if(!'data.RData' %in% dir()){
  
  uuids <- imani$`meta:instanceID`
  data <- odk_get_data(
    url = creds$databrew_odk_server,
    id = 'smallcensusb',
    id2 = NULL,
    unknown_id2 = FALSE,
    uuids = uuids,
    user = creds$databrew_odk_user,
    password = creds$databrew_odk_pass
  )
  save(data, file = 'data.RData')
} else {
  load('data.RData')
}

