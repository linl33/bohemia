
The Bohemia Data Pipeline
=============================================

This repository contains utilities and guides created by DataBrew for use by the Bohemia research team. It is publicly available for the purposes of reproducibility and transparency.

Guides
------------

Several "how-to" guides are available for use by different Bohemia team members:

### [1. How to set up the system](guides/guide_admin_set_up.md)

This is a step-by-step walkthrough showing how to set up the Bohemia data system from scratch. This includes everything from domain configuration, to security certificates, to server-side software prerequisites.  

### [2. How to create forms](guides/guide_forms.md)

The Bohemia data system is a variation of the OpenHDS framework, but also allows for the creation and modification of survey forms specific to the Bohemia project's different study components. This guide shows how to create and deploy a form.

### [3. How to set up the data collection device (tablet/phone)](guides/guide_data_collection.md)

Once the system has been deployed and forms have been created, data collection software needs to be installed on android devices (phone or tablet). This guide shows how.

### [4. Fieldworker guide](guides/guide_fieldworker.md)

This guide is meant for fieldworkers, and provides an overview of how to collect and upload data.


### [5. How to retrieve data using ODK Briefcase](#guides/guide_briefcase.md)

This guide shows how to export data from the Bohemia system to a local machine, for the purpose of exploration or analysis. 

R package
------------

The "bohemia" R package can be installed by running the below from within the R console.

``` r
if(!require(devtools)) install.packages("devtools")
install_github('databrew/bohemia')
```

For more details on the R package, including usage examples and how to build the package from scratch see the [guide](#guides/guide_r_package.md)
