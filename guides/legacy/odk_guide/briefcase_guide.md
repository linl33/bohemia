Create a directory for placing the Briefcase `.jar` file:
```
cd ~/Documents
mkdir briefcase
cd briefcase
mkdir storage
mkdir exports
```

Download into the newly created directory the `.jar`:
```
wget https://github.com/opendatakit/briefcase/releases/download/v1.16.1/ODK-Briefcase-v1.16.1.jar
```

Run the following:
```
java -jar ODK-Briefcase-v1.16.1.jar
```

A window will popup.

## Configure ODK Briefcase (for GUI use)

- In the "Settings" tab, set the "Storage Location" to: `~/Documents/briefcase/storage`
- In the "Pull" tab, click the "Configure" button next to the "Pull from" field. Type in the following:
  - URL: `https://papu.us`
  - Username: `joe`
  - Password: `databrew`
- The forms should now populate in the "Pull" tab

- In the "Push" tab, click the "Configure" button next to the "Push to" field. Type in the following:
  - URL: `https://papu.us`
  - Username: `joe`
  - Password: `databrew`

- Go back to the "Pull" tab
- Click "Select All" in the bottom left
- Click "Pull"

- Go to the "Export" tab
- Click "Set Default Configuration"
- Set "Export directory" to `~/Documents/briefcase/exports`
- Click "Export"

## Get data via ODK Briefcase (for CLI use)

Pull:
```
java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar --pull_aggregate --storage_directory ~/Documents/briefcase/storage --aggregate_url https://papu.us --odk_username joe --odk_password databrew
```

Export (for a form with form_id = "build_Test-form-2_1564234327"):
```
java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar --export --form_id build_Test-form-2_1564234327 --storage_directory ~/Documents/briefcase/storage --export_directory ~/Documents/briefcase/exports --export_filename testform2.csv
```

 --export_filename testf.csv
