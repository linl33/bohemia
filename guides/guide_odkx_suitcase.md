# How to set up ODK-X Suitcase

- Create a directory for placing the ODK-X Suitcase `.jar` file:

```
cd ~/Documents
mkdir suitcase
cd suitcase
```

- Download the program into the newly created directory by running the following:
```
wget https://github.com/odk-x/suitcase/releases/download/2.1.7/ODK-X_Suitcase_v2.1.7.jar
```

- Make sure the .jar file is executable
```
chmod +x suitcase/ODK-X_Suitcase_v2.1.7.jar
```

## Suitcase CLI

- For a list of available options:
```
java -jar ~/Documents/suitcase/ODK-X_Suitcase_v2.1.7.jar --help
```

- download data: 
  ```
  java -jar ODK-X_Suitcase_v2.1.7.jar -download -a -cloudEndpointUrl "https://databrew.app" -appId "default" -tableId "hh_geo_location" -username "data" -password "data" -path "Download"
  ```
(NOTE: specifying "Download" as the path creates a folder called "Download" in your current directory):

- update data:
```
java -jar 'ODK-X_Suitcase_v2.1.7.jar' -cloudEndpointUrl 'https://databrew.app' -appId 'default' -dataVersion 2 -username 'data' -password 'data' -update -tableId 'hh_geo_locations' -path 'hh_geo_locations.csv'
```
- The above command workd for updating, deleting, or adding new data on the ODK-X Cloud Endpoint. You will need a correctly formatted csv (Tip: use the.csv file from `Download` as a template).
- The contents of the first column ("operation") in the csv file will determe if new data should be added, or if existing data should be updated or deleted. 
- The valid values for the "operation" column are: `UPDATE`, `FORCE_UPDATE`, `NEW` and `DELETE`. 
- In the example below, all the columns besides "hh_id" are "meta-variables" and MUST be present in the csv. To change the value of an existing column, simply add the column name (in this example "hh_id") with the new value (AAA-222). 
    - `UPDATE` is used for updating data that already exists on the server. The update is done by matching on the `_id`column. The `_id` for an instance can be found by downloading the data using ODK-X suitcase.
![](img/example_spreadsheet.png)
    - `FORCE_UPDATE` is used for updating data with a more aggressive strategy, if -UPDATE failed.
    - `NEW` is used for adding new rows (instances) to the server. We can add the entry `NEW` to our existing csv.
   ![](img/example_spreadsheet_new.png)
    - `DELETE` is used for deleting rows (instances) from the server by matching on the `_id` column. In the image below, we delete the newly created instance. 
   ![](img/example_spreadsheet_delete.png)






