# Data access

## Set up your credentials file

To use the Bohemia data access tools, it is advisable to first:
- Clone the Bohemia code repository: `git clone https://github.com/databrew/bohemia`
- Create a directory in the cloned repo named `credentials`
- In the credentials directory, create a file named `credentials.yaml`
- Populate the `credentials.yaml` file with the following parameters

```
country: MOZ # or TZA
moz_odk_server: https://bohemia.systems # will change
moz_odk_user: data
moz_odk_pass: data

tza_odk_server: https://bohemia.ihi.or.tz
tza_odk_user: data
tza_odk_pass: data

databrew_odk_server: https://bohemia.systems
databrew_odk_user: data
databrew_odk_pass: data

odk_database: aggregate
odk_database_user: aggregate
odk_database_pass: aggregate
odk_database_schema: aggregate

traccar_server: https://bohemia.fun
traccar_db: traccardb
traccar_mysql_remote_user: traccarremoteuser
traccar_mysql_remote_pass: traccarremotepass
traccar_mysql_remote_host: 3.21.67.128
traccar_mysql_local_user: traccaruser
traccar_mysql_local_pass: traccarpass
traccar_mysql_local_host: 127.0.0.1
shiny_server: https://bohemia.team

aws_access_key_id: xxx
aws_secret_access_key: xxx
aws_default_region_name: eu-west-3
```

- Henceforth, references in this guide wrapped in `<>` refer to variables from this credentials file.

## Access data

### Tablet locations

- Tablet locations are stored in a MySQL database running on a server located at `<traccar_server>`
- To access the database directly via the MySQL CLI, one can run:
```
mysql <traccar_db> -h <traccar_mysql_remote_host> -u <traccar_mysql_remote_user> -p
```
- When prompted, supply the `<traccar_mysql_remote_pass>`
- The main table of interest is `tc_positions`, whose `deviceid` field refers to the `id` variable of `tc_devices`
- Example query:
```
SELECT
  p.deviceid,
  p.servertime,
  p.devicetime,
  p.latitude,
  p.longitude,
  p.altitude,
  p.speed,
  p.course,
  p.attributes,
  d.name,
  d.uniqueid,
  d.lastupdate
FROM
  tc_positions p
LEFT JOIN tc_devices d ON p.deviceid = d.id;
```

- Alternatively, once could run the query directly in the same command as the connection:
```
mysql mysql <traccar_db> -h <traccar_mysql_remote_host> -u <traccar_mysql_remote_user> -p<traccar_mysql_remote_pass> -e "select * from tc_devices limit 5;";
```

### ODK Aggregate data

- ODK Aggregate data is stored in a PostgreSQL database running on a server located at `<databrew_odk_server>`
- To access the database directly, one should first ssh into the ODK Aggregate server
- Then, one should get into the postgres user: `sudo su postgres`
- Then, open the psql cli: `psql aggregate`
- Finally, look at the data. For example:
```
select * from aggregate."RECON_CORE" ;
```
- To see all the tables:
```
\dt aggregate.*;
```
