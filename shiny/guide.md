# Admin guide for setting up the Bohemia directory shiny application

The below guide is a walk-through of setting up the Bohemia directory shiny web application.

## Buy a domain

- Go to domains.google.com and buy a domain.
- For the purposes of this guide, the domain being used is `www.bohemia.team`

## Spin up an EC2 instance on AWS

_The below should only be followed for the case of a remote server on AWS. In production, sites will use local servers, physically housed at the study sites. In the latter case, skip to the [Setting up OpenHDS section](https://github.com/databrew/bohemia/blob/master/guide/guide.md#setting-up-openhds)_

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
- Choose the instance type: General purpose, t2.micro (free tier eligible)
- Click on Next: Configure Instance Details.
- Select the VPC you previously created in the Network dropdown ("aggregate-vpc")
- Select "Enable" in the Auto-assign Public IP dropdown.
- Select the IAM role you previously created in the IAM role dropdown.
- Click on Next: Add Storage and edit the storage settings. Keep as default of 8gb.
- Click on Next: Add Tags.
- Skip the tags section
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

We'll install some libraries:
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
```

## Install R, shiny, and RStudio server

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo apt update
sudo apt install r-base r-base-core r-recommended


sudo add-apt-repository ppa:marutter/c2d4u3.5
sudo apt-get update

sudo su - -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""


sudo R
install.packages('devtools')
install.packages('shiny')
```

```
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.12.933-amd64.deb
sudo gdebi shiny-server-1.5.12.933-amd64.deb
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5019-amd64.deb
sudo gdebi rstudio-server-1.2.5019-amd64.deb
```

## Install R packages

```
sudo R
install.packages(c('httpuv', 'shiny', 'rmarkdown', 'shinydashboard', 'shinyjs'))

## hadleyverse
install.packages(c('ggplot2', 'dplyr', 'tidyr', 'readr', 'lazyeval', 'stringr', 'ggthemes', 'ggExtra', 'magrittr', 'viridis', 'gridExtra', 'lubridate', 'fasttime', 'data.table'))

## spatial analysis
install.packages(c('sp', 'rgdal', 'rgeos', 'adehabitatHR', 'geojsonio', 'maptools'))

## htmlwidgets
install.packages(c('leaflet', 'highcharter'))

## additional packages specific to the directory app
install.packages(c('ggplot2', 'devtools', 'RPostgreSQL'))

## packages from github
library(devtools); install_github('rstudio/DT')
```

## Install git and clone the directory

```
sudo apt install git
mkdir Documents
cd Documents
```
