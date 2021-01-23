# ODKX Uploading Survey Forms to Server Using Android Device

## Introduction

This guide is a description of the steps to follow in order to upload new ODK-X forms to the server. 

#### Overview

The ODK-X suite of applications needed are:

- [OI File Manager](https://github.com/openintents/filemanager/releases)
- [ODK-X Services](https://github.com/odk-x/services/releases/latest)
- [ODK-X Survey](https://github.com/odk-x/survey/releases/latest)
- [ODK-X Tables](https://github.com/odk-x/tables/releases/latest)

See [ODK X Server Client setup](https://github.com/databrew/bohemia/blob/feature/odkx_server_reset_guide/guides/guide_odkx_client.md) for download instructions if you do not yet have the apps above. 

# **** IMPORTANT NOTE: This will erase all data currently on the server! **** 

# Instructions

_If you have previously synced your device with the server (i.e., you have survey forms on your device), follow the steps to 'Clear ODK-X files on your Android device'. If not, then skip to 'Push survey forms from your computer to Android device'_

## Clear ODK-X files on your Android device

- Open OI File Manager 
- Open the `opendatakit` folder, where you should see a single folder `default` 
- Press and hold the `default` folder and you will see a trash can option at the top of the page 
- Click it to delete the default folder
- This should delete all the files currently on ODK-X Survey and reset the server settings

## Push survey forms from your computer to Android device

- Connect the device to your computer via a USB cable.
_Note: You must have USB debugging enabled on your device in order to perform the next step. See [these instructions](https://www.phonearena.com/news/How-to-enable-USB-debugging-on-Android_id53909) for help._

- Open a cmd or terminal window and cd into the Application Designer directory
- Use the command `grunt adbpush` to push the designer files from your computer onto your phone/tablet
- Once done, you should see all your files in the OI File Manager > `opendatakit` > `default` folder

_For detailed instructions please refer to: https://docs.odk-x.org/build-app/#moving-files-to-the-device_

## Set up server connection 

- Open the ODK-X Survey app
- Press the settings button (gear icon in upper right)  
- Select "Server Settings"  
- Click "Server URL"  
- Set the server URL to https://databrew.app  
- Set the server sign-on credential as "Username"  
- Sign in using the *super user* credentials 
- Click the 'back' button to return to the previous page
- An "Authenticate credentials" pop-up will show show up; Click "Authenticate New User".  
- Click "Verify User Permissions"  
- You should see a "Verification successful" window. Click "OK".  

## Uploading new forms to the server

- You should see a "Reset App Server" button at the bottom right corner of the page
- A pop up that says "Confirm Reset App Server" will appear
- Click "Reset" to upload the updated survey forms to the server

