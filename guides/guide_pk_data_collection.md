
# How to set up the data collection device (tablet/phone)

Once the system has been deployed and forms have been created, data collection software needs to be installed on android devices (phone or tablet). This guide shows how.

## Software installation

- Fetch an android device (phone/tablet)
- Download/Install [ODKCollect via Google Play](https://play.google.com/store/apps/details?id=org.odk.collect.android&hl=en)

# Setting up fieldworker credentials  

## Credentials

- You'll be provided with credentials for the central server from the DataBrew team. For the purposes of this example, we'll use the below credentials.
  - Username: pk
  - Password: pk

### Set up ODKCollect

- Open ODKCollect
- Click the three dots in the upper-right hand corner
- Select "General Settings"
- Click "Server"
- Change the server URL to https://bohemia.systems
- Set the credentials to `pk` (user) and `pk` (password)

### Synchronizing ODKCollect

- In ODKCollect, select "Get Blank Form"
- Select all the forms:
  -CRF2
  -CRF3
  -CRF4
  -Ento
  -Lab
-Click "Get Selected"

### Filling out a form
- In ODKCollect, on the main page, click the top button ("Fill Blank Form")
- Select the form you wish to fill out
- Begin filling out form
- To switch language, click the three dots in the upper right
- Go question by question filling out the form
- To advance to the next page or go back, swipe left or right
- On the last page, click the "Save Form and Exit" button

### Sending data
- With an internet connection, from the main page of ODKCollect, click "Send Finalized Form"
- Select all and "Send"

### Syncronizing
- When you have an internet connection, you should also synchronize with the main server
- In order to do this, you need to go to the main page of ODK and select "Get Blank Form"
- Then, select the census form (its updated version) and get it
