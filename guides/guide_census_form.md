# How to review the census form

## For collaborators

There are two ways to review the census form: (1) in a web browswer and (2) on your android device. The latter is better (since it more accurately reflects the experience of a fieldworker), but the former is quicker for a fast overview.

### 1. Review the census form in the web browswer
- Use this link: https://odk.enke.to/preview?form=https://xlsform.opendatakit.org/downloads/ez2tx12r/census.xml
- Note, this is only a rought approximation of how the survey will look. Better to use an android device.

### 2. Review the census form on your android device.

#### A. Get ODK Collect onto your android device

- On your android device, go to the Google play store.
- Search for "ODK Collect" and click on "install"

### Getting new form onto tablet

- Open ODK Collect on your android device (phone or tablet)
- Click the three dots in the upper right > General Settings > Server
- Set the following parameters:
```
Type: ODK Aggregate
URL: https://papu.us
Username: data
Password: data
```
- Go back to the main page of the ODK Collect android app
- Select "Get Blank Form". The app will now connect to our server.
- Select the form names "Census1" and click "Get Selected".
- If successful, you will be prompted by a pop-up titled "Downlaod Results" and it will confirm the connection was succesful. Select "OK" (This will bring you back to the Main page")
- On the main page of the app, select "Fill Blank Form" and select your recently uploaded form (a brief window should pop-up "Loading form")
- You may be prompted by the app to allow it to have access to your phone.
- You will be brought to the first page of the form. To continue, swipe left.
- You will not be able to continue the survey unless all required questions are answered (they are indicated).


## For engineers

### During build

- For general guidelines on creating forms in the Bohemia system, see [this guide](guide_forms.md)  
- The form is hosted at https://docs.google.com/spreadsheets/d/16_drw-35haLaBlB6tn92mr6zbIuYorAUDyieGONyGTM/edit#gid=141178862  
- To convert the form to xml, download as xls and then use this converter: https://xlsform.opendatakit.org/
- For styling and documentation see these two guides: [1](https://docs.opendatakit.org/form-styling/), [2](https://xlsform.org/en/)

### Deploy

- Download the xform after conversion from https://xlsform.opendatakit.org
- Go to papu.us  
- Log in  
- Click on "Form Management"  
- Delete the previous form  
- Click on Add new form
- Upload the XML  
