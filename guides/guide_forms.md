# How to create a form for the Bohemia project

The data _collection_ component of the Bohemia data system is built on the ODK framework, allowing for the creation and modification of survey forms specific to the Bohemia project's different study components. This guide shows how to create and deploy a form. For the purpose of this example, it assumes your OpenHDS admin user/password is data/data.

## Start creating a form

- If you don't have much experience with xlsforms, you'll likely want to use the online drag/drop tool at https://build.opendatakit.org/
- Create a user account and log in
- Give the form a name by clicking "rename" in the upper left (ie, "fake")
- Add questions by selecting the question type from the bottom
- As you create questions, regularly save buy selecting "File -> Save"
- Once your questions have been created, click File -> Export to XLSForm
- Save the file locally as a `.xlsx` file (excel)

## How to further modify your form

- If your form is complex, you may need to make further modifications in a spreadsheet editor
- Do so with your recently downloaded `.xlsx` file  
- Refer to the guides:
  - https://docs.opendatakit.org/openrosa-form-submission/
  - https://xlsform.org/en/#external-xml-data


## Converting the form to XML

- Once you're done with creating your form in excel, you'll need to export to XML format
- Go to https://opendatakit.org/xlsform/
- Submit your file
- Before downloading as XML, consider previewing it by clicking the "Preview in Enketo" option

## Uploading form into Bohemia system

- Once your form is ready to go, go to https://papu.us and log in as data/data
- Click "Form Management"
- Click "Add New Form"
- Upload your form

## Getting new form onto tablet

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
- Select your recently uploaded form and click "Get Selected"
- On the main page of the app, select "Fill Blank Form" and select your recently uploaded form
- You can now fill out the form

## Sending data to the server
- Once done filling out the form, click "Save Form and Exit" in the app
- Then on the main app page, click "Send Finalized Form"
- Now, having sent the data to the server, you should be able to inspect results at https://papu.us under "Form Management" > "Submission Admin"
