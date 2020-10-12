# Anomalies and errors

## Overview

The Bohemia data pipeline consists of a semi-structured "data cleaning" process wherein anomalies and errors are automatically identified and data managers provide "resolutions" in a semi-structured format via web app. This document describes the process.

Note: this document only refers to "in-app" anomalies and errors (ie, corrections to the database _after_ data has already been collected). "In-form" warnings and constraints are a different process.

## Registry of anomalies and errors

- A registry of anomalies and errors exists in spreadsheet format [HERE](https://docs.google.com/spreadsheets/d/1MH4rLmmmQSkNBDpSB9bOXmde_-n-U9MbRuVCfg_VHNI/edit#gid=0).
- In this registry, each row is a "check". For example, "check to see if there are any pregnant people younger than 13".
- Each "check" gets run against the data for a site:
  - If the check "passes" (ie, no anomaly or error is detected), no action is required.
  - If the check "fails", action is required (to be taken by the data manager):
    - If the failed check consisted of an anomaly, the "action" can be one of three things:
      1. Confirm correctness (ie, "this person is indeed pregnant")  
      2. Delete (ie, "this person does not exist")  
      3. Modify (ie, "this person is indeed 13, but not pregnant")  
    - If the failed check consisted of an error, the "action" can be only the latter two items (ie, one cannot confirm correctness of an error)
- The registry is maintained by Databrew. Changes to the registry should be carried out in coordination with Databrew.

## Code standards for the registry

- The registry consists of two columns for writing code: `identification_code` and `incident_code`.  
- The standards for writing conformant code are as follows:
  - Refer to tables with a `data$` prefix.
  - `identification_code` should produce a dataframe named `result`.  
  - `incident_code` should manipulate one row of `result` (referred to as `result_row`) so as to generate a character vector of length 1 (the text to be shown to the data manager explaining the error and action required).  

In order to test out writing `identification_code` and `incident_code` snippets, a developer can set up her environment as follows (assuming at Bohemia project directory):

```
library(yaml)
library(bohemia)
library(RPostgres)
library(dplyr)
creds <- yaml::yaml.load_file('credentials/credentials.yaml')

psql_end_point = creds$endpoint
psql_user = creds$psql_master_username
psql_pass = creds$psql_master_password
drv <- RPostgres::Postgres()
con <- dbConnect(drv, dbname='bohemia', host=psql_end_point,
                 port=5432,
                 user=psql_user, password=psql_pass)

# Read in data
 data <- list()
 main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main"))
 data$minicensus_main <- main
 ok_uuids <- paste0("(",paste0("'",main$instance_id,"'", collapse=","),")")

 repeat_names <- c("minicensus_people",
                   "minicensus_repeat_death_info",
                   "minicensus_repeat_hh_sub",
                   "minicensus_repeat_mosquito_net",
                   "minicensus_repeat_water")
 for(i in 1:length(repeat_names)){
   this_name <- repeat_names[i]
   this_data <- dbGetQuery(con, paste0("SELECT * FROM clean_", this_name, " WHERE instance_id IN ", ok_uuids))
   data[[this_name]] <- this_data
 }
 # Read in enumerations data
 enumerations <- dbGetQuery(con, "SELECT * FROM clean_enumerations")
 data$enumerations <- enumerations

# # Read in va data
va <- dbGetQuery(con, "SELECT * FROM clean_va")
data$va <- va
 # Read in refusals data
 refusals <- dbGetQuery(con, "SELECT * FROM clean_refusals")
 data$refusals <- refusals
dbDisconnect(con)
```

The developer now has an object named `data` to be operated on.  

## Flow for identification and exposition of anomalies and errors

1. Anomaly and error _types_ are registered in [the anomaly and error registry](https://docs.google.com/spreadsheets/d/1MH4rLmmmQSkNBDpSB9bOXmde_-n-U9MbRuVCfg_VHNI/edit#gid=0)  
2. The Bohemia R package function `identify_anomalies_and_errors` is run in the back-end of Bohemia web application  
3. The result of `identify_anomalies_and_errors` (ie, a long list of errors and anomalies) is exposed in a table in the web-app  
4. Data managers go row-by-row in the table and submit corrections / confirmations (ie, semi-structured comments regarding which remediative action should be taken).  
5. The corrections / confirmations submitted by the data managers get stored in the `corrections` table in the Bohemia database.  
6. Databrew codifies corrections in the `scripts/clean_database.R` script. This serves as both (a) a functional script to implement corrections, (b) a log of all changes to "raw" data.

## The `corrections` table  

- The `corrections` table is a table is the Bohemia PostgreSQL database with one row for each anomaly / error identified via the previously-mentioned mechanisms.  
- The `corrections` table consists of the following columns:
  - `id`: the ID of the anomaly, as generated by `identify_anomalies_and_errors`
  - `action`: the action to be taken (free text), as indicated by the data manager(s).  
  - `done`: whether the action has been taken or not, as indicated by Databrew.  
  - `done_by`: who (Databrew team member) implemented the action.  
- Rows of the `corrections` table are generated by the Shiny app (ie, when a data manager indicates correction to be made)  
- The `done` and `done_by` columns of the `corrections` table are modified by Databrew (following the former)

## Code standards for database "cleaning" code  

- Corrections are codified in `scripts/clean_database.R`  
- Running this script takes the "raw" data, modifies it (individual entries, each corresponding to an entry in the `corrections` table), and then generates "clean" data with `clean_` prefixes in the database.  
