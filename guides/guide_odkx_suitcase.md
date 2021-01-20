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
  - `java -jar ~/Documents/suitcase/ODK-X_Suitcase_v2.1.7.jar --help`

- Download (specifying "Download" as the path creates a folder called "Download" in your current directory):
  - `java -jar ODK-X_Suitcase_v2.1.7.jar -download -a -cloudEndpointUrl "https://databrew.app" -appId "default" -tableId "hh_geo_location" -username "data" -password "data" -path "Download"`
  
- Upload (not important)
  - `java -jar 'ODK-X_Suitcase_v2.1.7.jar' -cloudEndpointUrl 'https://databrew.app' -appId 'default -username 'user' -password 'pass' -upload -tableId 'table_id'-path 'table_id.csv'`

- Update
  - In order to add, delete, or update data on the ODK-X Cloud Endpoint, you will need to create a CSV. 
  - The CSV file must also include `_id` and `_form_id` columns. 
  - When uploading, you need a correctly formatted csv file: (Tip: use the.csv file from `Download` as a template).
  - All the columns besides "hh_id" are `meta-variables` and MUST be present in the csv. To change the value of a column, simple add the column name (in this example "hh_id") with the new value (AAA-222). 
  
  An example of updating a csv:
![](img/example_spreadsheet.png)

 - The first column of the CSV must have the header operation. The value in the operation column instructs ODK-X Suitcase how to handle that row. The valid values for this operation column are: UPDATE, FORCE_UPDATE, NEW and DELETE.
   - `UPDATE` is used for updating data that already exists on the server. The update is done by matching on the `_id`column. The `_id` for an instance can be found by downloading the data using ODK-X suitcase.
   - `FORCE_UPDATE` is used for updating data with a more aggressive strategy, if -UPDATE failed.
   - `NEW` is used for adding new rows (instances) to the server.
   - `DELETE` is used for deleting rows (instances) from the server by matching on the `_id` column.
 - Once you have specified a command in the "operation" column, run the following:
 - `java -jar 'ODK-X_Suitcase_v2.1.7.jar' -cloudEndpointUrl 'https://databrew.app' -appId 'default' -dataVersion 2 -username 'data' -password 'data' -update -tableId 'hh_geo_locations' -path 'hh_geo_locations.csv'`

## Open the Suitcase GUI

- Create an alias to open the Suitcase program by copying the below line into `~/.bashrc`:
```
alias suitcase='java -jar ~/Documents/suitcase/ODK-X_Suitcase_v2.1.7.jar &'
```
- Run `source ~/.bashrc`
- Then, to run the program, simply type `suitcase` into the terminal (in the `suitcase` directory).
- Alternatively, double-click the .jar file.
  - A window will popup and enter the following fields:
  - Cloud Endpoint Address: https://server_url
  - App ID: default
  - Username: user
  - Password: pass
- Then select the `Login` button

- There are two uptions: `Download` and `Upload`
  - `Download`: download existing data from the server
  - `Upload`: delete, upload new, or update data.
  
- `Download` 
  - When downloading, you will need to specify the table_id. By default ODK-X Suitcase creates a `Download` directory where the ODK-X Suitcase jar file is located and saves data in that directory in a table_id sub-folder with a corresponding link_unformatted.csv that has all of the data for that table downloaded from the server. To specify a different directory for ODK-X Suitcase to store downloaded data in, modify the `Save to` field or click on the `…` button.
  - ODK-X Suitcase provides three options to customize the CSV file download.
    - (1) Download attachments:
      - If this option is selected, ODK-X Suitcase will download all attachments from the given table and the CSV generated will contain hyperlinks to the local files.
      - If this option is not selected, the CSV generated will contain hyperlink to the given ODK-X Cloud Endpoint.
    - (2) Apply scan formatting:
      - When this option is selected, ODK-X Suitcase will optimize the CSV by replacing certain columns added by ODK-X Scan.
    - (3) Extra metadata columns
      - When this option is selected, two more columns will be included in the CSV, create_user and last_update_user.




