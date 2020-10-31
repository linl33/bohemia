# GPS tracking

## Context

- During the census phase of the Bohemia project, the location of data capture devices (tablets) will be tracked. The purpose of this tracking is to both:
  - Help with recovery in the case of device loss or theft
  - Enable, over time, the identification of travel routes through the aggregation of the GPS tracks/paths taken by each tablet, and the subsequent generation of travel route planning tools and maps
- This guide details the technical set-up of the device tracking system

### Services used

- Device-side: Devices will use Traccar Client, and Android application downloadable via the [Google Play Store](https://play.google.com/store/apps/details?id=org.traccar.client).
- Server-side: The server will run Traccar Server, downloadable from Traccar's [website](https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip)

## Steps

### On tablets


Please visit the [GPS tracking Android page](guide_gps_tracking_android.md) for details on configuring the tablets for location collection.


### On server


(Note: some of this came from [TracCar official documentation](https://www.traccar.org/documentation/))


#### Buy a domain

- Go to domains.google.com and buy a domain.
- For the purposes of this guide, the domain being used is `www.bohemia.fun`

#### Spin up an EC2 instance on AWS

- AMI: Ubuntu Server 18.04 LTS
- Instance type: t2.medium
- Configure instance:
  - All default except:
    - Auto-Assign Public IP: Enable
- Add Storage: (50gb)
- Add Tags: Skip
- Configure Security Group:
  - Create new: name it traccar
  - Type: All traffic
  - Source: Anywhere
- launch (associate with keypair already created)


#### Allocate a persistent IP

- So that your AWS instance's public IP address does not change at reboot, etc., you need to create an "Elastic IP address". To do this:
  - Go to the EC2 dashboard in aws
  - Click "Elastic IPs" under "Network & Security" in the left-most menu
  - Click "Allocate new address"
  - Select "Amazon pool"
  - Click "Allocate"
  - In the allocation menu, click "Associate address"
  - Select the instance you just created. Also select the corresponding "Private IP"
  - Click "Associate"
- Note, this guide is written with the below elastic id. You'll need to replace this with your own when necessary.

```
3.21.67.128
```

- Go to instances menu
- Name the newly spun-up server "traccar"

#### Connect to the server

- In the “Instances” menu, click on “Connect” in the upper left
- This will give instructions for connecting via an SSH client
- It will be something very similar to the following:

```
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-3-21-67-128.us-east-2.compute.amazonaws.com
```

- Create an alias
```
alias traccar='ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.fun'
```
- Add the above line to ~/.bashrc to persist

#### Setting up the domain

- In domains.google.com, click on the purchased domain.
- Click on "DNS" on the left
- Go to "Custom resource records"
- You're going to create two records:
  1. Name: @; Type: A; TTL 1h; Data: 3.21.67.128
  2. Name: www; Type: CNAME; TTL: 1h; Data: ec2-3-21-67-128.us-east-2.compute.amazonaws.com.

#### Setting up Linux  

- SSH into the server:
```
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-3-21-67-128.us-east-2.compute.amazonaws.com
```

- Install some software:
```
sudo apt-get update
sudo apt-get install openjdk-8-jdk-headless
sudo apt-get install zip
sudo apt-get install unzip
sudo apt-get install wget
sudo apt-get install curl
#sudo apt-get install postgresql-10
sudo apt-get -y update
sudo apt-get install nginx
sudo apt-get install software-properties-common
sudo apt install mysql-server
# NOT RUNNING: sudo mysql_secure_installation
```


#### Setting up java

- Java is already installed, but you need to set the `JAVA_HOME` environment variable. To do so:
- `sudo nano /etc/environment`
- Add line like `JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"`
- Run `source /etc/environment`

#### Installing Traccar

- Install the zip file [here](https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip) by running:
```
mkdir traccar
cd traccar
wget https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip
```
- Extract the contents:
```
unzip traccar-linux-64-4.8.zip
```
- Run the executable:
```
sudo ./traccar.run
```
- Start the service:
```
sudo systemctl start traccar.service
```
- Open web interface by navigating to http://localhost:8082/ (on local machine) or bohemia.fun (if you have already configured the below) or bohemia.fun:8082
- Log in as `admin` / `admin`

#### Deal with ports, nginx, etc.

- Run the below:
```
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/bohemia.fun
sudo nano /etc/nginx/sites-available/bohemia.fun
```
- Make it as follows:
```
server_name bohemia.fun;

       location / {
               proxy_pass http://127.0.0.1:8082;
       }

```

- Make a symlink as per below:
```
sudo ln -s /etc/nginx/sites-available/bohemia.fun /etc/nginx/sites-enabled/
```
- Edit a file: `sudo nano /etc/nginx/nginx.conf` and remove the `#` before `server_names_hash_bucket_size 64;`
- Remove the default nginx file: `sudo rm /etc/nginx/sites-enabled/default`
- Check to make sure there are no syntax errors:
```
sudo nginx -t
```
- Restart:
```
sudo systemctl restart nginx
sudo nginx -s reload
sudo systemctl start traccar.service
```

### Add users/devices

- For each user/tablet, do the following:
  - Click the "plus" icon in the upper left of the web interface
  - Add the name and worker ID for each user

### Set up mysql database

```
sudo mysql
CREATE USER 'traccaruser'@'localhost' IDENTIFIED BY 'traccarpass';
GRANT ALL PRIVILEGES ON * . * TO 'traccaruser'@'localhost';
FLUSH PRIVILEGES;
ctrl + d
mysql -u traccaruser -p
<enter password>
CREATE DATABASE traccardb;
```

#### Configure Traccar for MySQL

- Edit the [configuration file](https://www.traccar.org/configuration-file/) by running:
```
sudo nano /opt/traccar/conf/traccar.xml
```

Replace the below lines:

```
<entry key='database.driver'>org.h2.Driver</entry>
<entry key='database.url'>jdbc:h2:/home/user/Documents/traccar/target/database</entry>
<entry key='database.user'>sa</entry>
<entry key='database.password'></entry>
```
With:
```
<entry key='database.driver'>com.mysql.jdbc.Driver</entry>
<entry key='database.url'>jdbc:mysql://3.21.67.128:3306/traccardb?serverTimezone=UTC&amp;useSSL=false&amp;allowMultiQueries=true&amp;autoReconnect=true&amp;useUnicode=yes&amp;characterEncoding=UTF-8&amp;sessionVariables=sql_mode=''</entry>
<entry key='database.user'>traccaruser</entry>
<entry key='database.password'>traccarpass</entry>
```

- Note in the above that the `3.21.67.128` is the server IP.

- Also, add some filtering to ensure that we don't capture too much jumpiness:
```
<entry key='distance.enable'>true</entry>

<entry key='filter.enable'>true</entry>
<entry key='filter.distance'>40</entry>
<entry key='filter.maxSpeed'>25000</entry>
<entry key='filter.invalid'>true</entry>
<entry key='filter.accuracy'>40</entry>
<entry key='filter.duplicate'>true</entry>
<entry key='filter.skipLimit'>1800</entry>
<entry key='filter.future'>600</entry>
<entry key='filter.zero'>true</entry>

<entry key='report.trip.minimalTripDuration'>250</entry>
<entry key='report.trip.minimalTripDistance'>300</entry>
<entry key='report.trip.minimalParkingDuration'>300</entry>
```

#### Optimize MySQL

```
sudo nano /etc/mysql/mysql.conf.d/custom.cnf
```
- Add the following lines (adjusting the first line so that it is less than 75% of total memory)

```
[mysqld]
innodb_buffer_pool_size = 2G
innodb_log_file_size = 512M
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 0
```

- Restart stuff:
```
sudo systemctl stop traccar
sudo systemctl restart mysql
sudo systemctl start traccar
```

#### Reverse geocoding configuration

- DO NOT DO THIS FOR NOW; causes positions to not be recorded
~~- Edit the [configuration file](https://www.traccar.org/configuration-file/) by running:~~
```
sudo nano /opt/traccar/conf/traccar.xml
```

~~- Add the following lines in the `<properties>` block:~~
```
<entry key='geocoder.enable'>true</entry>
<entry key='geocoder.type'>nominatim</entry>
<entry key='geocoder.url'>https://nominatim.openstreetmap.org/reverse</entry>
```

- To set an explicit number of days before deleting, add the following (for 60 days, for example):
```
<entry key='database.positionsHistoryDays'>60</entry>
```

### Restart
```
sudo systemctl daemon-reload
sudo systemctl start traccar.service
```

### Allow for remote access to database

```
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```
- Comment out this line
```
bind-address            = 127.0.0.1
```

- Restart mysql:
```
sudo systemctl restart mysql
```
- Create remote user and grant privileges
```
sudo mysql
CREATE USER 'traccarremoteuser'@'%' IDENTIFIED BY 'traccarremotepass';
CREATE USER 'traccaruser'@'%' IDENTIFIED BY 'traccarpass';
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON traccardb.* TO 'traccarremoteuser'@'%';
GRANT ALL PRIVILEGES ON traccardb.* TO 'traccaruser'@'%';
FLUSH PRIVILEGES;
<ctrl +d>
```

- Restart stuff:
```
sudo systemctl stop traccar
sudo systemctl restart mysql
sudo systemctl start traccar
```
- Test the remote connection (from another box):
```
mysql -h 3.21.67.128 -u traccarremoteuser -p
<traccarremotepass>
```

### Secure connection (serving over https)

https://www.traccar.org/secure-connection/


```
sudo apt-get install apache2 # temporarily stop
sudo apt-get install apache2
sudo a2enmod ssl
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
sudo service apache2 restart
```

```
sudo nano /etc/apache2/sites-available/traccar.conf
```
Edit as follows
```
<IfModule mod_ssl.c>
        <VirtualHost _default_:443>

                ServerName bohemia.fun
                ServerAdmin webmaster@localhost

                DocumentRoot /var/www/html

                ProxyPass /api/socket ws://localhost:8082/api/socket
                ProxyPassReverse /api/socket ws://localhost:8082/api/socket

                ProxyPass / http://localhost:8082/
                ProxyPassReverse / http://localhost:8082/

                SSLEngine on
                SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
                SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

        </VirtualHost>
</IfModule>
```

```
sudo a2ensite traccar
sudo service apache2 restart
```

SSL / https

```
sudo apt install nginx
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx
sudo certbot run --nginx --non-interactive --agree-tos -m joebrew@gmail.com --redirect -d bohemia.fun
```



```
sudo systemctl start traccar.service
```



### Data extraction

- The [API](https://www.traccar.org/api-reference/) should be used for data extraction

- Get a list of devices:
```
http://bohemia.fun/api/devices
```
etc.

- The database can be accessed directly:
```
mysql traccardb -u traccaruser -p
<traccarpass>
show tables;
select * from tc_positions;
```

### Troubleshooting and logs
- See logs at `/opt/traccar/logs/tracker-server.log`
- See more details on the [troubleshooting page](https://www.traccar.org/troubleshooting/)

# Backups

See the [Backups guide](guide_backups.md) for details on generating automatated backups.
