# Admin guide for setting up the Bohemia directory shiny application

The below guide is a walk-through of setting up the Bohemia directory shiny web application. Note, this guide was influenced by some of the steps [here](https://abndistro.com/post/2019/07/06/deploying-a-shiny-app-with-shiny-server-on-an-aws-ec2-instance/).

## Buy a domain

- Go to domains.google.com and buy a domain.
- For the purposes of this guide, the domain being used is `www.bohemia.team`


## Get an EC2 instance

- Use the RStudio AMI at https://console.aws.amazon.com/ec2/home?region=us-east-2#launchAmi=ami-09aea2adb48655672
- Go through all the steps making no changes to the configuration.
- Select to use an existing keypair OR configure a key pair as per instructions (see more in next section if you don't yet have a keypair)
- Click on Launch instance.


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
18.218.87.64
```

### Associate the domain and IP address

- Go to domains.google.com
- Select the purchased domain (ie, bohemia.team) and click "Manage"
- Click "DNS"
- Scroll down to "Custom resource records"
- Create an @ / A entry with the IP address (18.218.87.64
)
- Create a www / CNAME entry with the public DNS (ec2-18-218-87-64.us-east-2.compute.amazonaws.com)



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
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-18-218-87-64.us-east-2.compute.amazonaws.com
or
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.team
```

- Congratulations! You are now able to run linux commands on your new ubuntu server
- If you want, create an alias such as:
```
alias shiny='ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.team'
```
- Add the above line to ~/.bashrc to persist
- Run `source ~/.bashrc`
- Now you can simply run `shiny` to ssh into the server

### Setting up https

- You may need to wait a few minutes after setting up the domain before obtaining an https certificate.
- Run the following to get an https certificate set up:
```
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx
sudo certbot run --nginx --non-interactive --agree-tos -m joebrew@gmail.com --redirect -d bohemia.team
```
- Note, replace "joebrew@gmail.com" and "bohemia.team" with your email and domain, respectively
  - (As an alternative to the above, you can get a CDN on cloudflare, and in the "DNS" section of domains.google.com, set the "Name servers" to the 2 provided by Cloudfare (may take 1 hour or so to work))
- As per the instructions in the terminal, run a test on the new site at: https://www.ssllabs.com/ssltest/analyze.html?d=bohemia.team


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
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.team
```
or
```
shiny # if you set up the alias as per previous instructions
```

## Installing some Libraries

We'll install some libraries (most are installed via the AMI, but we'll have this here to catch those that weren't):
```
sudo apt-get -y install \
    nginx \
    gdebi-core \
    apache2-utils \
    pandoc \
    pandoc-citeproc \
    libssl-dev \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libxml2-dev \
    libxt-dev \
    libv8-dev
sudo apt-get update
sudo apt-get install default-jre
sudo apt-get install default-jdk
sudo R CMD javareconf
```

## Install R, shiny, and RStudio server

(No need, since it's all already installed via the AMI)


## Install git and clone the directory

```
sudo apt install git
cd /home/ubuntu/
mkdir Documents
cd Documents
git clone https://github.com/databrew/bohemia
cd /home/rstudio/ShinyApps
sudo cp -r /home/ubuntu/Documents/bohemia/shiny .
cd shiny
```

- To keep the repo up to date later:
```
cd /home/ubuntu/Documents/bohemia
git pull
cd /home/rstudio/ShinyApps/shiny
sudo cp /home/ubuntu/Documents/bohemia/shiny/app.R /home/rstudio/ShinyApps/shiny/app.R
sudo cp /home/ubuntu/Documents/bohemia/shiny/set_up_database.R /home/rstudio/ShinyApps/shiny/set_up_database.R
sudo cp /home/ubuntu/Documents/bohemia/shiny/global.R /home/rstudio/ShinyApps/shiny/global.R
```

## Set up RStudio for the browser

- Click on "Security Groups" in the AWS web console
- Click on the one associated with the AMI image
- Configure the Security Group to allow inbound HTTP (port 80) traffic
- Configure to allow all IP inbound/outbound traffic on port 3838
- Go back to the EC2 dashboard
- Copy and paste the instance ID into the web browser: ec2-18-218-87-64.us-east-2.compute.amazonaws.com
- Sign in with username rstudio and the password (instance id - get it from the EC2 instance menu)
- To remove it: sudo apt-get remove --purge rstudio-server


## Set up postgresql database

```
sudo apt install postgresql-10
sudo -i -u postgres
createuser --interactive
- name of role: ubuntu
- superuser: y
createuser --interactive
- name of role: rstudio
- superuser: y
createuser --interactive
- name of role: shiny
- superuser: y
createdb ubuntu
createdb rstudio
createdb shiny
exit
psql
create database directory;

sudo -u postgres psql
grant all privileges on database directory to shiny
```

## Copy private files from local machine to remote machine

Remote machine:
```
sudo mkdir /home/rstudio/ShinyApps/shiny/data/
sudo mkdir /home/rstudio/ShinyApps/shiny/credentials/
```
Local machine:
```
scp -i "/home/joebrew/.ssh/openhdskey.pem" /home/joebrew/Documents/bohemia/shiny/data/database.xlsx ubuntu@bohemia.team:/home/ubuntu/database.xlsx

scp -r -i "/home/joebrew/.ssh/openhdskey.pem" /home/joebrew/Documents/bohemia/shiny/credentials ubuntu@bohemia.team:/home/ubuntu/credentials
```
Remote machine:
```
sudo cp /home/ubuntu/database.xlsx /home/rstudio/ShinyApps/shiny/data/database.xlsx

sudo cp -r /home/ubuntu/credentials /home/rstudio/ShinyApps/shiny/credentials
```

## Get the app data set up

```
cd /home/rstudio/ShinyApps/shiny
R
sudo su - -c "R -e \"install.packages('readxl')\""
sudo su - -c "R -e \"devtools::install_github('rstudio/DT')\""
sudo su - -c "R -e \"install.packages('shinydashboard')\""
sudo su - -c "R -e \"install.packages('shiny')\""
sudo su - -c "R -e \"install.packages('RPostgreSQL')\""
sudo su - -c "R -e \"install.packages('devtools')\""
sudo su - -c "R -e \"install.packages('tidyverse')\""
sudo su - -c "R -e \"install.packages('xlsx')\""

Rscript set_up_database.R
```

## Set up shiny server

- Copy our app to the deploy zone:
```
sudo cp -r /home/rstudio/ShinyApps/shiny /srv/shiny-server/
```

- Launch a sample app:
```
sudo /opt/shiny-server/bin/deploy-example default
```

- Copy our app to the launch zone:
```
sudo cp -r /home/rstudio/ShinyApps/shiny /srv/shiny-server/sample-apps/
sudo cp -r /home/rstudio/ShinyApps/shiny /srv/shiny-server/
sudo systemctl restart shiny-server
```

- Ensure permissions are okay:
```
sudo ufw allow 3838/tcp
sudo ufw allow 80/tcp
cd /srv/shiny-server
chmod 555 shiny
sudo systemctl restart shiny-server
```

# The website is now live at http://bohemia.team:3838/shiny/
