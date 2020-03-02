# Worker registration and tablet configuration

## Summary

This guide explains how to enroll Bohemia field-workers into the database. This is a straightforward, largely non-technical process, but should only be handled by site data managers.

## Things to know
- Any person who collects any data for the Bohemia project is considered a "worker". This includes data managers, supervisors, etc. who collect recon data.
- Every "worker" must be "registered" in the Bohemia system.
- Every tablet must be configured for that worker.

## Steps

### Step 1: Register the worker

- Go to [THIS SPREADSHEET](https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=490144130).
- Select the tab for your country.
- Enter the following details for the worker on the first available row:
- `First name`
- `Last name`
- `ID of tablet` (TZA; MOZ?)
- `Phone number of tablet` (TZA only)
- `Phone number of person` (ie, their person cell phone number, including country code)
- `Location` (ie, the area they will be deployed)
- `Details` (optional, supplementary details)
- `Start date` (the date they began employment with the project)
- `End date` (the date they stopped working for the project; leave empty for currently employed workers)
- By using the first available row, the QR code / ID number will be the lowest available country-specific number (001-300 for TZA; 301-600 for MOZ; > 600 for other).
- _Never_ delete a row. If a worker leaves the project, his/her ID number is simply retired. It should not be re-used.


### Step 2: Give ID card
- Step 1 (above) will result in a worker being assigned an ID number. The `bohemia_id` of  row will be the worker's ID number for the entirety of the Bohemia project.
- A QR card should be given to the worker, and the worker should be told to memorize / write down their ID number (in case they lose the QR card).
  - These cards will be supplied by Databrew.
  - If you do not yet have the cards, or you need to print replacements, go to https://bohemia.team/operations and click on QR code generator
  - An ID should only be assigned to 1 worker
    - Even in the case of a worker leaving the project, his/her ID should never be re-assigned to someone else
    - Sufficient extra ID numbers / cards exist so that there is no need to "recycle" ID numbers
  - A fieldworker should only be assigned 1 ID.
    - If a QR code is lost, a replacement QR for that ID number should be generated via the tool at bohemia.team/operations.
    - Under no circumstances should a worker be given a new ID number

### Step 3: Set up GPS tracking

- For security and operational reasons, tablet locations will be tracked.
- In order to enable tracking, each tablet must install the Traccar client via the [Google Play Store](https://play.google.com/store/apps/details?id=org.traccar.client)
- After installation, open the Traccar app and provide the following details in configuration:
  - Set the "Device identifier" field to the ID number corresponding to your name:
  - Set the address of the server URL: `http://bohemia.fun`
  - Set the Frequency field to: `60`
  - Set location accuracy to: `high`
  - Do not change the Distance or Angles fields
  - At the top set "Service status" to on/running
  - Click on "Status" in the upper right to ensure that everything is working and data is sent correctly; It should show "Location update"; if it shows anything with the word "failure", email joe@databrew.cc
- More details are available in [this guide on GPS tracking](guide_gps_tracking_android.md)

### Step 4: Set up ODK Collect

- Download/Install [ODKCollect via Google Play](https://play.google.com/store/apps/details?id=org.odk.collect.android&hl=en)
- Open ODKCollect
- Click the three dots in the upper-right hand corner
- Select "General Settings"
- Click "Server"
- Change the server URL to https://bohemia.systems
- Set the credentials to `data` (user) and `data` (password)
- Note that the URL, user, and pass may be different (for your local server)
- More details are available in [this guide on configuring ODK Collect](guide_data_collection_odk.md)
