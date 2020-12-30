# Using ODK X Designer for Form Building

## App Organization

The app has been organized in the format:
- main survey questions are in the `census` form and `census` table
- main household member information questions are in the `hh_members` form and the `hh_members` table
- variations of information concerning members are in the table `hh_members` and the forms `hh_member_*`
- questions that involve a 'repeat' are in the respective forms e.g. `hh_latrines` for latrines repeat questions, and `hh_snake_bites` for snake bites repeat questions
- The source files _not the deployable unit_ are in the zipped folder `odkx-bohemia-app-forms` in the repo path `forms/`

## Local Designer Deploy
### Prerequisites
1. Set up the application designer as per the instructions at: https://docs.odk-x.org/app-designer-setup/
2. Proceed to clean up the test apps from the installation as per instructions at: https://docs.odk-x.org/build-app/#cleaning-app-designer

### Launch designer app 
To test this app locally, start the designer by:
 - `cd` into the designer folder
 - type `grunt` 
in the shell of your choice.

_For detailed instructions please refer to: https://docs.odk-x.org/app-designer-launching/#launching-the-application-designer_

### Load the app forms and tables

Import the xlsx files as per the instructions at: https://docs.odk-x.org/build-app/#generating-formdef-json

Load the xls files in the following order for ease of flow 
- `census.xlsx`
    - After saving to file system, copy the `external_choices.csv` to the same folder with the `formdef.json` otherwise app won't load
- `hh_members.xlsx`
- `hh_member_detail.xlsx`
- `hh_member_exit.xlsx`
- `hh_member_new.xlsx`
- `hh_head_info.xlsx`
- `hh_latrines.xlsx`
- `hh_snake_bites.xlsx`
- `hh_member_questions.xlsx`

### Run app on browser
Navigate to `http://localhost:8000/index.html` and you can try out the app 

### Run app using prepopulated data

Prepopulated data should be in the `hh_members.csv` file in the `/app/config/assets/csv/` folder or matching <tablename>.csv file

Add the table and file name for prepopulating the database you need in the `tables.init` file in the `app/config/assets` folder

### Test app on android device
To test the init setup and generally the app on an android device: 

0. If you haven't already; use this resource to install the ODK tools on your android device: https://docs.odk-x.org/basics-install/#installing-odk-x-basic-tools
     - OI File Manager
     - ODK-X Services
     - ODK-X Survey
     - ODK-X Tables

1. Connect the device to your computer via a USB cable

2. Open a cmd or terminal window within the Application Designer directory (the one containing Gruntfile.js), as described in the Application Designer Directory Structure documentation.

3. Type:
    
    `grunt adbpush`

_For detailed instructions please refer to: https://docs.odk-x.org/build-app/#moving-files-to-the-device_

### Notes

After making changes to the xlsx files, always re-upload census if you change it and hh_members as they are the 'parent' tables at the moment

All the forms that share a table should have matching `model` sheets to prevent overwriting or duplication when the sync is done



When you make changes to the models, you need to purge the database




