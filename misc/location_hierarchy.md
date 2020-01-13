# Location hierarchy

This document gives an overview of how the location hierarchy is handled, created, etc.

## Step 1: Populate the spreadsheet

The location hierarchy google doc (https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765) is populated manually by copy-pasting the different docs sent from sites.

## Step 2: Process the spreadsheet

The code in `bohemia/rpackage/bohemia/data-raw/create_data_files.R` contains a few lines for processing the names (capitalizing uniformly, updating Mopeia localities, etc.). Look for the function `update_mopeia_locality_names`. Run those lines, and then copy-paste the resultant csv back to google sheets.

## Step 3: Generate the format for choices for ODK

The function defined in `bohemia/rpackage/bohemia/odk_create_location_choices.R` formats correctly for the ODK choices page. Run it. And write the two elements of the list output to local csvs (for later copy-pasting into the relevant spreadsheets).

## Step 4: Copy-paste into spreadsheets

- Any ODK form which uses the hierarchy should get it copy-pasted:
  - Census: https://docs.google.com/spreadsheets/d/16_drw-35haLaBlB6tn92mr6zbIuYorAUDyieGONyGTM/edit#gid=286602728
  - Recon: https://docs.google.com/spreadsheets/d/1xe8WrTGAUsf57InDQPIQPfnKXc7FwjpHy1aZKiA-SLw/edit#gid=0
- The shiny apps may also need to be updated, as well as documentation
