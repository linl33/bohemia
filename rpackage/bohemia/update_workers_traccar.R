library(yaml)
library(bohemia)


# Read in credentials
credentials <- yaml::yaml.load_file('../../credentials/credentials.yaml')

# Syncronize between the worker registrationd data (collected via the shiny app)
# and the traccar server app
sync_workers_traccar(credentials = credentials)
