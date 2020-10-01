# Automated data backups for Bohemia

## Context

- All data needs to be regularly backed up in case of server failure.
- Local sites have their own backup policies and practices. These should be applied for the Bohemia project. These are not described in this document.
- In addition, we will implement a project-level backup strategy. This document describes the technical underpinnings of that strategy.

## Backups overview

- Project-level backups will be stored:
  1. On AWS S3 (cloud)
  2. On hard drives (physical)

- 5 databases will be backed up:
  1. The PostgreSQL `aggregate` database on the IHI server.
  2. The PostgreSQL `aggregate` database on the CISM server.
  3. The PostgreSQL `bohemia` database (ie, "study database") on Databrew's `bohemia.systems` server.
  4. The MySQL `traccardb` database on Databrew's `bohemia.fun` server.
  5. A flat file of fieldworker IDs and contact info.

- Backups will be generated daily via the following sequential steps:
  1. SQL "dump" of all data
  2. Automated transfer of data to cloud server (AWS S3 bucket, henceforth called the "bohemia bucket")
  3. Automated copy of cloud server contents to local (physical) hard drive

## Bucket set-up

- The following describes the exact steps taken to set up the bohemia bucket.
- These steps do not need to be carried out by local sites.
- Local sites will be provided with scripts and instructions for setting up the backup tools.
- These steps are outlined here for the purposes of transparency and reproducibility only.

#### Create bucket

- Go to https://s3.console.aws.amazon.com/s3
- Click "Create bucket"
- Set the "Bucket name" field to `databrewbohemia`
- Set the region to "EU (Paris)"

#### Configure bucket

- Once created, click on the bucket
- Click "Access points"
- Click "Create access point"
- Create an access point named `joebrew`
- Set "Network access type" to `internet`
- Keep public access blocked
- Copy the Amazon Resource name code (ARN). It will looke like this (example only):
```
arn:aws:s3:eu-west-3:671670783497:accesspoint/joebrew
```
- Copy the arn code

#### Generate security credentials

- Go to the AWS console, click on your name in the upper right, and then click "My security credentials"
- Click "Access keys"
- Click "Create new access keys"
- Download the `rootkey.csv` file
- Copy the following parameters to a file on your system named `credentials.yaml`:
  - Access Key ID (call it `aws_access_key_id`)
  - Secret Access Key (call it `aws_secret_access_key`)

#### Set up AWS CLI

- Run the following:
```
sudo apt-get install awscli
```
- Run `aws configure`
- Enter in the parameters
- For "Default region name", use `eu-west-3`
- Keep default output format as `None`

#### Test the bucket (optional)

- Check out the contents of the `databrewbohemia` bucket by running:
```
aws s3 ls s3://databrewbohemia
```
-The following example creates a file locally called `example.txt` and then moves it to the s3 bucket in `folder/subfolder`:
```
touch example.txt
echo -e "this\nis\na\ntest" >> example.txt
aws s3 cp example.txt s3://databrewbohemia/folder/subfolder/example.txt
```
- Check in the web browswer that everything was created
- To delete:
```
aws s3 rm s3://databrewbohemia/folder/subfolder/example.txt
```

#### Set up data dumps

- Make the database trust local connections:
```
sudo nano /etc/postgresql/10/main/pg_hba.conf

# Change this line:
local   all             postgres                                peer
# To this line:
local   all             postgres                                trust
```
- Restart postgres:
```
/etc/init.d/postgresql reload
```

##### On the ODK Aggregate server

- On the server, create a folder for dumps:
```
mkdir ~/Documents
cd ~/Documents
mkdir dumps/
sudo chmod -R 775 dumps/  
```
- In that folder, create a `backup.sh` file and make it executable:
```
touch ~/Documents/dumps/backup.sh
sudo chmod +x  ~/Documents/dumps/backup.sh
```
- Open the file and copy and paste the below information (changing the `server` variable to one of `bohemiasystems`, `ihi`, or `cism`):

```
#!/bin/bash

server=bohemiasystems
bucket=databrewbohemia
folder=aggregate
dateValue=`(date --iso-8601=seconds)`
file=${dateValue}.sql
resource="/${bucket}/${server}/${folder}/${file}"

# Stop running tomcat
sudo service tomcat8 stop

# Run the dump
pg_dump aggregate -U postgres > ${file}

# Restart tomcat
sudo service tomcat8 start


aws s3 cp ${file} s3:/${resource}
rm ${file}
```

##### For backing up the bohemia database (using same server)

Modify the ~/Documents/dumps/backup.sh file by adding the following lines:

```
dateValue=`(date --iso-8601=seconds)`
password=<PASSWORD GOES HERE>
endpoint=<ENDPOINT GOES HERE>
bucket=databrewbohemia
server=bohemiadb
folder=bohemia
file=${dateValue}.sql
resource="/${bucket}/${server}/${folder}/${file}"
#pg_dump -h ${endpoint} -U postgres bohemia > ${file}
pg_dump --dbname=postgresql://postgres:${password}@bohemiacluster.cluster-carq1ylei7sf.eu-west-3.rds.amazonaws.com:5432/bohemia > ${file}
aws s3 cp ${file} s3:/${resource}
rm ${file}
```


##### On the traccar server (bohemia.fun)

- On the server, create a folder for dumps:
```
mkdir ~/Documents
cd ~/Documents
mkdir dumps
sudo chmod -R 775 dumps/  
```
- In that folder, create a `backup.sh` file and make it executable:
```
touch ~/Documents/dumps/backup.sh
sudo chmod +x  ~/Documents/dumps/backup.sh
```
- Open the file and copy and paste the below information (replacing the text within `<>` with the appropriate user and password for the `traccardb` database):


```
#!/bin/bash

server=bohemiafun
bucket=databrewbohemia
folder=traccardb
dateValue=`(date --iso-8601=seconds)`
file=${dateValue}.gz
resource="/${bucket}/${server}/${folder}/${file}"

# Run the dump
mysqldump -u <traccar_mysql_local_user> -p<traccar_mysql_local_pass> traccardb | gzip > ${file}

aws s3 cp ${file} s3:/${resource}
rm ${file}
```





#### Use crontab to automate the above

- Log onto the server.
- Create a place to store crontb logs: `sudo mkdir /var/log/dumps; sudo chmod -R 700 /var/log/dumps/`
- Use the edit functionality of crontab: `crontab -e`
- To back up every day at 1:00 AM, add the following line:
```
0 1 * * * /home/ubuntu/Documents/dumps/backup.sh
```
