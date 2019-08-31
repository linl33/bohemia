# How to create a form for the Bohemia project

The Bohemia data system is a variation of the OpenHDS framework, but also allows for the creation and modification of survey forms specific to the Bohemia project's different study components. This guide shows how to create and deploy a form in a way that it can draw upon the data in the demographic database. For the purpose of this example, it assumes your OpenHDS admin user/password is data/data.

## Create a form

- Go to https://build.opendatakit.org/
- Create a user account and log in
- Give the form a name by clicking "rename" in the upper left (ie, "fake")
- Add questions by selecting the question type from the bottom
- As you create questions, regularly save buy selecting "File -> Save"
- Once your questions have been created, click File -> Export to XML
- Save the file locally



## Uploading form into OpenHDS system

- Go to https://papu.us/openhds
- Log in as data/data
- Click "Utility Routines" -> "ODK Forms"
- Name the form you are about to upload
- Select as "Active" or not
- Select to whom it applies (gender)
- Click "Create"

## Getting new form onto tablet

- Open OpenHDS on the tablet
- Log in as supervisor role with credentials data/data
- Click "Sync Database", "Sync Field Workers" and "Sync extra forms" sequentially
- Log out
- Log back in as a fieldworker with the credentials FWJD1/data
- Go through the location steps (including geocoding)
