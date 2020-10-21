# Forms

## Overview

The Bohemia project uses the ODK framework for surveys. This means that forms are designed in `xls` format, converted to `xml` format (sometimes with accompanying metadata in `itemsets.csv`) and deployed to and ODK Aggregate server to be retrieved by tablets/phones running the ODK Collect mobile app.

## Versioning

Version control is important. Forms undergo modifications, and these modifications may lead to data formatting incompatibilities if not appropriately controlled. Additionally, clear versioning is essential to ensuring compliance.

During the form design and development phase (ie, prior to a form actually being used in the field), versioning is inconsequential. Changes (corrections and improvements) can be made at the request of a site or the sponsor, or in response to finding a bug.

However, once a form has been IRB-approved and deployed (ie, data is being collected), it is essential to maintain structured versioning. This requires the following:
- All field ODK servers (CISM, IHI) should use the same version of the same form.   
- Databrew should communicate the current version string to the sites.  
- "Beta" versions (ie, those which have incorporated and are undergoing testing) should be deployed at https://bohemia.systems (the Databrew ODK server).  
- The files to be uploaded to site ODK servers should the xml (and `itemsets.csv`, when applicable) from the [FORMS PAGE](https://github.com/databrew/bohemia/tree/master/forms).
  - The `xls` files should not be manipulated in any way.  
  - Sites should not carry out any conversion from `xls` to `xml` (as this can corrupt data)
- Form `name`s will have a `bohemia_` prefix
- Form `id`s will have no prefix
- Forms will have a `version` string in the following format: `YYYYMMDDXX` wherein:
  - `YYYY`: the four digit year, such as 2020
  - `MM`: the two digit month, such as 10 for October or 04 for April
  - `DD`: the two digit day, such as 03 for the third of the month or 28 for the 28th of the month
  - `XX`: an incrementing two-character numeric showing the specific version for that day

### Deploys

When a form needs to be updated (ie, replaced with a newer version), the process is as follows:
- Databrew should:
  - Communicate to the sites and sponsor that a form update is taking place and provide all associated materials.  
- Sites should:
  - Update and upload the new form to their respective ODK servers.  
  - Ensure that all tablets are synced with the new form.  
  - Inform Databrew when both the server and all tablets have been updated.  

### Backwards compatibility

In the case of a form which is not backwards compatible (ie, data fields have been modified), a new id will be issued. For example, `minicensus` may become `minicensusb`, `minicensusb`, etc. In general, backwards-incompatibile form revisions are to be avoided (but in some cases they cannot be). In the case of a backwards-incompatible form revision, it is essential that:
- The "deprecated" (ie, no longer active) form remain on the site server  
- Tablets be synced to include the updated form
- Fieldworkers be instructed to use the updated form  

### Form-log

#### Mini-census

- `BOHEMIA_minicensus`
- `bohemia_minicensus2`
- `bohemia_smallcensus`
- `bohemia_smallcensusa`

#### Mini-census related

- `bohemia_enumerations`
- `bohemia_refusals`
- `bohemia_va153`



# Deprecated documentation




## How to create a form for the Bohemia project

The data _collection_ component of the Bohemia data system is built on the ODK framework, allowing for the creation and modification of survey forms specific to the Bohemia project's different study components. This guide shows how to create and deploy a form. For the purpose of this example, it assumes your ODK Aggregate server is running at https://bohemia.systems.


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

## Uploading form into Bohemia system

- Once your form is ready to go, go to https://bohemia.systems and log in.
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
