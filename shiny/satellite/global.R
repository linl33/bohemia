library(leaflet)
library(sp)
# library(leaflet.providers)
library(leaflet.extras)

# at the time of writing, version 1.8.0
# pd <- providers_default()


## Retrieve data using bohemia package
# mopeia2 <- bohemia::mopeia2
# rufiji2 <- bohemia::rufiji2
# mopeia_health_facilities <- bohemia::mopeia_health_facilities
# rufiji_health_facilities <- bohemia::rufiji_health_facilities
# save(mopeia2, file = 'data/mopeia2.rda')
# save(rufiji2, file = 'data/rufiji2.rda')
# save(mopeia_health_facilities, file = 'data/mopeia_health_facilities.rda')
# save(rufiji_health_facilities, file = 'data/rufiji_health_facilities.rda')

load('data/mopeia2.rda')
load('data/rufiji2.rda')
load('data/mopeia_health_facilities.rda')
load('data/rufiji_health_facilities.rda')
