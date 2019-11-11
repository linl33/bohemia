# Admin guide for setting up the Bohemia project data system (ODK+)

The below guide is a walk-through of setting up the Bohemia data infrastructure. It assumes you are running a cloud server on AWS (which will not be the case for local sites). For local servers, much of the ssh, tunneling, etc. sections can simply be ignored/altered.

## Buy a domain

- Go to domains.google.com and buy a domain.
- For the purposes of this guide, the domain being used is `www.bohemia.systems`

## Spin up an EC2 instance on AWS


#### Create a VPC configuration
- Log into the AWS console: aws.amazon.com
- Go to the VPC dashboard: https://console.aws.amazon.com/vpc/home#dashboard
- Click "Launch VPC Wizard"
- Follow the wizard for the VPC with a Single Public Subnet configuration.
- Enter aggregate-vpc (or your desired name) as the name and description.
- Select the VPC you previously created.
- Click on Create.
- Click on the newly created security group from the list, click on the Inbound rules tab, the Edit rules.
- Set the below rules:
  - SSH: Anywhere
  - HTTP: Anywhere
  - HTTPS: Anywhere
  - (For Mirth to work, you also need to add Anywhere access on HTTP and HTTPS for ports 8082 and 8443)
- Save rules

#### Create an IAM role
- Go to the IAM - Roles tab (https://console.aws.amazon.com/iam/home#/roles)
- Click "Create role"
- Select "AWS service" and click "EC2"
- Click "Next:Permissions"
- Search for "AmazonEC2ReadOnlyAccess" and select it
- Click "Next:Tags". Do nothing.
- Click "Next: Review"
- Enter "aggregate-role" as the name
- Click "Create role"


#### Create an EC2 machine
- Go to the EC2 dashboard (https://console.aws.amazon.com/ec2/v2/home#Home)
- Click the “Launch a virtual machine” option under “Build a solution”
- Select "Ubuntu Server 18.04 LTS (HVM), SSD Volume Type"
-To the far right select 64-bit (x86)  
- Click “select”  
- Choose the instance type: General purpose, t2.small (or larger)
- Click on Next: Configure Instance Details.
- Select the VPC you previously created in the Network dropdown ("aggregate-vpc")
- Select "Enable" in the Auto-assign Public IP dropdown.
- Select the IAM role you previously created in the IAM role dropdown.
- Toggle the Advanced Details section and copy and paste the below (based on [this](https://raw.githubusercontent.com/opendatakit/aggregate/master/cloud-config/aws/cloud-config.yml) script:

```
#cloud-config

packages:
  - zip
  - unzip
  - wget
  - curl
  - tomcat8
  - tomcat8-common
  - tomcat8-admin
  - tomcat8-user
  - postgresql-10
  - openjdk-8-jdk-headless
  - nginx
  - software-properties-common
  - awscli

write_files:
  - path: /root/aggregate-config.json
    content: |
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
          "hostname": "foo.bar",
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
  - path: /tmp/nginx-aggregate
    content: |
      server {
          client_max_body_size 100m;
          server_name foo.bar;

          location / {
              proxy_pass http://127.0.0.1:8080;
          }
      }
  - path: /usr/local/bin/download-aggregate-cli
    permissions: '0755'
    content: |
      #!/bin/sh
      curl -sS https://api.github.com/repos/opendatakit/aggregate-cli/releases/latest \
      | grep "aggregate-cli.zip" \
      | cut -d: -f 2,3 \
      | tr -d \" \
      | wget -O /tmp/aggregate-cli.zip -qi -

      unzip /tmp/aggregate-cli.zip -d /usr/local/bin
      chmod +x /usr/local/bin/aggregate-cli
  - path: /root/.aws/config
    permissions: '0644'
    content: |
      [default]
      region = foobar
      output = text

runcmd:
  - download-aggregate-cli

  - unattended-upgrades
  - apt-get -y autoremove

  - rm /etc/nginx/sites-enabled/default
  - mv /tmp/nginx-aggregate /etc/nginx/sites-enabled/aggregate

  - add-apt-repository -y universe
  - add-apt-repository -y ppa:certbot/certbot
  - apt-get -y update
  - apt-get -y install python-certbot-nginx
  - (crontab -l 2>/dev/null; echo "0 0 1 * * /usr/bin/certbot renew > /var/log/letsencrypt/letsencrypt.log") | crontab -

  - su postgres -c "psql -c \"CREATE ROLE aggregate WITH LOGIN PASSWORD 'aggregate'\""
  - su postgres -c "psql -c \"CREATE DATABASE aggregate WITH OWNER aggregate\""
  - su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE aggregate TO aggregate\""
  - su postgres -c "psql -c \"CREATE SCHEMA aggregate\" aggregate"
  - su postgres -c "psql -c \"ALTER SCHEMA aggregate OWNER TO aggregate\" aggregate"
  - su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON SCHEMA aggregate TO aggregate\" aggregate"

  - sed -i -e 's/foobar/'"$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/ | sed 's/.$//')"'/' /root/.aws/config
  - aws ec2 describe-tags | grep "aggregate.hostname" | grep "$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" | awk -F' ' '{print $5}' > /tmp/domain-name
  - sed -i -e 's/foo\.bar/'"$(cat /tmp/domain-name)"'/' /root/aggregate-config.json
  - sed -i -e 's/foo\.bar/'"$(cat /tmp/domain-name)"'/' /etc/nginx/sites-enabled/aggregate

  - aggregate-cli -i -y -c /root/aggregate-config.json

  - service nginx restart
```
- Click on Next: Add Storage and edit the storage settings. Set to a minimum of 30gb.
- Click on Next: Add Tags.
- Add `aggregate.hostname` key with the domain name as the value (e.g., `bohemia.systems`). Important. You need to have purchased the hostname prior to doing this (ie, don't use your IP address, use an actual DNS)
- Click on Next: Configure Security Group.
- Select an existing security group and select the security group you previously created.
- Click on Review and Launch and after review, click on Launch.
- Select to use an existing keypair OR configure a key pair as per instructions (see more in next section if you don't yet have a keypair)
- Click on Launch instances.


#### Configuring a key pair  

- A modal will show up saying “Select an existing key pair or create a new key pair”
- Select “Create a new key pair”
- Name it “openhdskey”
- Download the `.pem` file into your `/home/<username>/.ssh/id_rsa` directory
- If that directory does not exist, run the steps in the next section (“Setting up SSH keys”)
- Run the following to change permissions on your key: `chmod 400 ~/.ssh/openhdskey.pem`
- Click “Launch instances”
- Wait a few minutes for the system to launch (check the "launch log" if you’re impatient)
- Click on the name of the instance (once launched)
- This will bring you to the instances menu, where you can see things (in the “Description” tab below) like public IP address, etc.

### Allocate a persistent IP

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
18.218.151.100
```

### Setting up SSH keys

- If you don’t have an SSH key on your system yet, run the following:
`ssh-keygen -t rsa -b 4096 -C “youremail@host.com”`
- Select defaults (ie, press enter when it asks you the location, password, etc.)
- You will now have a file at `/home/<username>/.ssh/id_rsa`
- To verify, type: `ls ~/.ssh/id_*` (this will show your key)
- To change permissions to be slightly safer, run the following: `chmod 400 ~/.ssh/id_rsa`

### Connect to the servers

- In the “Instances” menu, click on “Connect” in the upper left
- This will give instructions for connecting via an SSH client
- It will be something very similar to the following:

```
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-18-218-151-100.us-east-2.compute.amazonaws.com
or
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.systems
```

- Congratulations! You are now able to run linux commands on your new ubuntu server
- If you want, create an alias such as:
```
alias odk='ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.systems'
```
- Add the above line to ~/.bashrc to persist

### Setting up the domain

- In domains.google.com, click on the purchased domain.
- Click on "DNS" on the left
- Go to "Custom resource records"
- You're going to create two records:
  1. Name: @; Type: A; TTL 1h; Data: 18.218.151.100
  2. Name: www; Type: CNAME; TTL: 1h; Data: ec2-18-218-151-100.us-east-2.compute.amazonaws.com.


### Setting up https

- You may need to wait a few minutes after setting up the domain before obtaining an https certificate.
- Run the following to get an https certificate set up:
```
sudo certbot run --nginx --non-interactive --agree-tos -m joebrew@gmail.com --redirect -d bohemia.systems
```
- Note, replace "joebrew@gmail.com" and "bohemia.systems" with your email and domain, respectively
  - (As an alternative to the above, you can get a CDN on cloudflare, and in the "DNS" section of domains.google.com, set the "Name servers" to the 2 provided by Cloudfare (may take 1 hour or so to work))
- As per the instructions in the terminal, run a test on the new site at: https://www.ssllabs.com/ssltest/analyze.html?d=bohemia.systems



### Managing users (ie, creating ssh keypairs for other users)

- Having ssh’ed into the server, run the following: `sudo adduser <username_of_new_user>`
- Type a password
- Press “enter” for all other options
- To create a user with no password, run the following: `sudo adduser <username_of_new_user> --disabled-password`. For example:
`sudo adduser benmbrew --disabled-password`
- Switch to that user: `sudo su -  benmbrew`
- Create a `.ssh` directory for the new user and change permissions:
`mkdir .ssh; chmod 700 .ssh`
- Create a file named “authorized_+keys” in the `.ssh` dir and change permissions: `touch .ssh/authorized_keys; chmod 600 .ssh/authorized_keys`
- Open whatever public key is going to be associated with this user (the .pub file) and paste the  content into the authorized_keys file (ie, open authorized_keys in nano first and then copy-paste from your local machine)
Grant sudo access to the new users: `sudo usermod -a -G sudo benmbrew`


### Setting up Linux  

- SSH into the server:
```
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-18-218-151-100.us-east-2.compute.amazonaws.com
```
- You now have an up-and-running instance with some software already installed (stuff installed via the cloud config script)
  - For example, postgres, tomcat, awscli, openjdk-8-jre-headless, etc. are already installed, etc.
- Run the following after ssh'ing into the server: `sudo apt-get update`


### Setting up java

- Java is already installed, but you need to set the `JAVA_HOME` environment variable. To do so:
- `sudo nano /etc/environment`
- Add line like `JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"`
- Run `source /etc/environment`

## Setting up ODKAggregate

The `cloud-config` script previously run installs ODKAggregate. However, because we need to do some configuration

- Navigate to http://bohemia.systems/ in the browser.
- You'll be reedirected to http://bohemia.systems/Aggregate and prompted to log in.
- Sign-in with the credentials `administrator` (username) and `aggregate` (password)
- Click on the "Site Admin" tab
- Create a new user called "data" with password "data"
- Check all boxes for the `data` Username
- Click "Save changes"
- Log out
- Log in as data/data to ensure that everything worked.
- Change the `administrator` password to `data`

# Managing the census form

- The master "census" xls form is [HERE](https://docs.google.com/spreadsheets/d/16_drw-35haLaBlB6tn92mr6zbIuYorAUDyieGONyGTM/edit#gid=141178862)
- Changes should be made on that form.
- Following changes, the form should be downloaded as an excel file (`.xls`) and then converted to `.xml` format. To do this either:
  - Use [this online converter](https://xlsform.opendatakit.org/)
  - Or convert locally using the python tools described below

## Setting up python tools

There are some tools that help to both download the census excel from google docs as well as convert it to xml. This can all be done in the `scripts/census_excelt_xml.py` script. To prepare your system to run it:

- Clone the bohemia github repo: `git clone https://github.com/databrew/bohemia`
- Create a virtual environment to be used with python's package manager. Follow [these steps](https://itnext.io/virtualenv-with-virtualenvwrapper-on-ubuntu-18-04-goran-aviani-d7b712d906d5).  Then `mkvirtualenv bohemia`
- Get inside the virtual environment (`workon bohemia`) and intall python pacakges: `pip install -r requirements.txt`
- From within the main `bohemia` directory, `cd` into `scripts` and run `python census_excel_to_xml.py`


# Setting up enketo

(Much of the following is based on [this guide](https://blog.enketo.org/install-enketo-production-ubuntu/), but with some modifications for our server and use-case)

## Spin up an ubuntu machine on AWS

- Go to the EC2 dashboard (https://console.aws.amazon.com/ec2/v2/home#Home)
- Click the “Launch a virtual machine” option under “Build a solution”
- Select "Ubuntu Server 18.04 LTS (HVM), SSD Volume Type"
-To the far right select 64-bit (x86)  
- Click “select”  
- Choose the instance type: General purpose, t2.small
- Click on Next: Configure Instance Details.
- Select the VPC you previously created in the Network dropdown ("aggregate-vpc")
- Select "Enable" in the Auto-assign Public IP dropdown.
- Select the IAM role you previously created in the IAM role dropdown.
- Set security group to vpc-aggregate-group
- Set storage to 30 gb
- Click "Review and launch"
- Go to Elastic IPs and assign a stable one (we'll use the one previously created and linked to papu.us)
- On your local machine, add the following line to `~/.bashrc` to create an alias:
```
alias enketo='ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@papu.us'
```

## Installing required software

- Log in as the enketo user (see above) and run the following line by line:
```
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get install -y git nginx htop build-essential redis-server checkinstall python
```
- Install NodeJS and global Node packages
```
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2 npm
```

-Let Ubuntu automatically install security updates (keep default values and select Yes when asked):
```
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Installing Enketo Express and its dependencies

- Run the following, line by line:
```
cd ~
git clone https://github.com/enketo/enketo-express.git
cd enketo-express
npm install --production
```
- (The above takes a little while)

## Configuring Enketo Express

### First, make an enketo account

- Go to https://accounts.enke.to/signup/plan/basic and make an account. In this case:
  - joebrew
  - joe@databrew.cc
  - <password>

### Database configuration

First we stop and remove the default redis service:

```
sudo systemctl stop redis
sudo systemctl disable redis
sudo systemctl daemon-reload
```

Then, we configure 2 new redis instances for Enketo that run on different ports:

```
sudo mv /etc/redis/redis.conf /etc/redis/redis-origin.conf
sudo cp ~/enketo-express/setup/redis/conf/redis-enketo-main.conf /etc/redis/
sudo cp ~/enketo-express/setup/redis/conf/redis-enketo-cache.conf /etc/redis/
sudo systemctl enable redis-server@enketo-main.service
sudo systemctl enable redis-server@enketo-cache.service
```

Now, start the 2 Enketo redis instances:

```
sudo systemctl start redis-server@enketo-main.service
sudo systemctl start redis-server@enketo-cache.service
```

Test: Cache database

```
redis-cli -p 6380
ping
exit
```

Test: Main database
```
redis-cli -p 6379
ping
exit
```

The response to both tests should be: “PONG”.

- Create a configuration file:
```
cp ~/enketo-express/config/default-config.json ~/enketo-express/config/config.json
```
- Edit it:
```

{
"app name": "Bohemia Enketo",
   "port": "8005",
   "offline enabled": true,
   "linked form and data server": {
       "name": "Bohemia",
       "server url": "bohemia.systems",
       "api key": "lpols3nboul",
       "legacy formhub": false,
       "authentication": {
           "type": "basic",
           "allow insecure transport": "true"
       }
   },
   "timeout": 300000,
   "expiry for record cache": 30000,
   "encryption key": "s0m3v3rys3cr3tk3y",
   "less secure encryption key": "this $3cr3t key is crackable",
   "default theme": "kobo",
   "themes supported": [],
   "base path": "enketo",
   "log": {
       "submissions": false
   },
   "support": {
       "email": "support@kobotoolbox.org"
   },

"widgets": [
        "note", "select-desktop", "select-mobile", "autocomplete", "geo", "textarea", "url",
        "table", "radio", "date", "time", "datetime", "select-media", "file", "draw", "rank",
        "likert", "range", "columns", "image-view", "comment", "image-map", "date-native", "date-nativ$
        "date-mobile", "text-max"
    ],
    "analytics": "google",
    "google": {
        "analytics": {
            "ua": "",
            "domain": ""
        },
        "api key": ""
    },
    "piwik": {
        "analytics": {
            "tracker url": "",
            "site id": ""
        }
    },
    "maps": [ {
        "name": "streets",
        "tiles": [ "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" ],
        "attribution": "© <a href=\"http://openstreetmap.org\">OpenStreetMap</a> | <a href=\"www.opens$
    } ],

"query parameter to pass to submission": "",
"redis": {
    "main": {
        "host": "127.0.0.1",
        "port": "6379",
        "password": null
    },
    "cache": {
        "host": "127.0.0.1",
        "port": "6380",
        "password": null
    }
},
"logo": {
    "source": "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET$
    "href": ""
},
"disable save as draft": false,
"repeat ordinals": false,
"validate continuously": false,
"validate page": true,
"payload limit": "100kb",
"text field character limit": 2000
}

```

- Rebuild:
```
cd ~/enketo-express
npm install --production
```

- Start enketo:
```
npm start
```
- Check that it's running at papu.us:8005
-Configure pm2 to make sure that the server automatically starts up upon reboot:
```
cd ~/enketo-express
pm2 start app.js -n enketo
pm2 save
sudo pm2 startup ubuntu -u enketo  # ? ubuntu
```

- Ban rogue users:
```
sudo apt-get install -y fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo service fail2ban restart
```
- Set up firewall (NOT DOING FOR NOW):
```
sudo apt-get install ufw
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
sudo ufw status
```

## Final configuration


- Set up https
```
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt install certbot
sudo apt-get -y update
sudo apt-get -y install python-certbot-nginx
sudo certbot run --nginx --non-interactive --agree-tos -m joebrew@gmail.com --redirect -d papu.us
```

## Create back-ups  

- The database is at `/var/lib/redis/enketo-main.rdb`
- First, give ubuntu access permission:
```
sudo usermod -a -G redis ubuntu
```
- To copy it to back-up locally, run the following:
```
sudo systemctl stop redis-server@enketo-main.service
scp -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@papu.us:/var/lib/redis/enketo-main.rdb backup.rdb
systemctl start redis-server@enketo-main.service
```

## Managing forms

- Go to https://accounts.enke.to/account/ to manage accounts
- To delete a form, run the following:
```
curl -X DELETE --user lpols3nboul: -d "server_url=https://bohemia.systems&form_id=census" http://papu.us/api/v1/survey
```


# Data collection

This is the end of the admin's guide. The data collection guide is available [HERE](guide_data_collection.md).
