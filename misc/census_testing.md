# Census testing

Early February 2021

## Context

The Bohemia census will take place in the spring of 2021. Whereas previous rounds of data collection (reconnaissance, animal annex, minicensus) involved a unidirectional flow of data (ie, sending the data from the field to a server) the census requires a more complex, bi-directional flow of data, wherein a data collection "form" relies on pre-populating fields which were previously collected (such as the location of a household, or the roster of household members). Because of this complexity, the census form will use the ODK-X framework (previous forms used ODK). Since the ODK-X framework involves a substantially different workflow than ODK, it is important to test.

## Instructions

If you are reading this document, it is because you are testing the census form. You should focus on both:  

- (a) the technical components of the form (ie, "it it working?"), and   
- (b) the usability and familiarity with the form of fieldworkers (ie, "is it clear to me what to do")

What follow are steps to carry out the testing:
- ~~Set up an ODK-X Server per [THIS GUIDE](https://github.com/databrew/bohemia/blob/master/guides/guide_odkx_server.md)~~ (Not applicable for this round of testing; Databrew is doing this internally).  
- ~~Set up forms on the ODK-X Server per [THIS GUIDE](https://github.com/databrew/bohemia/blob/master/guides/guide_odkx_client.md)~~  (Not applicable for this round of testing; Databrew is doing this internally).  
- ~~Set up utilities for pulling and pushing data to the server per [THIS GUIDE](https://github.com/databrew/bohemia/blob/master/guides/guide_odkx_suitcase.md)~~  (Not applicable for this round of testing; Databrew is doing this internally).  
- Fetch an android device.  
- Follow [THESE INSTRUCTIONS](https://github.com/databrew/bohemia/blob/master/guides/guide_odkx_client.md) to download and install the necessary software.
- Follow [THESE INSTRUCTIONS](https://github.com/databrew/bohemia/blob/master/guides/guide_census_form_testing.md) for testing the census form.  
- Write your detailed comments and change requests on [THIS SPREADSHEET](https://docs.google.com/spreadsheets/d/1qNuL6I6drMlZvOCfkKG5DDH7P4dd2mAwtqc6kwkfnqo/edit?urp=gmail_link&gxids=7628#gid=0).  
