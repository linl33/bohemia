# Bohemia census: VA teams

## Context

- The Bohemia project will collect verbal autopsy (VA) data following the death of someone in the study area
- A team (the "VA team") will carry out post-mortem interviews using the digital [VA form](https://docs.google.com/spreadsheets/d/1BuRSJdWmottUW8SDnh8nGTkLCeTjEX3LgkRpaPvoKjE/edit#gid=1264701015)
  - These interviews will be carried out by someone _other_ than the census team.
  - These interviews will be carried out during a _separate_ visit from the census visit.

## Operational flow

- Census fieldworker identifies a death (or deaths) (question 69 in the census household form: any deaths in past 12 months)
- For each death, the census fieldworker collects basic data (questions 69b-69k) pertaining to:
  - Name, ID, gender, place of birth of the deceased
  - Place, date of death
- Census fieldworker submits form to server
- Server processes data
- Data manager is automatically notified of the death(s) and the relevant meta-information (household number and location, fieldworker in question, information of deceased person, etc.)
- Data manager deploys a VA team/individual to fill out the VA form
- VA team goes to site in question, speaks with household head, and carries out a VA interview

## Accessing the form

- The VA form will be hosted on the same server as the other Bohemia census forms (recon, census, etc.).
- Refer to the general [Data collection guide](https://github.com/databrew/bohemia/blob/master/guides/guide_data_collection_odk.md) for instructions on configuring the application to retrieve the VA form
