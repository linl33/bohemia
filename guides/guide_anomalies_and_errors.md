# Anomalies and errors

## Overview

The Bohemia data pipeline consists of a semi-structured "data cleaning" process wherein anomalies and errors are automatically identified and data managers provide "resolutions" in a semi-structured format via web app. This document describes the process.

Note: this document only refers to "in-app" anomalies and errors (ie, corrections to the database _after_ data has already been collected). "In-form" warnings and constraints are a different process.

## Schema

The "data cleaning" process can be understood visually below:

![](img/data_cleaning.png)

# Operational elements

## Processes

The data cleaning process consists of the following processes:

- Automatically identify anomalies and errors on raw data
- Manually submit "resolutions" (fixes) to these anomalies and errors  
- Manually write SQL code to implement resolutions  
- Run SQL code so as to generate "clean" data  
- Infinitely repeat process (but now running the anomaly and error identification code on the "cleaned" rather than raw data)

## Roles  
Operationally, the data cleaning process requires input from at least the following two roles:

1. Site data manager: receives anomaly and error notifications in the "Alerts" section of the app, and submits the resolution ("fix") for those anomalies/errors  
2. Databrew: receives fix requests from site data manager, and "translates" those requests to SQL operations which modify the underlying data

The site data manager will sometimes be able to resolve an alert on his own. For example, he may recognize that a submission has been flagged for having too many household members, but he knows that this particular submission was just a technical test he carried out (and therefore submits the modification request of "delete"). In many cases, however, he will require other roles in order to properly carry out function 1. Specifically, he'll need to interact with:
- Supervisors (in order to request confirmations / corrections regarding an erroneous or anomalous event)  
- Fieldworkers (in order to ask for confirmations / corrections regarding an erroneous or anomalous event)  
- Databrew (in order to request, if applicable, supplementary data on the error/anomaly)

# Engineering elements

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
6. Databrew codifies corrections in the `scripts/clean_database.R` script. This serves as a functional script to implement corrections.
7. The output of the `scripts/clean_database.R` is stored in the `anomalies_corrections_log` table which acts a log of all changes to "raw" data.

## The `corrections` table  

- The `corrections` table is a table is the Bohemia PostgreSQL database with one row for each anomaly / error identified via the previously-mentioned mechanisms.  
- The `corrections` table consists of the following columns:
  - `id`: the ID of the anomaly, as generated by `identify_anomalies_and_errors`
  - `response_details`: the action to be taken (free text), as indicated by the data manager(s).  
  - `resolved_by`: the person (fieldworker, etc.) who resolved the issue  
  - `resolution_method`: how the issue was resolved (for example, house visit, phone call, etc.).
  - `resolution_date`: the date that the resolution took place
  - `submitted_by`: the data manager who submitted the resolution (captured automatically)
  - `submitted_at`: the date-time at which the data manager submitted the resolution
  - `done`: invisible in web-app; whether the action has been taken or not, as indicated by Databrew.  
  - `done_by`: invisible in web-app; who (Databrew team member) implemented the action.  
- Rows of the `corrections` table are generated by the Shiny app (ie, when a data manager indicates correction to be made)  
- The `done` and `done_by` columns of the `corrections` table are modified by Databrew (following the former)

## Code standards for database "cleaning" code  

- Corrections are codified in `scripts/clean_database.R`  
- Running this script takes:

    - the "raw" data (individual entries, each corresponding to an entry in the `corrections` table), 
    - checks the `response_details` specified in the `corrections` entry
    - if the `response_detail` is already available in the `preset_correction_steps` applies these steps,
    - if the `response_detail` is not available, the user creates a custom query and applies it.
    - then generates "clean" data with `clean_` prefixes in the database.
    - and saves the actual query used in the correction in the `anomaly_corrections_log` table.

### Detailed Execution Steps for the Script

Step 1:
NOTE The first step is manual review of the correction. This means:
   1. Examine the response_details provided
   2. Add classification for it i.e. `resolution_category`
   3. Add the corrective action label for it i.e. `resolution_action`
   4. If the `resolution_category` and `resolution_action` match an entry in the `preset_correction_steps` proceed with Step 2
   5. If they don't exist, then add an entry to the `preset_correction_steps` and add the query to apply in the `correction_steps` 

Step 2: 
Now that the correction has a `preset_correction_steps` entry for its `resolution_category` and `resolution_action`.
Check if the `preset_correction_steps` have a corresponding function in R and call it with the required params if it does.
If no specific function exists:
  - Populate the following variables:
      - anomaly_id
      - correction_id
      - user_email
      - preset_correction_steps_id
      - correction_steps_list
      - correction_query_params_list
  - Run the correction_steps keeping in line with the example change described below:
```
  anomaly_id <- fake_error_type_0017eea6-7239-433d-827a-3bd3d4c65c4e
  correction_id <- 776627ac-1c8c-4fd7-92f0-529a7f2749e8
  user_email <- 'joe@brew.cc'
  preset_correction_steps_id <- 5e86ee69-76a4-46a7-bdd1-6a5464d38b70
  correction_steps_list <- c(
    "UPDATE %s SET hh_possessions = %s WHERE instance_id= %s", 
    "UPDATE %s SET done = %s, done_by = %s WHERE id=%s"
  )
  correction_query_params_list <- c(
    c(clean_minicensus_main, 'joetest', '0017eea6-7239-433d-827a-3bd3d4c65c4e' ), 
    c(corrections, 'true', 'Joe Brew', 'fake_error_type_0017eea6-7239-433d-827a-3bd3d4c65c4e'))

  # This part executes the change
  for (i in 1:length(correction_steps_list)){
    statement <- paste0(corrections_steps_list[i], correction_query_param_list[i])
    dbExecute(conn = con,
          statement = statement)
    # This part logs the action in the log table and is standard for all actions therefore this query should not be in the list
    dbExecute(conn = con,
          statement = paste0("INSERT INTO anomaly_corrections_log 
                                (anomaly_id, correction_id, preset_steps_id, user_id, log_details) VALUES 
                                (anomaly_id, correction_id, preset_correction_steps_id, user_email, statement)))
```

    
### Detailed Schema Focused on the Tables Affected By Script

_NOTE The green labels indicate the new columns and models_

![](img/anomalies_detail_schema.png)


## TODO 

[] Add example query for insertion to the `preset_correction_steps`

[] Add a migration process to move the anomalies to the database table

[] Define the rules for the `resolution_category` and `resolution_action` values (_should be pre-agreed to be in a lookup list for the user applying them to reference_)

[] Iterate on the better way to separate the manual step 1 and formalize it for eventually having step 2 be fully automated as a batch job.