# Admin guide for setting up the Bohemia server from scratch

## Server set-up


#### Hardware details

- Set up a virtual machine
  - Specs:
    - 16 gb ram
    - 4 cores
    - 1 tb storage
- Ubuntu server 16.04 iso
- Install OS

#### DNS / IP

- In conjunction with IT, get a stable/static IP and public-facing DNS.
- For the purposes of this guide, replace any references to `bohemia.ihi.or.tz` with your particular DNS

## Credentials

You'll need the following credentials:
- username
- password
- ip address

You should have these saved in `credentials/server.yaml` in the following format:
```
username: xxx
password: xxx
ip: xxx
dns: xxx
```

## Log in to the server

- Run the following to log in:
```
ssh <username>@<bohemia.ihi.or.tz>
```
- You will then be prompted for the password. Enter it.

## Install apache

```
# Install apache
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install apache2
```

## Ensure static IP

(This may be relevant to Ubuntu 16 only)

- Open `/etc/network/interfaces` (`sudo nano /etc/network interfaces`):
- Modify the file so that it looks like this:

```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address <static ip to be used>
        netmask <subnet mask>
        network <network>
        broadcast <broadcast>
        gateway <gateway>
        dns-nameservers 192.168.1.252
        dns-search bohemia 8.8.8.8
```

## Install Java

```
# Java
sudo apt-get install openjdk-8-jdk-headless
```

### Setting up java

- Java is already installed, but you need to set the `JAVA_HOME` environment variable. To do so:
- `sudo nano /etc/environment`
- Add line like `JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"`
- Run `source /etc/environment`

### Install tomcat

```
sudo apt-get install tomcat8 tomcat8-common tomcat8-user tomcat8-admin
```

### Other packages

```
sudo apt-get install zip
sudo apt-get install unzip
# sudo apt-get install wget
sudo apt-get install curl
sudo apt-get install postgresql-10
# on Ubuntu 16, this requires more than just the above. See: https://www.liquidweb.com/kb/install-and-connect-to-postgresql-10-on-ubuntu-16-04/:
# Ubuntu 16 only:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'
sudo apt-get -y update
sudo apt-get install postgresql-10
sudo apt-get install nginx
sudo apt-get install software-properties-common
```

## Write some configuration write files

- `touch /root/aggregate-config.json`
- `sudo nano /root/aggregate-config.json`
- Paste the following content:
```
{
  "home": "/root",
  "jdbc": {
    "host": "127.0.0.1",
    "port": 5432,
    "db": "aggregate",
    "schema": "aggregate",
    "user": "aggregate",
    "password": "aggregate"
  },
  "security": {
    "hostname": "bohemia.ihi.or.tz",
    "forceHttpsLinks": true,
    "port": 80,
    "securePort": 443,
    "checkHostnames": false
  },
  "tomcat": {
    "uid": "tomcat8",
    "gid": "tomcat8",
    "webappsPath": "/var/lib/tomcat8/webapps"
  }
}
```

- `sudo touch /tmp/nginx-aggregate`
- `sudo nano /tmp/nginx-aggregate`
- Add the following content:
```
server {
    client_max_body_size 100m;
    server_name foo.bar;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}
```

- `sudo touch /usr/local/bin/download-aggregate-cli`
- `sudo chmod 0755 /usr/local/bin/download-aggregate-cli`
- `sudo nano /usr/local/bin/download-aggregate-cli`
- Paste the following content
```
#!/bin/sh
curl -sS https://api.github.com/repos/opendatakit/aggregate-cli/releases/latest \
| grep "aggregate-cli.zip" \
| cut -d: -f 2,3 \
| tr -d \" \
| wget -O /tmp/aggregate-cli.zip -qi -

unzip /tmp/aggregate-cli.zip -d /usr/local/bin
chmod +x /usr/local/bin/aggregate-cli
```

- `sudo mkdir /root/.aws`
- `sudo touch /root/.aws/config`
- `sudo nano /root/.aws/config`
- Paste the following:
```
[default]
region = foobar
output = text
```

- Run the following:

```
sudo download-aggregate-cli
sudo unattended-upgrades
sudo apt-get -y autoremove
sudo rm /etc/nginx/sites-enabled/default
sudo mv /tmp/nginx-aggregate /etc/nginx/sites-enabled/aggregate
sudo add-apt-repository -y universe
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get -y update
sudo apt-get -y install python-certbot-nginx
(crontab -l 2>/dev/null; echo "0 0 1 * * /usr/bin/certbot renew > /var/log/letsencrypt/letsencrypt.log") | crontab -

# Get into postgres user
sudo su postgres
psql -c "CREATE ROLE aggregate WITH LOGIN PASSWORD 'aggregate'"
psql -c "CREATE DATABASE aggregate WITH OWNER aggregate"
psql -c "GRANT ALL PRIVILEGES ON DATABASE aggregate TO aggregate"
psql -c "CREATE SCHEMA aggregate" aggregate
psql -c "ALTER SCHEMA aggregate OWNER TO aggregate" aggregate
psql -c "GRANT ALL PRIVILEGES ON SCHEMA aggregate TO aggregate" aggregate
# Get out of postgres user
ctrl + d
```

- Open the following file and change "foo.bar" to the correct dns
```
sudo nano /etc/nginx/sites-enabled/aggregate
```
- The file should look like this:

```
server {
          client_max_body_size 100m;
          server_name bohemia.ihi.or.tz;

          location / {
              proxy_pass http://127.0.0.1:8080;
          }
      }
```
- Run the following to configure/install ODK Aggregate:
```
sudo aggregate-cli -i -y -c /root/aggregate-config.json
```

- Restart nginx:
```
sudo service nginx restart
```

### Create an SSH key

#### On Windows using Putty

(To be filled out by Imani)

#### On Ubuntu

- If you don’t have an SSH key on your system yet, run the following:
`ssh-keygen -t rsa -b 4096 -C “youremail@host.com”`
- Select defaults (ie, press enter when it asks you the location, password, etc.)
- You will now have a file at `/home/<username>/.ssh/id_rsa`
- To verify, type: `ls ~/.ssh/id_*` (this will show your key)
- To change permissions to be slightly safer, run the following: `chmod 400 ~/.ssh/id_rsa`


### Managing users (ie, creating ssh keypairs for other users)

- SSH into the server
- Create a `.ssh` directory for the new user and change permissions:
`mkdir .ssh; chmod 700 .ssh`
- Create a file named “authorized_keys” in the `.ssh` dir and change permissions: `touch .ssh/authorized_keys; chmod 600 .ssh/authorized_keys`
- Open whatever public key is going to be associated with this user (the .pub file) and paste the  content into the authorized_keys file (ie, open authorized_keys in nano first and then copy-paste from your local machine)

### Log in using ssh key-pair

```
ssh -i <path to private key> bohemia@bohemia.ihi.or.tz
```

### Setting up certbot

```
sudo certbot run --nginx --non-interactive --agree-tos -m imaniirema@gmail.com --redirect -d bohemia.ihi.or.tz
```

## Setting up the server

- In the web browser, go to https://bohemia.ihi.or.tz/
- Log in with default credentials:
  - administrator
  - aggregate
- Go to "Site Admin" tab
- Uncheck all items for "anonymous user"
- Save
- Create users


# Data collection

This is the end of the admin's guide. The data collection guide is available [HERE](guide_data_collection.md).
