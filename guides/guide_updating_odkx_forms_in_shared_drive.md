# ODK-X Folder/Survey Form Organization on Google Drive

## Google Drive Organization 

The most up-to-date survey forms and app designer files are located in the DataBrew Bohemia Google Drive's `ODK-X forms` > `odk-x-v0.1` folder. 

Inside the `odk-x-v0.1` folder is the `odkx-bohemia-app-forms` folder, where all the xlsx form definition files (e.g., census.xlsx, hh_member.xlsx, etc) and external_choices csv files are located. These files can be edited directly when making updates to the survey form definitions. 

Within -`odk-x-v0.1`, there is also a folder called `app`, which is a copy of the the most updated `app` folder from the ODK-X Application Designer Directory. 

## Workflow

Once an xlsx file is edited, you will need to (1) download the file locally and (2) convert it to a .json file using the ODK-X Application Designer's XLSX Converter in order to update the actual survey. 

The newly converted .json file will be located your ODK-X Application Designer directory's `app/config/tables/(tablename)/(formname)` folder.

You can now purge the database in the ODK-X Application Designer and see your new updates on your local host or `grunt adpush` the updated form definition(s) to your Android device for testing. 

Once done making all the changes to the forms and ensuring everything works, delete the current `app` folder in the `odk-x-v0.1` folder in the Google Drive and replace it with the updated `app` folder from your local ODK-X Application Designer directory. 

