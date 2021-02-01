# ODKX Uploading Survey Forms to Server Using Android Device

## Introduction

This guide is a description of the steps to follow in order to upload new/updated ODK-X survey forms to the server. This will not delete the data already on the server. 

#### Overview

The ODK-X suite of applications needed are:

- [OI File Manager](https://github.com/openintents/filemanager/releases)
- [ODK-X Services](https://github.com/odk-x/services/releases/latest)
- [ODK-X Survey](https://github.com/odk-x/survey/releases/latest)
- [ODK-X Tables](https://github.com/odk-x/tables/releases/latest)

See [ODK X Server Client setup](https://github.com/databrew/bohemia/blob/feature/odkx_server_reset_guide/guides/guide_odkx_client.md) for download instructions if you do not yet have the apps above.

You will also need to have the ODK-X Application Designer downloaded on your computer.  [You can download it from  here](https://github.com/odk-x/app-designer/releases/tag/2.1.7) if you don't already have it. 

# Instructions

## Clear ODK-X files on your Android device

- Open OI File Manager 
- Open the `opendatakit` folder, where you should see a single folder `default` 
- Press and hold the `default` folder and you will see a trash can icon at the top of the page 
- Click it to delete the `default` folder
- This should delete all the files currently on ODK-X Survey and reset the server settings

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

## Ensure that you have the most updated version of the ODK-X census form in your Application Designer

- Open your cmd or terminal window, cd into your `databrew/bohemia` folder, and pull the Master branch
- Within the `databrew/bohemia/odkx/` folder, there is a folder called `app`
- If you open your ODK-X Application Designer folder, you will see a folder named `app` here as well
- Delete the `app` folder in your ODK-X Application Designer and replace it with a copy of the `app` folder found in `databrew/bohemia/odkx/` 

## Push the ODK-X Application Designer files from your computer to Android device

- Connect the device to your computer via a USB cable.
_Note: You must have USB debugging enabled on your device in order to perform the next step. See [these instructions](https://www.phonearena.com/news/How-to-enable-USB-debugging-on-Android_id53909) for help._

- Open a cmd or terminal window and cd into the ODK-X Application Designer directory 
- Use the command `grunt adbpush` to push the designer files from your computer onto your phone/tablet
- Once done, you should see all your new files in the OI File Manager > `opendatakit` > `default` folder

_For detailed instructions on moving files from computer to Android device, please refer to: https://docs.odk-x.org/build-app/#moving-files-to-the-device_

## Uploading new survey forms to the server
- Return to ODK-X Survey 
- Click the 'reload' icon at the top of the page 
- The Server URL should be https://databrew.app and the username/password is that of the *super user* account
- You should see a "Reset App Server" button at the bottom right corner of the page. Click it. 
- A pop up that says "Confirm Reset App Server" will appear
- Click "Reset" to upload the updated survey forms to the server

If you wish to delete all the data on the server, please refer to [this guide](https://github.com/databrew/bohemia/blob/master/guides/guide_odkx_suitcase.md#reset-the-server)

