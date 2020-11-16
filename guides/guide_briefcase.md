# How to set up ODK Briefcase

- Create a directory for placing the Briefcase `.jar` file:

```
cd ~/Documents
mkdir briefcase
cd briefcase
mkdir storage
mkdir exports
```

- Download the program into the newly created directory by running the following:
```
wget https://github.com/opendatakit/briefcase/releases/download/v1.16.1/ODK-Briefcase-v1.16.1.jar
```

- Create an alias to open the Briefcase program by coping the below line into `~/.bashrc`:
```
alias briefcase='java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar &'
```
- Run `source ~/.bashrc`
- Then, to run the program, simply type `briefcase` into the terminal
- A window will popup.

## Configure ODK Briefcase (for GUI use)

- In the "Settings" tab, set the "Storage Location" to: `~/Documents/briefcase/storage`
- In the "Pull" tab, click the "Configure" button next to the "Pull from" field with "Aggregate server" selected. Type in the following:
  - URL: `https://datacat.cc/ODKAggregate`
  - Username: `data`
  - Password: `data`
- The forms should now populate in the "Pull" tab as below:

![](img/briefcase.png)

- In the "Push" tab, click the "Configure" button next to the "Push to" field with "Aggregate server" selected. Type in the following:
  - URL: `https://datacat.cc/ODKAggregate`
  - Username: `data`
  - Password: `data`

- Go back to the "Pull" tab
- Click "Select All" in the bottom left
- Click "Pull"

- Go to the "Export" tab
- Click "Set Default Configuration"
- Set "Export directory" to `~/Documents/briefcase/exports`
- Click "Select all"
- Click "Export"

## Get data via ODK Briefcase (for CLI use)

Pull:
```
java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar --pull_aggregate --storage_directory ~/Documents/briefcase/storage --aggregate_url https://datacat.cc/ODKAggregate --odk_username data --odk_password data
```

Export (for a form with form_id = "censusmember"):
```
java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar --export --form_id censusmember --storage_directory ~/Documents/briefcase/storage --export_directory ~/Documents/briefcase/exports --export_filename censusmember.csv
```
