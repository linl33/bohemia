
The Bohemia Data Pipeline
=============================================

This repository contains utilities and guides created by DataBrew for use by the Bohemia research team. It is publicly available for the purposes of reproducibility and transparency.

Guides
------------

Several "how-to" guides are available for use by different Bohemia team members:

### [How to set up the system](guides/guide_admin_set_up.md)

This is a step-by-step walkthrough showing how to set up the Bohemia data system from scratch. This includes everything from domain configuration, to security certificates, to server-side software prerequisites.  

### [How to retrieve data using ODK Briefcase](#guides/guide_briefcase.md)

This guide shows how to export data from the Bohemia system to a local machine, for the purpose of exploration or analysis. 

R package
------------

The "bohemia" R package can be installed by running the below from within the R console.

``` r
if(!require(devtools)) install.packages("devtools")
install_github('databrew/bohemia')
```

For more details on the R package, including usage examples and how to build the package from scratch see the [guide](#guides/guide_r_package.md)
