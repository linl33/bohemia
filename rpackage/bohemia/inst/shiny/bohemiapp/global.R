library(dplyr)
library(DT)
library(leaflet)
library(bohemia)
library(sp)
source('functions.R')

# Define a summary data table (from which certain high-level indicators read)
default_aggregate_table <- tibble(forms_submitted = 538,
                          active_fieldworkers = 51,
                          most_recent_submission = 12.6)

# Define a action table example
default_action_table <- tibble(ID = 87:89,
                               Type = c('Anomaly',
                                        'Anomaly',
                                        'Error'),
                               Description = c('3 consecutive houses for one fieldworker with no head-of-household substitute',
                                               'Household with > 100 animals',
                                               'Mismatch between number of household members and number of individual forms')
                               )

# Define a default fieldworkers data
default_fieldworkers <- tibble(id = sort(sample(1:300, size = 10)),
                               name = c('John Doe',
                                        'Jane Doe',
                                        'Abraham Lincoln',
                                        'Maurice Fromage',
                                        'Pepe Birra',
                                        'Ebenezer Scrooge',
                                        'Byron Bryon',
                                        'Anabel García',
                                        'Camille de la Croix',
                                        'Raquel Manhiça'))

# Define a default notificaitons table
default_notifications <- 
  tibble(ID = c(101, 144, 149),
         Type = c('Individual', 'Aggregate', 'Individual'),
         Description = c('Worker 167: 4 days without submissions',
                         'Overall: 12 hours with no submissions',
                         'Worker 003: > 15% missingness on form 20920101'))
