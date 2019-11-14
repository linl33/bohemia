# How to create a form for the Bohemia project

The data _collection_ component of the Bohemia data system is built on the ODK framework, allowing for the creation and modification of survey forms specific to the Bohemia project's different study components. This guide shows how to create and deploy a form. For the purpose of this example, it assumes your ODK Aggregate server is running at https://bohemia.systems, and that the administrator's username and password is data/data.

## Create / modify forms

For the Bohemia project, there are two forms:

1. The [census form](https://docs.google.com/spreadsheets/d/16_drw-35haLaBlB6tn92mr6zbIuYorAUDyieGONyGTM/edit#gid=141178862)  
2. The [VA form](https://docs.google.com/spreadsheets/d/1BuRSJdWmottUW8SDnh8nGTkLCeTjEX3LgkRpaPvoKjE/edit#gid=1264701015) (verbal autopsy)  

The forms conform to the [xlsform](https://build.opendatakit.org/) standard. Only authorized collaborators should modify forms.

## Download / convert forms

Once forms are finished, they can be automatically downloaded as `.xls` files and then converted to `.xml files`. To do this, run the following:

```
# From within the "bohemia" project repo
cd scripts
# Fetch the census form
python census_excel_to_xml.py
# Fetch the VA form
python va_excel_to_xml.py
```

- As an alternative to the above, you can:  
- Go to https://opendatakit.org/xlsform/
- Submit your file
- Before downloading as XML, consider previewing it by clicking the "Preview in Enketo" option

## Uploading form into Bohemia system

- Once your form is ready to go, go to https://bohemia.systems and log in as data/data
- Click "Form Management"
- Click "Add New Form"
- Upload your form

## Getting new form onto tablet

- Open ODK Collect on the tablet
- Click the three dots in the upper right > General Settings > Server
- Set the following parameters:
```
Type: ODK Aggregate
URL: https://bohemia.systems
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
- Now, having sent the data to the server, you should be able to inspect results at https://bohemia.systems under "Form Management" > "Submission Admin"

## Helpful documentation

- The ODK documentation on form styling, language, etc. is very helpful: https://docs.opendatakit.org/form-styling/
- The XLSForm.org documentation is also very good: https://xlsform.org/en/
