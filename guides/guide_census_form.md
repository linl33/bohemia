# How to review the census form

## For collaborators

There are two ways to review the census form: (1) in a web browswer and (2) on your android device. The latter is better (since it more accurately reflects the experience of a fieldworker), but the former is quicker for a fast overview.

### 1. Review the census form in the web browswer

### 2. Review the census form on your android device.

#### A. Get ODK Collect onto your android device

- BEN FILL THIS OUT

### Getting new form onto tablet

- Open ODK Collect on the tablet
- Click the three dots in the upper right > General Settings > Server
- Set the following parameters:
```
Type: ODK Aggregate
URL: https://papu.us
Username: data
Password: data
```
- Go back to the main page of the ODK Collect android app
- Select "Get Blank Form". The app will now connect to our server
- Select the form and click "Get Selected"
- On the main page of the app, select "Fill Blank Form" and select your recently uploaded form
- You can now fill out the form




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
