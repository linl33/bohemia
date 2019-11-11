
# How to set up the data collection device (tablet/phone)

Once the system has been deployed and forms have been created, data collection software needs to be installed on android devices (phone or tablet). This guide shows how.


# Setting up fieldworker credentials  

## Credentials

- You'll be provided with credentials for the central server from the DataBrew team. For the purposes of this example, we'll use the below credentials.
  - Username: data
  - Password: data

### Set up ODKCollect

- Open ODKCollect
- Click the three dots in the upper-right hand corner
- Select "General Settings"
- Click "Server"
- Change the server URL to https://bohemia.systems
- Set the credentials to `data` (user) and `data` (password)

### Synchronizing ODKCollect

- In ODKCollect, select "Get Blank Form"
- Select all the forms we want. Click "Get Selected"

# Fieldworker guide

This next section is intended for either (a) fieldworkers' direct use or (b) for use by those who are training fieldworkers. It assumes that the data pipeline is up and running, that tablets are configured, etc. For the purposes of this example, we'll assume that the fieldworker is named "data data", with user ID `FWDD1` and password `data` (for more details on creating fieldworkers, see the [guide_local_data_manager.md](Local data manager guide)).
## Sending data

- Once done, open the ODK Collect app and send all finalized forms
