# How to fill out the Bohemia ODK-X Census Form

This guide describes the steps to follow to fill out the ODK-X Bohemia Full Census Form during the testing period. These instructions will be modified once operational flow details have been finalized and implemented.

# Instructions

## Download necessary ODK-X suite of applications and set up the ODK-X Server

If you have not already set up your Android device with the necessary ODK-X applications and/or server connection, follow the [ODK-X Server Client setup instructions](https://github.com/databrew/bohemia/blob/feature/odkx_server_reset_guide/guides/guide_odkx_client.md).

## Sync your device with the server
- Open ODK-X Tables or ODK-X Survey on your phone/tablet
- Click he refresh button at the top of the screen
- Click "Sync now"
- For more detailed instructions or if you have problems syncing, refer to [Refreshing the app with data from the server](https://github.com/databrew/bohemia/blob/master/guides/guide_odkx_client.md#refreshing-the-app-with-new-data-from-server).

## Entering your Fieldworker ID
 - Open ODK-X Tables
 - Click the `Enter Fieldworker ID` button
 - Click the `Scan QR code` or enter manually
 - Click `Submit`.

## Filling out a census form
You have the option of filling out the census form for a new household (i.e., one that was NOT minicensed) or an existing household (i.e., one that was minicensed and will come with prepopulated data). Instructions for both are scenarios below:

### Fill out a census form for a new household (not previously minicensed)
- Open the ODK-X Tables app
- Make sure you have entered your fieldworker ID
- On the home screen, click the `Add New Household` button
- You will be taken to a screen with the form name, version, and message that reads "You are at the start of a new instance"
- Click on the `Click to Proceed` button
- You will be taken to a screen titled "Technical Details-TBD"
- On the "Technical Details" page, select a country, enter a Household ID in the format "AAA-111", and geocode your location by clicking the `Create new instance` button under the heading "Record Location"
- Once done, swipe left or click the `next` button at the top of the screen to navigate to the next page
- You will arrive at the "Household Questionnaire" page and see the question "Was this household part of the minicensus?" Select "No" and click the `next` button to proceed
- On the "Meta-Information" page that follows, enter the number of household members and add details about new member by clicking the `Create new instance` button under "Details about household member"
- Once you have filled out the details for the first member, click `next` button and you will return to the main page where you can click the "Create new instance" button to add details about other household members
- If you need edit information about a specific household member, click the pencil icon next to his/her name to make changes
- Once you have entered information about all household members, click the `next` button to move on to the next survey question

### Fill out a census form as a minicensed household (with data populated)
- Open the ODK-X Tables app
- Make sure you have entered your fieldworker ID
- Click the `Edit Existing Household` button on the home screen
- You have the option of searching by household ID or household member name. Click on `Search by Household ID`.
- Type "AAA" in the search bar and click `Search`
- A list of households should appear with the household ID AAA-###. Click on the first one.
- You'll be presented with the members of the selected household. Please use the members to confirm you've selected the correct household. Click `Proceed` to confirm, or `Cancel` to go back.
- After you've confirmed the roster, you'll be taken to new screen that has the form name, version, message that reads "You are at the start of instance "AAA-###", and allows you to launch the survey form for that household
- Click the `Click to Proceed` button
- You will be taken to a screen titled "Technical Details-TBD" with pre-populated fields
- Click the `next` button or swipe left to proceed to fill out the census form for this household
- You will see that the members roster is prepopulated with member names. To edit details about a certain member, click on the pencil icon next to his or her name. Once done editing details, click the `next` button to return to the main screen

### Changing the form language
If you would like to change the language of the survey form, once you enter into a form instance (i.e., open a survey for a new or existing household) click the button at the top left of the screen. A pop up menu will appear. Click the `Language` button and select the language you would like

### Changing the operational flow interface language
If you would like to change the language of the operational flow interface, open ODK-X Services then open the settings. Click on `Device Settings` then click on `Default Locale`. A pop up list will appear. Choose the language you'd like. The language selected here applies to the operational flow interface and the Survey forms.

### Saving a form and sending data to the server
- To save an incomplete form and exit the survey, click the button at the top left of the screen. A pop up menu will appear. Click `Save changes + Exit`
- To "finalize" a survey form, once you have completed the entire survey (including the individual member questionnaire), there will be two buttons that appear:`Finalize` and `Incomplete`. Click `Finalize`
- Once you have saved and exited the survey form or finalized the form, you can upload your data to the server but navigating back to the ODK-X Tables app, clicking the `Send Data` button, then clicking the `Sync Now` button

## Handling Navigation from Content Pages view

_Click here for a [detailed ODK-X census form navigation guide](https://github.com/databrew/bohemia/blob/master/guides/guide_odkx_app_navigation.md)._

When filling out a survey, there are some sections that are populated via the `Create New Instance` button.
When such a section is entered, clicking the `Back` button will _not_ take you back to the census question you were at.
If you should realize that the section was entered in error, please click the `Next` button and that will take you to the census section.

It is counterintuitive at first but the logic is, the 'new instance' is a separate form which has no history of which form initiated a call to load it. Thus, when the `Back` button is clicked in it, it defaults to the `Contents` page.
