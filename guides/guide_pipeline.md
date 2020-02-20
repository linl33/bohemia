# Data pipeline guide

A sysadmin guide for setting up the Bohemia data "pipeline"

## Standards and "rules"  

The data processing scripts that migrate data from the ODK Aggregate server to project databases require that: 

1. All `.xml` forms deployed on the ODK Aggregate server be generated via the `xls2xform` functionality (or via the python scripts for conversion in the `scripts` sub-directory), _not_ via online converters.

2. All repeat elements (ie, xlsform rows in which the type is `begin repeat`) must contain `repeat` in the `name` field.

3. No non-repeat elements should contain the word `repeat` in the name field.