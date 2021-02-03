# How to fill out the ODK-X Census Form

This guide describes the steps to follow in order to fill out the ODK-X Bohemia Full Census Form for the purpose of the testing/piloting period. This will be modified once operational flow details have been finalized. 

#### Set up the ODK-X Server 

If you have not already set up your Android device and/or server connection, follow the [ODK-X Server Client setup instructions](https://github.com/databrew/bohemia/blob/feature/odkx_server_reset_guide/guides/guide_odkx_client.md).

# Instructions

## Sync your device with the server
- Open ODK-X Tables or ODK-X Survey on your phone/tablet
- Click he refresh button at the top of the screen 
- Click "Sync now"

## Fill out a census form as a new household (not previously minicensed)
- Open ODK-X Tables
- Click the "Add New Household" button
- You will be taken to a screen with the form name, version, and message that reads "You are at the start of a new instance"
- Click on the "Click to Proceed" button
- You will be taken to a screen titled "Technical Details-TBD"
- If you would like to change the language of the survey form, click the button at the top left of the screen. A pop up menu will appear. Click the "Language" button and select the language you would like
- On the "Technical Details" page, select a country, enter a Household ID in the format AAA-111, and geocode the location by clicking the "Create new instance" button under "Record Location"
- Once done, click the 'next' button at the top of the screen to navigate to the next page
- You will arrive at the "Household Questionnaire" page and see the question "Was this household part of the minicensus?" Select "No" and click the 'next' button to proceed
- On the "Meta-Information" page, enter the number of household members and add details about new member by clicking the "Create new instance" button under "Details about household member" to add details about the new household member
- Once you have filled out the details for the first member, click the 'next' navigation button and you will return to the previous page where you can click the "Create new instance" button to add details about other household members
- If you need edit information about a household member, click the pencil icon next to his/her name
- Once you have entered information about all household members, click the 'next' button to move on to the next survey question
 
## Fill out a census form as a minicensed household (with data populated)
- Open ODK-X Tables
- Click the "Edit Existing Household" button
- Click the "Search" button and you'll get to a screen with a search bar. 
- Type "AAA" in the search bar and click 'Search'
- A list of households should appear. Click on the first one. 
- You'll be taken to new screen that has the form name, version, message that reads "You are at the start of instance "AAA-888", and allows you to launch the survey form for that household. 
- Click the "Click to Proceed" button
- You will be taken to a screen titled "Technical Details-TBD" with some fields pre-populated
