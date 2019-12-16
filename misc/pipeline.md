# Bohemia Data Pipeline


## Software/tool used

- Data collection will be via the ODK Collect android application. The [Data Collection Guide](../guides/guide_data_collection_odk.md) should be referred to.
- Study site servers will run the ODK Aggregate software. The [Admin set-up guide](../guides/guide_odk_setup.md) should be referred to in regards to server configuration and deployment.
- Cron will be used for secure daily transfers of data to the central study server.
- Both the local and central servers will run data cleaning scripts in python and mysql.
- Both the local and central servers will run web applications using R and shiny.


## ID generation and management

The [Location handling](location_and_ids.md) document should be read in detail regarding the generation and management of location and individual ID numbers/codes.

## Overall flow

The below schema gives an overall picture of data flow.

![](img/pipeline.png)


