
<div>

<img src="img/bohemia_logo.jpg" alt="" width="200" />
<img src="img/logo.png" width="100" />

</div>

# Data management and analytic plan: Bohemia demographics

<span style="font-size:20px;">Table of contents</span>

  - [Executive summary](#executive-summary)
  - [Data acquisition](#data-acquisition-)
      - [Forms](#forms)
          - [Form roster](#form-roster)
          - [XLSForm standards and rules](#xlsform-standards-and-rules)
      - [Versioning](#versioning)
          - [Technical standards](#technical-standards)
          - [Testing](#testing-)
          - [Production versions](#production-versions)
      - [Data collection software](#data-collection-software)
          - [Software installation](#software-installation)
          - [Setting up fieldworker
            credentials](#setting-up-fieldworker-credentials-)
          - [Set up ODKCollect](#set-up-odkcollect)
          - [Synchronizing ODKCollect](#synchronizing-odkcollect)
          - [Filling out a form](#filling-out-a-form)
          - [Sending data](#sending-data)
          - [Syncronizing](#syncronizing)
  - [Data pipeline](#data-pipeline-)
      - [Setting up ODK Aggregate](#setting-up-odk-aggregate-)
          - [Preliminaries](#preliminaries-)
          - [Install software](#install-software)
      - [Setting up ODK Briefcase](#setting-up-odk-briefcase)
          - [Configure ODK Briefcase (for GUI
            use)](#configure-odk-briefcase-\(for-gui-use\))
          - [Get data via ODK Briefcase (for CLI
            use)](#get-data-via-odk-briefcase-\(for-cli-use\))
      - [Setting up an enketo server](#setting-up-an-enketo-server)
          - [Configuration](#configuration)
      - [Data fetching and storage](#data-fetching-and-storage-)
          - [General overview](#general-overview)
          - [Database set up](#database-set-up)
          - [Data Update](#data-update)
      - [Backups](#backups)
          - [Backups overview](#backups-overview)
          - [Bucket set-up](#bucket-set-up)
  - [Automated detection of
    anomalies](#automated-detection-of-anomalies-)
      - [Schema](#schema)
      - [Operational elements](#operational-elements)
          - [Processes](#processes)
          - [Roles](#roles-)
      - [Engineering elements](#engineering-elements)
          - [Registry of anomalies and
            errors](#registry-of-anomalies-and-errors)
          - [Code standards for the
            registry](#code-standards-for-the-registry)
          - [Flow for identification and exposition of anomalies and
            errors](#flow-for-identification-and-exposition-of-anomalies-and-errors)
          - [The `corrections` table](#the-%60corrections%60-table-)
          - [Code standards for database “cleaning”
            code](#code-standards-for-database-%22cleaning%22-code-)
      - [Data access](#data-access)
          - [Set up your credentials
            file](#set-up-your-credentials-file)
          - [Access data](#access-data)
  - [Data-related operations](#data-related-operations-)
      - [Registry and enrollment of
        fieldworkers](#registry-and-enrollment-of-fieldworkers-)
      - [Things to know](#things-to-know)
      - [Steps](#steps)
          - [Step 1: Register the worker](#step-1:-register-the-worker)
          - [Step 2: Give ID card](#step-2:-give-id-card)
          - [Step 3: Set up GPS tracking](#step-3:-set-up-gps-tracking)
          - [Step 4: Set up ODK Collect](#step-4:-set-up-odk-collect)
      - [Deployment of geocoding teams](#deployment-of-geocoding-teams)
          - [Operational flow](#operational-flow)
          - [Accessing the form](#accessing-the-form)
          - [Geocoding](#geocoding)
          - [Saving and sending the form](#saving-and-sending-the-form)
          - [What happens after
            geocoding](#what-happens-after-geocoding)
      - [Refusals and absences](#refusals-and-absences)
          - [Over-arching principles](#over-arching-principles)
          - [Process](#process)
      - [Deployment of VA teams](#deployment-of-va-teams)
          - [Operational flow](#operational-flow)
          - [Accessing the form](#accessing-the-form)
      - [Locations hierarchy](#locations-hierarchy)
          - [Step 1: Populate the
            spreadsheet](#step-1:-populate-the-spreadsheet)
          - [Step 2: Process the
            spreadsheet](#step-2:-process-the-spreadsheet)
          - [Step 3: Generate the format for choices for
            ODK](#step-3:-generate-the-format-for-choices-for-odk)
          - [Step 4: Copy-paste into
            spreadsheets](#step-4:-copy-paste-into-spreadsheets)
  - [Analysis for study objectives](#analysis-for-study-objectives)
  - [Analysis for quality control and operational
    optimization](#analysis-for-quality-control-and-operational-optimization)
      - [GPS tracking](#gps-tracking-)
          - [Services used](#services-used)
          - [Steps](#steps)
          - [On server](#on-server)
      - [Web app](#web-app)

# Executive summary

This document containts the overview of how data is managed and analyzed
during the demographic/census phase of the Bohemia project. It is
largely a compilation of specific content-area technical and operational
documentation, written by the Databrew team, in the form of
[“guides”](https://github.com/databrew/bohemia/tree/master/guides).
These “guides” are intentionally dynamic, changing in response to both
(a) input or instructions from the sponsor or sites, (b) issues arising
in the field. Unlike a statistical analysis plan, this document largely
pertains to data flow (acquisition, processing, exposition, and storage)
and *operational* analysis.

# Data acquisition

Data is acquired by study fieldworkers visiting the households of study
participants and carrying out structured interviews based on questions
approved by the project, as well as all relevant ethical committees. The
“forms” used for these interview questions are digital, as is the
collection of responses.

## Forms

A “form” refers to a paper questionnaire which has been converted to a
digital format. Forms are designed (in “paper” format) by study
researchers, and are digitized by Databrew. Digitization consists of:
(a) translation of paper form to XLSForm, (b) conversion of the `.xlsx`
file for the form to `.xml`, (c) uploading of the `.xml` file to
servers, and finally (d) retrieval of uploaded `.xml` forms by tablets
from servers.

### Form roster

Forms used for the demography/census component of the Bohemia project
are:

  - `recon`: Reconnaissance of hamlets prior to household-level data
    collection  
  - `animalannex`: An annex to the reconnaissance form for eliciting
    information about animal ownership
  - `enumerations`: An operational form for documenting the enumeration
    of participating households (Mozambique only)
  - `minicensus`: Household-level census
  - `refusals`: An operational form for documention absences and
    refusals
  - `va153`: The WHO Verbal Autopsy form  
  - `census`: A household-level census, but with more fields and
    person-level questions than the `minicensus`

### XLSForm standards and rules

In order to ensure efficient and accurate processing of all data
collected via digital forms, and so as to make sure that data from the
site servers is correctly migrated to the project database, Databrew
requires that forms conform to certain standards:

1.  All `.xml` forms deployed on the ODK Aggregate server be generated
    via the `xls2xform` functionality (or via the python scripts for
    conversion in the `scripts` sub-directory), *not* via online
    converters.

2.  All repeat elements (ie, xlsform rows in which the type is `begin
    repeat`) must contain `repeat_` prefix in the `name` field.

3.  No non-repeat elements should contain the word `repeat` in the name
    field.

4.  All group elements (ie, xlsform rows in which the type is `begin
    group`) must contain `group_` prefix in the `name` field.

5.  No non-group elements should contain the word `group` in the name
    field.

6.  All note elements (ie, xlsform rows in which the type is `note`)
    must contain `note_` prefix in the `name` field.

7.  No non-note elements should contain the word `note` in the name
    field.

## Versioning

### Technical standards

All forms are versioned explicitly via a `version` field on the
`settings` tab of the associated XLSForm. This field takes the following
format:

    2020102303

Wherein the first 8 characters refer to the date of the version (in
`YYYYMMDD` format), and the final two characters refer to the
incrementing version for that day.

### Testing

Digital forms must undergo testing in order to ensure (a) correctness,
(b) flow, (c) compliance. Testing should be carried out prior to a
form’s deployment so as to implement changes (and increment the
version) prior to operations. When changes are required after
operations, it is important that the version be deployed to servers and
subsequently fetched by tablets in a minimal amount of time so as to
reduce the possibility of form mismatch.

### Production versions

What follows are the IDs and version strings for each of the forms
currently deployed:

  - `recon`: `recon2` / `2020090802`
  - `animalannex`: `animalannex` / `2020090901`
  - `enumerations`: `enumerations` / `2020101301`
  - `minicensus`: `smallcensusa` / `2020102303`
  - `refusals`: `refusals` / `2020101301`
  - `va153`: `va153` / `2020101201`
  - `census`: `census` / `2020101301`

## Data collection software

Data is collected via digital forms (previous section) using the
“ODKCollect” Android client application. What follows are the steps
required to configure the client application appropriately:

### Software installation

  - Fetch an android device (phone/tablet)
  - Download/Install [ODKCollect via Google
    Play](https://play.google.com/store/apps/details?id=org.odk.collect.android&hl=en)

### Setting up fieldworker credentials

  - You’ll be provided with credentials for the central server from the
    DataBrew team. For the purposes of this example, we’ll use the below
    credentials.
  - Username: data
  - Password: data

### Set up ODKCollect

  - Open ODKCollect
  - Click the three dots in the upper-right hand corner
  - Select “General Settings”
  - Click “Server”
  - Change the server URL to <https://bohemia.systems>
  - Set the credentials to `data` (user) and `data` (password)

### Synchronizing ODKCollect

  - In ODKCollect, select “Get Blank Form”
  - Select all the forms: -Census -VA Form -Click “Get Selected”

### Filling out a form

  - In ODKCollect, on the main page, click the top button (“Fill Blank
    Form”)
  - Select the form you wish to fill out (for example, “VA Form”)
  - Begin filling out form
  - To switch language, click the three dots in the upper right
  - Go question by question filling out the form
  - To advance to the next page or go back, swipe left or right
  - On the last page, click the “Save Form and Exit” button

### Sending data

  - With an internet connection, from the main page of ODKCollect, click
    “Send Finalized Form”
  - Select all and “Send”

### Syncronizing

  - When you have an internet connection, you should also syncronize
    with the main server
  - In order to do this, you need to go to the main page of ODK and
    select “Get Blank Form”
  - Then, select the census form (its updated version) and get it

# Data pipeline

The ODKCollect Android client application is only a front-end; it
requires a back-end in order to both (a) send form schemas and metadata
to the data acquisition devices and (b) receive collected data from
those devices. The “data pipeline” section describes the Bohemia
back-end, as well as the processes around data flow.

## Setting up ODK Aggregate

The back-end equivalent of the front-end “ODKCollect” application is
“ODKAggregate”, a server-side software running in TomCat on the Ubuntu
platform. Each site must deploy its own ODKAggregate instance on a
server in compliance with institutional policies. What follows are step
by step instructions for configuring an ODKAggregate server. For
simplicity and reproducibility’s sake, these instructions assume you are
running a cloud server on AWS. For local servers, AWS- and
domain-acquisition steps can simply be skipped.

### Preliminaries

#### Buy a domain

  - Go to domains.google.com and buy a domain.
  - For the purposes of this guide, the domain being used is
    `www.bohemia.systems`

#### Spin up an EC2 instance on AWS

##### Create a VPC configuration

  - Log into the AWS console: aws.amazon.com
  - Go to the VPC dashboard:
    <https://console.aws.amazon.com/vpc/home#dashboard>
  - Click “Launch VPC Wizard”
  - Follow the wizard for the VPC with a Single Public Subnet
    configuration.
  - Enter aggregate-vpc (or your desired name) as the name and
    description.
  - Select the VPC you previously created.
  - Click on Create.
  - Click on the newly created security group from the list, click on
    the Inbound rules tab, the Edit rules.
  - Set the below rules:
  - SSH: Anywhere
  - HTTP: Anywhere
  - HTTPS: Anywhere
  - (For Mirth to work, you also need to add Anywhere access on HTTP and
    HTTPS for ports 8082 and 8443)
  - Save rules

##### Create an IAM role

  - Go to the IAM - Roles tab
    (<https://console.aws.amazon.com/iam/home#/roles>)
  - Click “Create role”
  - Select “AWS service” and click “EC2”
  - Click “Next:Permissions”
  - Search for “AmazonEC2ReadOnlyAccess” and select it
  - Click “Next:Tags”. Do nothing.
  - Click “Next: Review”
  - Enter “aggregate-role” as the name
  - Click “Create role”

##### Create an EC2 machine

  - Go to the EC2 dashboard
    (<https://console.aws.amazon.com/ec2/v2/home#Home>)
  - Click the “Launch a virtual machine” option under “Build a solution”
  - Select “Ubuntu Server 18.04 LTS (HVM), SSD Volume Type” -To the far
    right select 64-bit (x86)  
  - Click “select”  
  - Choose the instance type: General purpose, t2.small
  - Click on Next: Configure Instance Details.
  - Select the VPC you previously created in the Network dropdown
    (“aggregate-vpc”)
  - Select “Enable” in the Auto-assign Public IP dropdown.
  - Select the IAM role you previously created in the IAM role dropdown.
  - Click on Next: Add Storage and edit the storage settings. Set to
    200gb
  - Click on Next: Add Tags.
  - Add `aggregate.hostname` key with the domain name as the value
    (e.g., `bohemia.systems`). Important. You need to have purchased the
    hostname prior to doing this (ie, don’t use your IP address, use an
    actual DNS)
  - Click on Next: Configure Security Group.
  - Select an existing security group and select the security group you
    previously created.
  - Click on Review and Launch and after review, click on Launch.
  - Select to use an existing keypair OR configure a key pair as per
    instructions (see more in next section if you don’t yet have a
    keypair)
  - Click on Launch instances.

##### Configuring a key pair

  - A modal will show up saying “Select an existing key pair or create a
    new key pair”
  - Select “Create a new key pair”
  - Name it “openhdskey”
  - Download the `.pem` file into your `/home/<username>/.ssh/id_rsa`
    directory
  - If that directory does not exist, run the steps in the next section
    (“Setting up SSH keys”)
  - Run the following to change permissions on your key: `chmod 400
    ~/.ssh/odkkey.pem`
  - Click “Launch instances”
  - Wait a few minutes for the system to launch (check the “launch log”
    if you’re impatient)
  - Click on the name of the instance (once launched)
  - This will bring you to the instances menu, where you can see things
    (in the “Description” tab below) like public IP address, etc.

##### Allocate a persistent IP

  - So that your AWS instance’s public IP address does not change at
    reboot, etc., you need to create an “Elastic IP address”. To do
    this:
  - Go to the EC2 dashboard in aws
  - Click “Elastic IPs” under “Network & Security” in the left-most menu
  - Click “Allocate new address”
  - Select “Amazon pool”
  - Click “Allocate”
  - In the allocation menu, click “Associate address”
  - Select the instance you just created. Also select the corresponding
    “Private IP”
  - Click “Associate”
  - Note, this guide is written with the below elastic id. You’ll need
    to replace this with your own when necessary.

<!-- end list -->

    18.218.151.100

##### Setting up SSH keys

  - If you don’t have an SSH key on your system yet, run the following:
    `ssh-keygen -t rsa -b 4096 -C “youremail@host.com”`
  - Select defaults (ie, press enter when it asks you the location,
    password, etc.)
  - You will now have a file at `/home/<username>/.ssh/id_rsa`
  - To verify, type: `ls ~/.ssh/id_*` (this will show your key)
  - To change permissions to be slightly safer, run the following:
    `chmod 400 ~/.ssh/id_rsa`

##### Connect to the servers

  - In the “Instances” menu, click on “Connect” in the upper left
  - This will give instructions for connecting via an SSH client
  - It will be something very similar to the
    following:

<!-- end list -->

    ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-18-218-151-100.us-east-2.compute.amazonaws.com
    or
    ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.systems

  - Congratulations\! You are now able to run linux commands on your new
    ubuntu server
  - If you want, create an alias such
    as:

<!-- end list -->

    alias odk='ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.systems'

  - Add the above line to ~/.bashrc to persist

#### Setting up the domain

  - In domains.google.com, click on the purchased domain.
  - Click on “DNS” on the left
  - Go to “Custom resource records”
  - You’re going to create two records:

<!-- end list -->

1.  Name: @; Type: A; TTL 1h; Data: 18.218.151.100
2.  Name: www; Type: CNAME; TTL: 1h; Data:
    ec2-18-218-151-100.us-east-2.compute.amazonaws.com.

### Install software

    sudo apt-get update

#### Install Java

    sudo apt install openjdk-8-jdk openjdk-8-jre
    # Verify installation
    java -version

##### Setting up java

  - Java is already installed, but you need to set the `JAVA_HOME`
    environment variable. To do so:
  - `sudo nano /etc/environment`
  - Add line like `JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"`
  - Run `source
    /etc/environment`

#### Install tomcat

    sudo apt-get install tomcat8 tomcat8-common tomcat8-user tomcat8-admin

#### Other packages

    sudo apt-get install zip
    sudo apt-get install unzip
    sudo apt-get install wget
    sudo apt-get install curl

##### PostgreSQL

Ubuntu 18:

    sudo apt-get install postgresql-10

Ubuntu
    16:

    # on Ubuntu 16, this requires more than just the above. See: https://www.liquidweb.com/kb/install-and-connect-to-postgresql-10-on-ubuntu-16-04/:
    # Ubuntu 16 only:
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'
    sudo apt-get -y update
    sudo apt-get install postgresql-10
    sudo apt-get install nginx
    sudo apt-get install software-properties-common

#### Write configuration files

  - `touch /root/aggregate-config.json`
  - `sudo nano /root/aggregate-config.json`
  - Paste the following content:

<!-- end list -->

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
    "hostname": "bohemia.systems",
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

  - `sudo touch /tmp/nginx-aggregate`
  - `sudo nano /tmp/nginx-aggregate`
  - Add the following content:

<!-- end list -->

    server {
    client_max_body_size 100m;
    server_name foo.bar;
    
    location / {
    proxy_pass http://127.0.0.1:8080;
    }
    }

  - `sudo touch /usr/local/bin/download-aggregate-cli`
  - `sudo chmod 0755 /usr/local/bin/download-aggregate-cli`
  - `sudo nano /usr/local/bin/download-aggregate-cli`
  - Paste the following content

<!-- end list -->

    #!/bin/sh
    curl -sS https://api.github.com/repos/opendatakit/aggregate-cli/releases/latest \
    | grep "aggregate-cli.zip" \
    | cut -d: -f 2,3 \
    | tr -d \" \
    | wget -O /tmp/aggregate-cli.zip -qi -
    
    unzip /tmp/aggregate-cli.zip -d /usr/local/bin
    chmod +x /usr/local/bin/aggregate-cli

  - `sudo mkdir /root/.aws`
  - `sudo touch /root/.aws/config`
  - `sudo nano /root/.aws/config`
  - Paste the following:

<!-- end list -->

    [default]
    region = foobar
    output = text

  - Run the following:

<!-- end list -->

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

  - Open the following file and change “foo.bar” to the correct dns

<!-- end list -->

    sudo nano /etc/nginx/sites-enabled/aggregate

  - The file should look like this:

<!-- end list -->

    server {
    client_max_body_size 100m;
    server_name bohemia.systems;
    
    location / {
    proxy_pass http://127.0.0.1:8080;
    }
    }

  - Run the following to configure/install ODK Aggregate:

<!-- end list -->

    sudo aggregate-cli -i -y -c /root/aggregate-config.json

  - Restart nginx:

<!-- end list -->

    sudo service nginx restart

#### Managing users (ie, creating ssh keypairs for other users)

  - Having ssh’ed into the server, run the following: `sudo adduser
    <username_of_new_user>`
  - Type a password
  - Press “enter” for all other options
  - To create a user with no password, run the following: `sudo adduser
    <username_of_new_user> --disabled-password`. For example: `sudo
    adduser benmbrew --disabled-password`
  - Switch to that user: `sudo su - benmbrew`
  - Create a `.ssh` directory for the new user and change permissions:
    `mkdir .ssh; chmod 700 .ssh`
  - Create a file named “authorized\_+keys” in the `.ssh` dir and change
    permissions: `touch .ssh/authorized_keys; chmod 600
    .ssh/authorized_keys`
  - Open whatever public key is going to be associated with this user
    (the .pub file) and paste the content into the authorized\_keys file
    (ie, open authorized\_keys in nano first and then copy-paste from
    your local machine) Grant sudo access to the new users: `sudo
    usermod -a -G sudo benmbrew`

#### Setting up ODKAggregate

  - Navigate to <http://bohemia.systems/> in the browser.
  - You’ll be reedirected to <http://bohemia.systems/Aggregate> and
    prompted to log in.
  - Sign-in with the credentials `administrator` (username) and
    `aggregate` (password)
  - Click on the “Site Admin” tab
  - Create a new user called “data” with password “data”
  - Check all boxes for the `data` Username
  - Click “Save changes”
  - Log out
  - Log in as data/data to ensure that everything worked.
  - Change the `administrator` password to `data`

#### Setting up python tools

There are some tools that help to both download the census excel from
google docs as well as convert it to xml. This can all be done in the
`scripts/census_excel_xml.py` script. To prepare your system to run it:

  - Clone the bohemia github repo: `git clone
    https://github.com/databrew/bohemia`
  - Create a virtual environment to be used with python’s package
    manager. Follow [these
    steps](https://itnext.io/virtualenv-with-virtualenvwrapper-on-ubuntu-18-04-goran-aviani-d7b712d906d5).
    Then `mkvirtualenv bohemia`
  - Get inside the virtual environment (`workon bohemia`) and intall
    python pacakges: `pip install -r requirements.txt`
  - From within the main `bohemia` directory, `cd` into `scripts` and
    run `python census_excel_to_xml.py`

## Setting up ODK Briefcase

ODK Briefcase is a desktop application which can be used to migrate
forms between servers. Though not part of the envisioned data pipeline,
a change in server infrastructure or hosting may require its use. What
follows are instructions for the application’s installation.

  - Create a directory for placing the Briefcase `.jar` file:

<!-- end list -->

    cd ~/Documents
    mkdir briefcase
    cd briefcase
    mkdir storage
    mkdir exports

  - Download the program into the newly created directory by running the
    following:

<!-- end list -->

    wget https://github.com/opendatakit/briefcase/releases/download/v1.16.1/ODK-Briefcase-v1.16.1.jar

  - Create an alias to easily open the Briefcase program by coping the
    below line into
    `~/.bashrc`:

<!-- end list -->

    alias briefcase='java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar &'

  - Run `source ~/.bashrc`
  - Then, to run the program, simply type `briefcase` into the terminal
  - A window will popup.

### Configure ODK Briefcase (for GUI use)

  - In the “Settings” tab, set the “Storage Location” to:
    `~/Documents/briefcase/storage`
  - In the “Pull” tab, click the “Configure” button next to the “Pull
    from” field with “Aggregate server” selected. Type in the following:
  - URL: `https://datacat.cc/ODKAggregate`
  - Username: `data`
  - Password: `data`
  - The forms should now populate in the “Pull” tab as below:

![](img/briefcase.png)

  - In the “Push” tab, click the “Configure” button next to the “Push
    to” field with “Aggregate server” selected. Type in the following:

  - URL: `https://datacat.cc/ODKAggregate`

  - Username: `data`

  - Password: `data`

  - Go back to the “Pull” tab

  - Click “Select All” in the bottom left

  - Click “Pull”

  - Go to the “Export” tab

  - Click “Set Default Configuration”

  - Set “Export directory” to `~/Documents/briefcase/exports`

  - Click “Select all”

  - Click
    “Export”

### Get data via ODK Briefcase (for CLI use)

Pull:

    java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar --pull_aggregate --storage_directory ~/Documents/briefcase/storage --aggregate_url https://datacat.cc/ODKAggregate --odk_username data --odk_password data

Export (for a form with form\_id =
    “censusmember”):

    java -jar ~/Documents/briefcase/ODK-Briefcase-v1.16.1.jar --export --form_id censusmember --storage_directory ~/Documents/briefcase/storage --export_directory ~/Documents/briefcase/exports --export_filename censusmember.csv

## Setting up an enketo server

Forms are available in machine-readable `.xml` and human-readable
`.xlsx`. However, there are times where a human needs to explore a
form’s flow and is not able to do so on a tablet (for example, those
without android devices). Accordingly, it is useful to be able to deploy
forms via the web browswer as well. for this, Databrew has a dedicated
“enketo” server.

The following is an overview of how to deploy the enketo server for
serving digitized forms in the web browswer.

  - (Much of the following is based on [this
    guide](https://blog.enketo.org/install-enketo-production-ubuntu/),
    but with some modifications for our server and use-case)
  - Important configuration details at
    <https://enketo.github.io/enketo-express/tutorial-10-configure.html>

### Configuration

#### Launch an instance

\-Follow the steps in the [ODK set up guide](guide_odk_setup.md). Small,
15 gb, open security. -For this example, we’ll use the domain papu.us

#### Set up with domain

  - Via domains.google.com

#### Set up the enketo user

\-SSH into the machine:

    ssh -i "/home/joebrew/.ssh/odkkey.pem" ubuntu@papu.us

    sudo adduser enketo --disabled-password;
    sudo mkdir /home/enketo/.ssh;
    sudo chown enketo:enketo /home/enketo/.ssh;
    sudo cp ~/.ssh/authorized_keys /home/enketo/.ssh;
    sudo chown enketo:enketo /home/enketo/.ssh/authorized_keys;
    sudo chmod 600 /home/enketo/.ssh/authorized_keys;
    sudo usermod -a -G sudo enketo;

Now type `sudo visudo` and add the following line to the end of the file

    enketo     ALL=(ALL) NOPASSWD:ALL

#### Set up shortcut

On local machine, add this to ~/.bashrc

    alias enketo='ssh -i "/home/joebrew/.ssh/odkkey.pem" enketo@papu.us'

Then run:

    source ~/.bashrc

Log out, then log in again by simply typing `enketo`

#### Installing required software

  - Log in as the enketo user (see above) and run the following LINE BY
    LINE:

<!-- end list -->

    sudo apt-get update;
    sudo apt-get upgrade -y;
    sudo apt-get autoremove -y;
    sudo apt-get install -y git nginx htop build-essential redis-server checkinstall python;
    sudo apt-get install -y gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

  - Install NodeJS and global Node packages

<!-- end list -->

    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g pm2 npm

\-Let Ubuntu automatically install security updates (keep default values
and select Yes when asked):

    sudo dpkg-reconfigure -plow unattended-upgrades

#### Installing Enketo Express and its dependencies

  - Run the following, line by line:

<!-- end list -->

    cd ~
    sudo git clone https://github.com/enketo/enketo-express.git
    cd enketo-express
    sudo chown -R 1001:1001 "/home/enketo/.npm"
    npm config set unsafe-perm=true
    sudo chown -R $USER:$(id -gn $USER) /home/enketo/.config
    sudo mkdir /home/enketo/enketo-express/node_modules
    npm rebuild node-sass
    sudo npm install --production

  - (The above takes a while)

#### Database configuration

Set up redis

    sudo systemctl stop redis;
    sudo systemctl disable redis;
    sudo systemctl daemon-reload;
    sudo mv /etc/redis/redis.conf /etc/redis/redis-origin.conf;
    sudo cp ~/enketo-express/setup/redis/conf/redis-enketo-main.conf /etc/redis/;
    sudo cp ~/enketo-express/setup/redis/conf/redis-enketo-cache.conf /etc/redis/;
    sudo systemctl enable redis-server@enketo-main.service;
    sudo systemctl enable redis-server@enketo-cache.service;
    sudo systemctl start redis-server@enketo-main.service;
    sudo systemctl start redis-server@enketo-cache.service;

Test: Cache database

    redis-cli -p 6380
    ping
    exit

Test: Main database

    redis-cli -p 6379
    ping
    exit

The response to both tests should be: “PONG”.

#### Set up logo

  - Send a file from local to the remote server:

<!-- end list -->

    # remote
    sudo mkdir /home/enketo/Documents
    cd /home/enketo
    sudo chmod 777 Documents
    #local
    scp -i ~/.ssh/odkkey.pem ~/Documents/bohemia/misc/img/logo.png enketo@18.190.57.240:/home/enketo/Documents/logo.png
    scp -i ~/.ssh/odkkey.pem /home/joebrew/Documents/bohemia/misc/enketo-config.json enketo@18.190.57.240:/home/enketo/Documents/enketo-config.json
    scp -i ~/.ssh/odkkey.pem /home/joebrew/Documents/bohemia/misc/enketo-config.json enketo@18.190.57.240:/home/enketo/Documents/enketo-config.json
    # remote
    sudo cp /home/enketo/Documents/enketo-config.json /home/enketo/enketo-express/config/config.json
    sudo cp /home/enketo/Documents/enketo-config.json /home/enketo/enketo-express/config/default-config.json # this is strange, but apparently matters - need to overwrite the default
    sudo cp /home/enketo/Documents/logo.png /home/enketo/enketo-express/public/images/logo.png

  - Rebuild:

<!-- end list -->

    cd ~/enketo-express
    sudo npm install --production

  - Start enketo:

<!-- end list -->

    #pm2 kill
    #sudo kill -9 $(sudo lsof -t -i:8005) # to kill anything already on that port
    npm start

  - Check that it’s running at papu.us:8005
  - Configure pm2 to make sure that the server automatically starts up
    upon reboot. Do this in a new terminal:

<!-- end list -->

    cd ~/enketo-express
    pm2 start app.js -n enketo
    pm2 save
    sudo pm2 startup ubuntu -u enketo

#### Pointing ODK to the right place

  - Go to bohemia.systems and click on Site Admin -\> Preferences
  - Fill out the credentials as per below

![](img/enketo.png)

API URL: <http://papu.us:8005/api/v1> API TOKEN: lpols3nboul

Test that it’s working (ie, that we get a 201 response for this query)
(won’t work until configuring ODK agg
    server):

    curl --user lpols3nboul: -d "server_url=https://bohemia.systems&form_id=census" http://papu.us:8005/api/v1/survey

curl –user lpols3nboul: -d
“server\_url=<https://bohemia.systems/Aggregate.html&form_id=census>”
<http://papu.us:8005/api/v1/survey>

#### Managing forms

  - See API documentation here: <https://apidocs.enketo.org/v1>

  - To delete a form, run the
    following:

<!-- end list -->

    curl -X DELETE --user lpols3nboul: -d "server_url=https://bohemia.systems/Aggregate&form_id=census" http://papu.us/api/v2/survey

## Data fetching and storage

### General overview

The ODK utilities in the `bohemia` R package (main wrapper function:
`odk_get_data`) are used for fetching data from ODK Aggregate databases.
Second, cleaning/formatting functions in the `bohemia` R package are
used to process the data so as to conform with database standards.
Third, the script in `scripts/bohemia_db_schema.sql` is used to set up
the PosgreSQL database. Finally, upload functions in the `bohemia` R
package are used to send data to the database.

The above is all run automatically every N minutes via crontab which
executes the script at `scripts/run_odk_get_data_cron.sh`.

### Database set up

#### Deploy

  - Go to the Amazon RDS page:
    <https://eu-west-3.console.aws.amazon.com/rds/home?region=eu-west-3#>  

  - Click “Create database”  

  - Select “Amazon Aurora” and ensure the edition is “with PostgreSQL
    compatibility”  

  - Set version to 11.6  

  - Select “Production” under “Templates”  

  - For DB cluster identifier, type “bohemiacluster”  

  - For master username, use the master username in the credentials
    file: `psql_master_username`

  - For master password, use the master password in the credentials
    file: `psql_master_password`

  - Set “DB instance size” to “Memory optimized” and leave the instance
    type as is (2 cpus, 16 g ram)  

  - For availability and durability, select yes for creating a different
    node in a different zone  

  - Use default VPC  

  - Click additional connectivity configuration  

  - Under “Public access”, click “yes”  

  - For VPC security group, click “Create new” and call it
    “bohemiadbgroup”  

  - Keep database port as 5432  

  - For database authentication, select “Password and IAM database
    authentication”  

  - Under additional configuration:

  - Intitial database name: `bohemia`  

  - You’ll now see the `bohemiacluster` database set up at `endpoint`
    (in the credentials file)

  - In the browswer, go to
    <https://eu-west-3.console.aws.amazon.com/ec2/v2/home?region=eu-west-3#SecurityGroups>
    and modify inbound and outbound rules to accept all traffic.

  - You can connect to the db like this:  

<!-- end list -->

    psql \
    --host=<ENDPOINT> \
    --port=5432 \
    --username=<psql_master_username>\
    --password

  - A password will be prompted

#### Populate

  - Connect to the db (see above)  
  - Run the following:  

<!-- end list -->

    CREATE DATABASE bohemia;

  - Now disconnect and re-connect to the database as per below:

<!-- end list -->

    psql \
    --host=<ENDPOINT> \
    --port=5432 \
    --username=<psql_master_username>\
    --password\
    --dbname=bohemia

  - Copy paste the code from `scripts/bohemia_db_schema.sql`

#### Creating the “clean” tables

  - Clean tables are structurally a copy of their similarly named
    “non-clean” counterparts (with the `clean_` prefix).  
  - Clean tables differ from their non-clean counterparts in that they
    may undergo manual modifications (ie, “data cleaning”).  
  - These manual modifications are stored in the `xxx` script.

At first-go, to create the clean tables, run: `create_clean_db()`

To drop all of the clean tables, run: `create_clean_db(drop_all = TRUE)`

To carry out the “cleaning” (ie, execute changes on the newly-created
clean tables), run: `clean_db()`

### Data Update

  - Having retrieved the data, the code for updating it is in
    `scripts/update_database.R`.  
  - As mentioned in the General Overview section, the `bohemia` R
    package (main wrapper function: `odk_get_data`) used for fetching
    data from ODK is run every N minutes automatically. This section
    details the steps to deploy and set it up on AWS EC2 instances.

#### CronTab Set Up

1.  SSH into the `shiny` server (deployed at bohemia.team). The reason
    for using the shiny server is that it has the necessary R packages.

2.  Run (on the shell): `crontab -e`

<!-- end list -->

1.  In the crontab editor opened, type in for an automatic run every 42
    minutes past the
    hour:

<!-- end list -->

    42 * * * * sh /home/ubuntu/Documents/bohemia/scripts/run_odk_get_data_cron.sh > /home/ubuntu/Documents/bohemia/logs/backup.log 2>&1

2.  Save and exit the editor.

<!-- end list -->

3.  Wait for the time set to verify the job is run by checking the
    syslog for the entry: `tail -f /var/log/syslog | grep CRON`

#### CronTab Email Notification Set Up

1.  SSH into the `shiny` server (deployed at bohemia.team). The reason
    for using the shiny server is that it has the necessary R packages.

2.  Run (on the shell): `sudo apt install postfix mailutils libsasl2-modules postfix`

3.  Choose 'Internet site' and press `Enter`

4.  Accept the default domain in the 'Postfix Configuration' and press `Enter`

5.  Edit the config by typing `sudo nano /etc/postfix/main.cf`

6.  Add/Update the entries to be:
    ```
      myhostname = bohemia.team
      relayhost = [smtp.gmail.com]:587
      smtp_sasl_auth_enable = yes
      smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd
      smtp_sasl_security_options = noanonymous
      smtp_tls_security_level = encrypt
      header_size_limit = 4096000
    ```
7. Create the password map by typing `sudo nano /etc/postfix/sasl/sasl_passwd`

8. Type in the username and password of the email account 
   to be used for sending emails: 
   `[smtp.gmail.com]:587 yourgmailaddress:yourpassword` and save.

9. Run:
    ```
    sudo postmap /etc/postfix/sasl/sasl_passwd
    sudo chown -R root:postfix /etc/postfix/sasl
    sudo chmod 750 /etc/postfix/sasl
    sudo chmod 640 /etc/postfix/sasl/sasl_passwd
    ```

10. Restart the postfix service by running `sudo service postfix restart`

11. Test that the email setup works by running 
    `echo "Confirm email works test" | mail -s "Cron email test" joe@databrew.cc`

12. If you don't get an email, check the mail log at
    `tail -10 /var/log/mail.log` to review the issue.

13. For Gmail, you should have an email or a security alert. 
    Follow the instructions in the security alert email to 
    guide you to the option to 
    `Allow less secure apps` set this to `ON`

<!-- end list -->

1.  Open the crontab editor, type just above the cron above the line 
    where the entries you wish to email notifications are:

<!-- end list -->

    MAILTO="joe@databrew.cc,wanjiru@databrew.cc"
    42 * * * * sh /home/ubuntu/Documents/bohemia/scripts/run_odk_get_data_cron.sh

2.  Save and exit the editor.

<!-- end list -->

3.  Wait for the time set to verify the job is run by checking the
    syslog for the entry: `tail -f /var/log/syslog | grep CRON` and 
    your inbox.

## Backups

  - All data needs to be regularly backed up in case of server failure.
  - Local sites have their own backup policies and practices. These
    should be applied for the Bohemia project. These are not described
    in this document.
  - In addition, we will implement a project-level backup strategy. This
    document describes the technical underpinnings of that strategy.

### Backups overview

  - Project-level backups will be stored:

<!-- end list -->

1.  On AWS S3 (cloud)
2.  On hard drives (physical)

<!-- end list -->

  - 5 databases will be backed up:

<!-- end list -->

1.  The PostgreSQL `aggregate` database on the IHI server.
2.  The PostgreSQL `aggregate` database on the CISM server.
3.  The PostgreSQL `bohemia` database (ie, “study database”) on
    Databrew’s `bohemia.systems` server.
4.  The MySQL `traccardb` database on Databrew’s `bohemia.fun` server.
5.  A flat file of fieldworker IDs and contact info.

<!-- end list -->

  - Backups will be generated daily via the following sequential steps:

<!-- end list -->

1.  SQL “dump” of all data
2.  Automated transfer of data to cloud server (AWS S3 bucket,
    henceforth called the “bohemia bucket”)
3.  Automated copy of cloud server contents to local (physical) hard
    drive

### Bucket set-up

  - The following describes the exact steps taken to set up the bohemia
    bucket.
  - These steps do not need to be carried out by local sites.
  - Local sites will be provided with scripts and instructions for
    setting up the backup tools.
  - These steps are outlined here for the purposes of transparency and
    reproducibility only.

##### Create bucket

  - Go to <https://s3.console.aws.amazon.com/s3>
  - Click “Create bucket”
  - Set the “Bucket name” field to `databrewbohemia`
  - Set the region to “EU (Paris)”

##### Configure bucket

  - Once created, click on the bucket
  - Click “Access points”
  - Click “Create access point”
  - Create an access point named `joebrew`
  - Set “Network access type” to `internet`
  - Keep public access blocked
  - Copy the Amazon Resource name code (ARN). It will looke like this
    (example only):

<!-- end list -->

    arn:aws:s3:eu-west-3:671670783497:accesspoint/joebrew

  - Copy the arn code

##### Generate security credentials

  - Go to the AWS console, click on your name in the upper right, and
    then click “My security credentials”
  - Click “Access keys”
  - Click “Create new access keys”
  - Download the `rootkey.csv` file
  - Copy the following parameters to a file on your system named
    `credentials.yaml`:
  - Access Key ID (call it `aws_access_key_id`)
  - Secret Access Key (call it `aws_secret_access_key`)

##### Set up AWS CLI

  - Run the following:

<!-- end list -->

    sudo apt-get install awscli

  - Run `aws configure`
  - Enter in the parameters
  - For “Default region name”, use `eu-west-3`
  - Keep default output format as `None`

##### Test the bucket (optional)

  - Check out the contents of the `databrewbohemia` bucket by running:

<!-- end list -->

    aws s3 ls s3://databrewbohemia

\-The following example creates a file locally called `example.txt` and
then moves it to the s3 bucket in `folder/subfolder`:

    touch example.txt
    echo -e "this\nis\na\ntest" >> example.txt
    aws s3 cp example.txt s3://databrewbohemia/folder/subfolder/example.txt

  - Check in the web browswer that everything was created
  - To delete:

<!-- end list -->

    aws s3 rm s3://databrewbohemia/folder/subfolder/example.txt

##### Set up data dumps

  - Make the database trust local connections:

<!-- end list -->

    sudo nano /etc/postgresql/10/main/pg_hba.conf
    
    local   all             postgres                                peer # Change this line:
    
    local   all             postgres                                trust # To this line:

  - Restart postgres:

<!-- end list -->

    /etc/init.d/postgresql reload

##### On the ODK Aggregate server

  - On the server, create a folder for dumps:

<!-- end list -->

``` 
mkdir ~/Documents
cd ~/Documents
mkdir dumps/
sudo chmod -R 775 dumps/  
```

  - In that folder, create a `backup.sh` file and make it executable:

<!-- end list -->

    touch ~/Documents/dumps/backup.sh
    sudo chmod +x  ~/Documents/dumps/backup.sh

  - Open the file and copy and paste the below information (changing the
    `server` variable to one of `bohemiasystems`, `ihi`, or `cism`):

<!-- end list -->

``` 

server=bohemiasystems
bucket=databrewbohemia
folder=aggregate
dateValue=`(date --iso-8601=seconds)`
file=${dateValue}.sql
resource="/${bucket}/${server}/${folder}/${file}"


sudo service tomcat8 stop //// Stop running tomcat


pg_dump aggregate -U postgres > ${file} //// Run the dump


sudo service tomcat8 start 


aws s3 cp ${file} s3:/${resource}
rm ${file}
```

##### For backing up the bohemia database (using same server)

Modify the ~/Documents/dumps/backup.sh file by adding the following
lines:

    dateValue=`(date --iso-8601=seconds)`
    password=<PASSWORD GOES HERE>
    endpoint=<ENDPOINT GOES HERE>
    bucket=databrewbohemia
    server=bohemia
    folder=bohemia
    file=${dateValue}.sql
    resource="/${bucket}/${server}/${folder}/${file}"
    pg_dump --dbname=postgresql://postgres:${password}@bohemiacluster.cluster-carq1ylei7sf.eu-west-3.rds.amazonaws.com:5432/bohemia > ${file}
    aws s3 cp ${file} s3:/${resource}
    rm ${file}

##### On the traccar server (bohemia.fun)

  - On the server, create a folder for dumps:

<!-- end list -->

``` 
mkdir ~/Documents
cd ~/Documents
mkdir dumps
sudo chmod -R 775 dumps/  
```

  - In that folder, create a `backup.sh` file and make it executable:

<!-- end list -->

    touch ~/Documents/dumps/backup.sh
    sudo chmod +x  ~/Documents/dumps/backup.sh

  - Open the file and copy and paste the below information (replacing
    the text within `<>` with the appropriate user and password for the
    `traccardb` database):

<!-- end list -->

``` 

server=bohemiafun
bucket=databrewbohemia
folder=traccardb
dateValue=`(date --iso-8601=seconds)`
file=${dateValue}.gz
resource="/${bucket}/${server}/${folder}/${file}"


mysqldump -u <traccar_mysql_local_user> -p<traccar_mysql_local_pass> traccardb | gzip > ${file} # Run the dump

aws s3 cp ${file} s3:/${resource}
rm ${file}
```

#### Automation

  - Log onto the server.
  - Create a place to store crontb logs: `sudo mkdir /var/log/dumps;
    sudo chmod -R 700 /var/log/dumps/`
  - Use the edit functionality of crontab: `crontab -e`

<!-- end list -->

    0 1 * * * /home/ubuntu/Documents/dumps/backup.sh

To back up every day at 1:00 AM, add the above line.

# Bohemia R package

Databrew has built an R package for the Bohemia project. This package
contains utilities used by the Bohemia research team. It is publicly
available for the purposes of reproducibility and transparency.

## Installation and removal

To install this package: - Clone the parent repo: `git clone
https://github.com/databrew/bohemia` - `cd` into `rpackage` - Run
`Rscript build_package.R`

Alternatively, one can install directly from github:

To remove the package (for example, so as to re-install for an update),
simply run: \`remove.packages(‘bohemia’)

The package is fully documented and downloadable here:
<https://github.com/databrew/bohemia/tree/master/rpackage/bohemia#bohemia-the-r-package-of-the-bohemia-project>

# Automated detection of anomalies

The Bohemia data pipeline consists of a semi-structured “data cleaning”
process wherein anomalies and errors are automatically identified and
data managers provide “resolutions” in a semi-structured format via web
app. This document describes the process.

Note: this document only refers to “in-app” anomalies and errors (ie,
corrections to the database *after* data has already been collected).
“In-form” warnings and constraints are a different process.

## Schema

The “data cleaning” process can be understood visually below:

![](img/data_cleaning.png)

## Operational elements

### Processes

The data cleaning process consists of the following processes:

  - Automatically identify anomalies and errors on raw data
  - Manually submit “resolutions” (fixes) to these anomalies and
    errors  
  - Manually write SQL code to implement resolutions  
  - Run SQL code so as to generate “clean” data  
  - Infinitely repeat process (but now running the anomaly and error
    identification code on the “cleaned” rather than raw data)

### Roles

Operationally, the data cleaning process requires input from at least
the following two roles:

1.  Site data manager: receives anomaly and error notifications in the
    “Alerts” section of the app, and submits the resolution (“fix”)
    for those anomalies/errors  
2.  Databrew: receives fix requests from site data manager, and
    “translates” those requests to SQL operations which modify the
    underlying data

The site data manager will sometimes be able to resolve an alert on his
own. For example, he may recognize that a submission has been flagged
for having too many household members, but he knows that this particular
submission was just a technical test he carried out (and therefore
submits the modification request of “delete”). In many cases, however,
he will require other roles in order to properly carry out function 1.
Specifically, he’ll need to interact with: - Supervisors (in order to
request confirmations / corrections regarding an erroneous or anomalous
event)  
\- Fieldworkers (in order to ask for confirmations / corrections
regarding an erroneous or anomalous event)  
\- Databrew (in order to request, if applicable, supplementary data on
the error/anomaly)

## Engineering elements

### Registry of anomalies and errors

  - A registry of anomalies and errors exists in spreadsheet format
    [HERE](https://docs.google.com/spreadsheets/d/1MH4rLmmmQSkNBDpSB9bOXmde_-n-U9MbRuVCfg_VHNI/edit#gid=0).
  - In this registry, each row is a “check”. For example, “check to see
    if there are any pregnant people younger than 13”.
  - Each “check” gets run against the data for a site:
  - If the check “passes” (ie, no anomaly or error is detected), no
    action is required.
  - If the check “fails”, action is required (to be taken by the data
    manager):
  - If the failed check consisted of an anomaly, the “action” can be one
    of three things:

<!-- end list -->

1.  Confirm correctness (ie, “this person is indeed pregnant”)  
2.  Delete (ie, “this person does not exist”)  
3.  Modify (ie, “this person is indeed 13, but not pregnant”)  

<!-- end list -->

  - If the failed check consisted of an error, the “action” can be only
    the latter two items (ie, one cannot confirm correctness of an
    error)
  - The registry is maintained by Databrew. Changes to the registry
    should be carried out in coordination with Databrew.

### Code standards for the registry

  - The registry consists of two columns for writing code:
    `identification_code` and `incident_code`.  
  - The standards for writing conformant code are as follows:
  - Refer to tables with a `data$` prefix.
  - `identification_code` should produce a dataframe named `result`.  
  - `incident_code` should manipulate one row of `result` (referred to
    as `result_row`) so as to generate a character vector of length 1
    (the text to be shown to the data manager explaining the error and
    action required).

In order to test out writing `identification_code` and `incident_code`
snippets, a developer can set up her environment as follows (assuming at
Bohemia project directory):

    library(yaml)
    library(bohemia)
    library(RPostgres)
    library(dplyr)
    creds <- yaml::yaml.load_file('credentials/credentials.yaml')
    
    psql_end_point = creds$endpoint
    psql_user = creds$psql_master_username
    psql_pass = creds$psql_master_password
    drv <- RPostgres::Postgres()
    con <- dbConnect(drv, dbname='bohemia', host=psql_end_point,
    port=5432,
    user=psql_user, password=psql_pass)
    
    data <- list()
    main <- dbGetQuery(con, paste0("SELECT * FROM clean_minicensus_main"))
    data$minicensus_main <- main
    ok_uuids <- paste0("(",paste0("'",main$instance_id,"'", collapse=","),")")
    
    repeat_names <- c("minicensus_people",
    "minicensus_repeat_death_info",
    "minicensus_repeat_hh_sub",
    "minicensus_repeat_mosquito_net",
    "minicensus_repeat_water")
    for(i in 1:length(repeat_names)){
    this_name <- repeat_names[i]
    this_data <- dbGetQuery(con, paste0("SELECT * FROM clean_", this_name, " WHERE instance_id IN ", ok_uuids))
    data[[this_name]] <- this_data
    }
    enumerations <- dbGetQuery(con, "SELECT * FROM clean_enumerations")
    data$enumerations <- enumerations
    
    va <- dbGetQuery(con, "SELECT * FROM clean_va")
    data$va <- va
    refusals <- dbGetQuery(con, "SELECT * FROM clean_refusals")
    data$refusals <- refusals
    dbDisconnect(con)

The developer now has an object named `data` to be operated on.

### Flow for identification and exposition of anomalies and errors

1.  Anomaly and error *types* are registered in [the anomaly and error
    registry](https://docs.google.com/spreadsheets/d/1MH4rLmmmQSkNBDpSB9bOXmde_-n-U9MbRuVCfg_VHNI/edit#gid=0)  
2.  The Bohemia R package function `identify_anomalies_and_errors` is
    run in the back-end of Bohemia web application  
3.  The result of `identify_anomalies_and_errors` (ie, a long list of
    errors and anomalies) is exposed in a table in the web-app  
4.  Data managers go row-by-row in the table and submit corrections /
    confirmations (ie, semi-structured comments regarding which
    remediative action should be taken).  
5.  The corrections / confirmations submitted by the data managers get
    stored in the `corrections` table in the Bohemia database.  
6.  Databrew codifies corrections in the `scripts/clean_database.R`
    script. This serves as both (a) a functional script to implement
    corrections, (b) a log of all changes to “raw” data.

### The `corrections` table

  - The `corrections` table is a table is the Bohemia PostgreSQL
    database with one row for each anomaly / error identified via the
    previously-mentioned mechanisms.  
  - The `corrections` table consists of the following columns:
  - `id`: the ID of the anomaly, as generated by
    `identify_anomalies_and_errors`
  - `response_details`: the action to be taken (free text), as indicated
    by the data manager(s).  
  - `resolved_by`: the person (fieldworker, etc.) who resolved the
    issue  
  - `resolution_method`: how the issue was resolved (for example, house
    visit, phone call, etc.).
  - `resolution_date`: the date that the resolution took place
  - `submitted_by`: the data manager who submitted the resolution
    (captured automatically)
  - `submitted_at`: the date-time at which the data manager submitted
    the resolution
  - `done`: invisible in web-app; whether the action has been taken or
    not, as indicated by Databrew.  
  - `done_by`: invisible in web-app; who (Databrew team member)
    implemented the action.  
  - Rows of the `corrections` table are generated by the Shiny app (ie,
    when a data manager indicates correction to be made)  
  - The `done` and `done_by` columns of the `corrections` table are
    modified by Databrew (following the former)

### Code standards for database “cleaning” code

  - Corrections are codified in `scripts/clean_database.R`  
  - Running this script takes the “raw” data, modifies it (individual
    entries, each corresponding to an entry in the `corrections` table),
    and then generates “clean” data with `clean_` prefixes in the
    database.

## Data access

### Set up your credentials file

To use the Bohemia data access tools, it is advisable to first: - Clone
the Bohemia code repository: `git clone
https://github.com/databrew/bohemia` - Create a directory in the cloned
repo named `credentials` - In the credentials directory, create a file
named `credentials.yaml` - Populate the `credentials.yaml` file with the
following parameters

    country: MOZ # or TZA
    moz_odk_server: https://bohemia.systems # will change
    moz_odk_user: data # will change
    moz_odk_pass: data # will change
    
    tza_odk_server: https://bohemia.ihi.or.tz
    tza_odk_user: data # will change
    tza_odk_pass: data # will change
    
    databrew_odk_server: https://bohemia.systems # will change
    databrew_odk_user: data # will change
    databrew_odk_pass: data # will change
    
    odk_database: aggregate
    odk_database_host: <request from databrew>
    odk_database_user: aggregate
    odk_database_pass: aggregate
    odk_database_schema: aggregate
    
    traccar_server: https://bohemia.fun
    traccar_db: traccardb
    traccar_mysql_remote_user: <request from databrew>
    traccar_mysql_remote_pass: <request from databrew>
    traccar_mysql_remote_host: <request from databrew>
    traccar_mysql_local_user: <request from databrew>
    traccar_mysql_local_pass: <request from databrew>
    traccar_mysql_local_host: <request from databrew>
    
    shiny_server: https://bohemia.team
    
    aws_access_key_id: xxx
    aws_secret_access_key: xxx
    aws_default_region_name: eu-west-3

  - Henceforth, references in this guide wrapped in `<>` refer to
    variables from this credentials file.

### Access data

#### Tablet locations

  - Tablet locations are stored in a MySQL database running on a server
    located at `<traccar_server>`
  - To access the database directly via the MySQL CLI, one can
    run:

<!-- end list -->

    mysql <traccar_db> -h <traccar_mysql_remote_host> -u <traccar_mysql_remote_user> -p

  - When prompted, supply the `<traccar_mysql_remote_pass>`
  - The main table of interest is `tc_positions`, whose `deviceid` field
    refers to the `id` variable of `tc_devices`
  - Example query:

<!-- end list -->

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

  - Alternatively, once could run the query directly in the same command
    as the
    connection:

<!-- end list -->

    mysql mysql <traccar_db> -h <traccar_mysql_remote_host> -u <traccar_mysql_remote_user> -p<traccar_mysql_remote_pass> -e "select * from tc_devices limit 5;";

#### ODK Aggregate data

  - ODK Aggregate data is stored in a PostgreSQL database running on a
    server located at `<databrew_odk_server>`
  - To access the database directly, one should first ssh into the ODK
    Aggregate server
  - Then, one should get into the postgres user: `sudo su postgres`
  - Then, open the psql cli: `psql aggregate`
  - Finally, look at the data. For example:

<!-- end list -->

    select * from aggregate."RECON_CORE" ;

  - To see all the tables:

<!-- end list -->

    \dt aggregate.*;

#### The “Bohemia database”

The study database can be accessed programatically via the following:

    psql \
    --host=<HOST> \
    --port=5432 \
    --username=<USERNAME>\
    --dbname=bohemia\
    --password

# Data-related operations

In order to work correctly, some componenents of the data pipeline
requires certain operational processes to be carried out. These include:

  - The correct registry and enrollment of fieldworkers
  - The correct deployment of geocoding teams to geocode areas missed
    during the census interview (main census only)  
  - The correct registry of absences and refusals  
  - The correct deployment of VA teams to carry out verbal autopsy
    interviews following the identification of a death  
  - The correct creation of a “locations hierarchy” for the purpose of
    delineating administrative boundaries and population geographical
    drop-downs

## Registry and enrollment of fieldworkers

This is a straightforward, largely non-technical process, but should
only be handled by site data managers.

## Things to know

  - Any person who collects any data for the Bohemia project is
    considered a “worker”. This includes data managers, supervisors,
    etc. who collect recon data.
  - Every “worker” must be “registered” in the Bohemia system.
  - Every tablet must be configured for that worker.

## Steps

Step 1: Register the worker

  - Go to [THIS
    SPREADSHEET](https://docs.google.com/spreadsheets/d/1o1DGtCUrlBZcu-iLW-reWuB3PC8poEFGYxHfIZXNk1Q/edit#gid=490144130).
  - Select the tab for your country.
  - Enter the following details for the worker on the first available
    row:
  - `First name`
  - `Last name`
  - `ID of tablet` (TZA; MOZ?)
  - `Phone number of tablet` (TZA only)
  - `Phone number of person` (ie, their person cell phone number,
    including country code)
  - `Location` (ie, the area they will be deployed)
  - `Details` (optional, supplementary details)
  - `Start date` (the date they began employment with the project)
  - `End date` (the date they stopped working for the project; leave
    empty for currently employed workers)
  - By using the first available row, the QR code / ID number will be
    the lowest available country-specific number (001-300 for TZA;
    301-600 for MOZ; \> 600 for other).
  - *Never* delete a row. If a worker leaves the project, his/her ID
    number is simply retired. It should not be re-used.

Step 2: Give ID card

  - Step 1 (above) will result in a worker being assigned an ID number.
    The `bohemia_id` of row will be the worker’s ID number for the
    entirety of the Bohemia project.
  - A QR card should be given to the worker, and the worker should be
    told to memorize / write down their ID number (in case they lose the
    QR card).
  - These cards will be supplied by Databrew.
  - If you do not yet have the cards, or you need to print replacements,
    go to <https://bohemia.team/operations> and click on QR code
    generator
  - An ID should only be assigned to 1 worker
  - Even in the case of a worker leaving the project, his/her ID should
    never be re-assigned to someone else
  - Sufficient extra ID numbers / cards exist so that there is no need
    to “recycle” ID numbers
  - A fieldworker should only be assigned 1 ID.
  - If a QR code is lost, a replacement QR for that ID number should be
    generated via the tool at bohemia.team/operations.
  - Under no circumstances should a worker be given a new ID number

Step 3: Set up GPS tracking

  - For security and operational reasons, tablet locations will be
    tracked.
  - In order to enable tracking, each tablet must install the Traccar
    client via the [Google Play
    Store](https://play.google.com/store/apps/details?id=org.traccar.client)
  - After installation, open the Traccar app and provide the following
    details in configuration:
  - Set the “Device identifier” field to the ID number corresponding to
    your name:
  - Set the address of the server URL: `http://bohemia.fun`
  - Set the Frequency field to: `60`
  - Set location accuracy to: `high`
  - Do not change the Distance or Angles fields
  - At the top set “Service status” to on/running
  - Click on “Status” in the upper right to ensure that everything is
    working and data is sent correctly; It should show “Location
    update”; if it shows anything with the word “failure”, email
    <joe@databrew.cc>
  - More details are available in [this guide on GPS
    tracking](guide_gps_tracking_android.md)

Step 4: Set up ODK Collect

  - Download/Install [ODKCollect via Google
    Play](https://play.google.com/store/apps/details?id=org.odk.collect.android&hl=en)
  - Open ODKCollect
  - Click the three dots in the upper-right hand corner
  - Select “General Settings”
  - Click “Server”
  - Change the server URL to <https://bohemia.systems>
  - Set the credentials to `data` (user) and `data` (password)
  - Note that the URL, user, and pass may be different (for your local
    server)
  - More details are available in [this guide on configuring ODK
    Collect](guide_data_collection_odk.md)

## Deployment of geocoding teams

  - The Bohemia census includes several geocoding fields pertaining to
    (a) location of a household, (b) location of bodies of water, and
    (c) location of livestock.  
  - In general, these locations will be geocoded *during* the
    “interview” (ie, at the same time as the general census data
    collection).  
  - However, there may be some cases in which pausing the interview to
    carry out geocoding for (c) would result in undue operational
    burden.  
  - Example A: A census participant has many animals who sleep and eat
    in multiple locations, each between 500 and 1000 meters from the
    house. Going to each of these locations would result in hours of
    walking, which would disrupt the interview.
  - Example B: A census participant has only one location in which
    animals are held. However, the census participant and/or his/her
    family only have a short window of time before one or more of them
    have to leave (and the time does not permit going to geocode the
    location of the animals)
  - In the above cases, the fieldworker can choose to *not* geocode (ie,
    answer all questions but skip the geocoding fields).
  - In this case, as soon as the data is sent to the server, an alert
    will be sent to the data manager to deploy a separate geocoding
    team.
  - When able, the geocoding team will go to the household in question
    and carry out data capture related exclusively to geocoding animal
    locations.
  - What follows are instructions for carrying using the separate
    “geocoding” form.

### Operational flow

  - Census fieldworker skips 1 or more geocoding fields during interview
  - Census fieldworker submits form to server
  - Server automatically identifies the skipped field(s)
  - Data manager is automatically notified of the skipped field(s) and
    the relevant meta-information (household number and location,
    fieldworker in question)
  - Data manager deploys a geocoding team/individual to fill out the
    geocoding form (below)
  - Geocoding team goes to site in question, speaks with household head,
    goes to each location needing to be geocoded, and fills out form.
  - The geocoding form can be filled one (or MORE) times for one site.
  - Example: if young cattle and adult cattle graze in two different
    locations, the form should be filled out for both locations

### Accessing the form

  - Open ODK and select “Fill Blank Form”
  - Select the form titled “geocoding”

### Geocoding

  - Go to the area that should be geocoded and select the “Start
    GeoPoint” field.

<img src="img/geo.jpg" height="400">

  - You may be prompted to allow ODK to access your devices GPS
    functionality.

#### Location details (dry season)

  - On this page please select all the fields that apply to this
    location in the dry season.
  - For example, the image below indicates that this location is where
    Adult cattle graze, young cattle sleep, adult pigs graze, and young
    pigs sleep during the dry season.
  - It also indicates this is not where young cattle graze, adult pigs
    sleep and young pigs graze during the dry season, and that the
    respondent wasn’t sure if Adult cattle sleep in this area during the
    dry season.

<img src="img/dry_season.jpg" height="400">

  - Once you’ve completed this swipe to the next page.

#### Location details (wet season)

  - Similar to the last page, indicate which fields apply to the wet
    season.

  - For example, the image below indicates Young cattle and young pigs
    sleep at this location during the wet season, but only young cattle
    graze there too.

  - Once you’ve completed this swipe to the next page.

### Saving and sending the form

  - Select the “Save Form and Exit” field

<img src="img/save.jpg" height="400">

  - This will bring you back to the main menu.
  - Select “Send Finalized Form”.
  - Make sure the box to the right of the form name is “checked” and the
    select “Send Selected” to upload a finished form.

### What happens after geocoding

  - When a separate geocoding form is submitted (as per the above), the
    server-side data “pipeline” will automatically link the geocoded
    locations and meta-information with the missing/skipped fields from
    the original census questionnaire.

## Refusals and absences

### Over-arching principles

  - Everyone / anyone has the right to refuse / decline participation.  
  - All refusals should be documented via the
    [refusals](https://github.com/databrew/bohemia/tree/master/forms/refusals)
    form.  
  - All households (whether participating or not) are assigned a HH-ID
    number (in the case of a non-participating household, this ID number
    may be digital-only, ie not painted anywhere).

### Process

The process for identifying and logging refusals (ie, non-participating
households) is slightly different for MOZ versus TZA. The reason for
this difference is because: - MOZ uses the [“a priori” enumeration
method](https://github.com/databrew/bohemia/blob/master/misc/ids.md#method-1-a-priori)  
\- TZA uses the [“on the fly” enumeration
method](https://github.com/databrew/bohemia/blob/master/misc/ids.md#method-2-on-the-fly)

Because of these different methods, refusals can take place at different
times. What follows is a country-specific flow for when / how refusals
take place.

#### Shared principles: handling absences

In both the case of Mozambique and Tanzania, absences are handled
identically. If the person is absent when the house is visited, the
`refusals` form should be used to register the absence. The “Reason for
not participating” field should be marked as “Not present”.

Unlike a “refused” response, when a household is marked as “not
present”, that household will remain in visitation lists thereafter
(ie, they should be tried again).

A household is removed from visitation lists following three “not
present” entries.

#### Mozambique

  - The enumeration team goes to a hamlet.  

  - The enumeration team goes house-by-house to *every* house in that
    hamlet.  

  - *Every* house is registered either :

  - A. In the `enumerations` form (if they choose to participate)

  - B. In the `refusals` form (if they decline to participate)

  - Following enumeration, during the actual minicensus, the team goes
    back to the hamlet to collect data.

  - A. Houses which were enumerated can still refuse to participate at
    this point. If they do so, a `refusals` form should be filled out
    for the house in question. In this case, a household will have been
    enumerated but then refused (ie, shown up in both the enumerations
    table and the refusals table).  

  - B. Houses which refused to participate during enumerations do not
    need to be contacted again.

  - In summary, every househould will fit one of the following three
    patterns:

  - 1.  Refusal (occurred during enumeration)

  - 2.  Enumeration then refusal (refusal occurred during minicensus
        collection)

  - 3.  Enumeration then minicensus

  - There exists a fourth edge-case which is:

  - 4.  Minicensus (no enumeration)

  - The above can occur in the case of the enumeration team (a) missing
    a house or (b) a house being constructed after enumeration but prior
    to minicensus.

#### Tanzania

  - The data collection team goes to a hamlet.  
  - The data collection team goes house-by-house to *every* house in
    that hamlet.
  - *Every* house is registered either :
  - A. In the `minicensus` form (if they choose to participate)
  - B. In the `refusals` form (if they decline to participate)

## Deployment of VA teams

  - The Bohemia project will collect verbal autopsy (VA) data following
    the death of someone in the study area
  - A team (the “VA team”) will carry out post-mortem interviews using
    the digital [VA
    form](https://docs.google.com/spreadsheets/d/1BuRSJdWmottUW8SDnh8nGTkLCeTjEX3LgkRpaPvoKjE/edit#gid=1264701015)
  - These interviews will be carried out by someone *other* than the
    census team.
  - These interviews will be carried out during a *separate* visit from
    the census visit.

### Operational flow

  - Census fieldworker identifies a death (or deaths) (question 69 in
    the census household form: any deaths in past 12 months)
  - For each death, the census fieldworker collects basic data
    pertaining to:
  - Name, ID, gender, place of birth of the deceased
  - Place, date of death
  - Census fieldworker submits form to server
  - Server processes data
  - Data manager is automatically notified of the death(s) and the
    relevant meta-information (household number and location,
    fieldworker in question, information of deceased person, etc.)
  - Data manager deploys a VA team/individual to fill out the VA form
  - VA team goes to site in question, speaks with household head, and
    carries out a VA interview

### Accessing the form

  - The VA form will be hosted on the same server as the other Bohemia
    census forms (recon, census, etc.).
  - Refer to the general [Data collection
    guide](https://github.com/databrew/bohemia/blob/master/guides/guide_data_collection_odk.md)
    for instructions on configuring the application to retrieve the VA
    form

## Locations hierarchy

The below gives an overview of how the location hierarchy is handled,
created, etc.

### Step 1: Populate the spreadsheet

The location hierarchy google doc
(<https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765>)
is populated manually by copy-pasting the different docs sent from
sites.

### Step 2: Process the spreadsheet

The code in `bohemia/rpackage/bohemia/data-raw/create_data_files.R`
contains a few lines for processing the names (capitalizing uniformly,
updating Mopeia localities, etc.). Look for the function
`update_mopeia_locality_names`. Run those lines, and then copy-paste the
resultant csv back to google sheets.

### Step 3: Generate the format for choices for ODK

The function defined in
`bohemia/rpackage/bohemia/odk_create_location_choices.R` formats
correctly for the ODK choices page. Run it. And write the two elements
of the list output to local csvs (for later copy-pasting into the
relevant
    spreadsheets).

    out <- odk_create_location_choices(country = NULL, add_other = TRUE, add_ids = FALSE, add_codes = TRUE, other_word = 'Other', other_only_levels = c("Village", "Hamlet"))
    readr::write_csv(out$survey, '~/Desktop/survey.csv')
    readr::write_csv(out$choices, '~/Desktop/choices.csv')

### Step 4: Copy-paste into spreadsheets

  - Any ODK form which uses the hierarchy should get it copy-pasted:
      - Census:
        <https://docs.google.com/spreadsheets/d/16_drw-35haLaBlB6tn92mr6zbIuYorAUDyieGONyGTM/edit#gid=286602728>
      - Recon:
        <https://docs.google.com/spreadsheets/d/1xe8WrTGAUsf57InDQPIQPfnKXc7FwjpHy1aZKiA-SLw/edit#gid=0>
  - The shiny apps may also need to be updated, as well as documentation

## Handling of IDS

The census portion of the Bohemia research project requires that each
household and household member be identified and identifiable over time.
This means assigning a unique ID to each household and member at the
time of the census.

The below gives an overview of the Bohemia project’s approach to
handling IDs and location data.

### Nomenclature

#### Household ID nomenclature

The Bohemia household ID is a six-character alphanumeric code consisting
of (i) a three-character code indicating the hamlet/bairro followed by
(ii) a 3 number code. ~~In the case of Tanzania,~~ The initial
three-character code is made up of letters (for example, “ABC”). ~~in
the case of Mozambique, the initial three-character code is made up of
numbers (for example, “123”).~~ For example, for a house in the
imaginary village of “Asante”, its code might be `ASA536` whereby `ASA`
indicates that the house is located in the hamlet/bairro of Asante, and
536 is the sequential number assigned to that house at the time of
enumeration.

##### A note on the 3-character bairro/hamlet code

For areas using the letter naming system, the three-character location
code which forms the first half of the location ID will be similar in
name to the location which it represents (ie, `ASA` for Asante). That
said, there are cases in which multiple locations beginning with the
same 3 letters (for example, “Asante” and “Asambogo”). For this reason,
the 3-letter codes are generated *a priori* and are built into the
Bohemia Census form (as well as available via web application). When
assigning IDs, fieldworkers should use DataBrew tools (the census form
or web app) so as to ensure that they are using the correct codes; they
should not create codes *ad hoc*.

##### How to get codes

There are three ways to get the “official” location ID for a given
hamlet.

1.  Location IDs are viewable [in this
    spreadsheet](https://docs.google.com/spreadsheets/d/1hQWeHHmDMfojs5gjnCnPqhBhiOeqKWG32xzLQgj5iBY/edit#gid=1134589765).
2.  They are also retrievable using the DataBrew Bohemia R package
    function `get_location_code()`, or in the `locations` object in the
    same package
3.  Finally, one can view location IDs in the operation helper app at
    <http://bohemia.team/operations/> and clicking “Location codes” in
    the left sidebar menu:

![](../misc/img/locations.png)

#### Person ID nomenclature

The person ID is a simple extension of the household ID at which the
person was first censed. It consists of (i) the 6-character household ID
followed by (ii) a 3 digit ID-specific to that person. For example, the
head of household at the aforementioned house (`ASA-536`) might have an
ID like `ASA-536-001`. This person’s ID is “permanent” in the sense that
(s)he would retain that ID number even in the case of (a) moving to a
new house, (b) dying, (c) remaining in the house but being replaced as
head of household, (d) emigrating, or (e) being lost to follow-up. In
other words, the 9-character person ID is issued only once, to only one
person, and that person is never issued more than one ID.

The assignation of person IDs within a household is sequential (ie,
starting with 01 and going upwards) (the only exception being
non-resident household members - see next section).

##### A note on non-residents

Non-resident household members should be assigned an ID beginning at
number 901 and increasing thereafter sequentially.

### How to assign individual IDs

  - Individual IDs are assigned at the moment of data entry in the
    census form. A default ID is automatically generated as a function
    of the sequence of data collection. The default ID schema is `001`
    for the head of household `002` (and sequentially increasing) for
    the household head substitute, and `003` (or more, in the case of
    multiple household head substitutes) and upwards for the other
    household members.
  - However, there are edge cases in which the default should not be
    used.
      - Edge case A: Non-resident household members’ automatic ID
        generation should be overridden so as to begin their number with
        “9”, ie `901`.
      - Edge case B: An option exists to “override” automatic
        assignation (ie, assign number “5” to someone who was
        automatically going to receive number “1”). This is only
        applicable to cases of (a) interrupted visits requiring a device
        shut-down/exit or (b) a return/follow-up visit.
      - Edge case C: A “retrieval” option will be implemented for
        getting a list of the names and IDs of the members of a
        household who have already been enrolled in the census. Since
        houses are generally censed in one-go (ie, not requiring return
        visits), and since internet connectivity is intermittent in some
        areas, this should only be useful in exceptional circumstances.

### How to assign household IDs

There are two methods for household “enumeration” (ie, the assignation
of IDs to households). Mozambique will use the “a priori” method, and
Tanzania will use the “on the fly” method.

#### Method 1: A priori

The “a priori” method means assigning a number to every household in a
hamlet/village *prior* to collecting data from any of those households.
The advantage of this method is that it decreases the likelihood of
duplication and saves the data collectors time. It also allows for a
more systematic/organized approach to enumerating. The disadvantage is
that it requires two household visits.

#### Method 2: On the fly

The “on the fly” method means assigning a number to each household at
the same time as the census data collection visit. The advantage of this
method is that it does not require two separate visits to a household.
The disadvantage is the possibility of ID duplications - that is,
because houses are being assigned IDs in the same village
simultaneously, there is a risk that two houses will get the same ID
number.

In order to eliminate the risk of duplicates, the “on the fly” method
uses the same enumeration list approach as the “a priori” method. The
main difference is that the “on the fly” approach has many different
people/teams simultaneously enumerating (whereas the “a priori” approach
generally has only one enumeration team in a hamlet at any given time).
Because in the “on the fly” method there are many simultaneous
enumerators, it is important that pre-printed, unique enumeration lists
be used.

### Verification

  - It is of vital importance that:
      - household numbers be unique
      - household numbers be correct (ie, coded for their corresponding
        hamlets)
      - household numbers be unique
  - Because many areas do not have internet connectivity, and because
    census fieldworkers may be carrying out data offline data
    collections simultaneously, there is no reliable, automated way to
    verify data entries in real time.
  - However, on the server-side, an automated script is set up to detect
    ID abnormalities as soon as they are entered (ie, as soon as a
    fieldworker synchronizes). When an abnormality (duplicate, skipped
    ID, miscoded hamlet, etc.) occurs, the abnormality is logged and an
    “event” is triggered in the data manager web application requiring
    correction or confirmation.

# Analysis for study objectives

## Clustering

### Overview of approach

The data generated from the demographic/census phase of the Bohemia
project will, unto themselves, be of analytical value. Descriptive
analysis will be carried out by study researchers. Data for analysis
will be accessible to study researchers via the “Download data” portal
in the dashboard, and Databrew will provide technical and statistical
support to those who request it. That said, the *priniciple analytical
contribution* of the demographic/census phase of the study to the
Bohemia project’s research objectives is not the descriptive analysis of
the population, but rather the formation of clusters for later random
assignation to treatment groups for the Bohemia clinical trial
component. What follows is a description of the cluster creation and
randomization process.

The project requires knowing how many clusters can be formed given the
spatial distribution of hamlets and certain “parameters” (buffer
distance, minimum number of children per cluster, minimum number and
type of animals, etc.). We can approximate this number by taking
advantage of the data collected during Bohemia “Reconnaissance”
activities (ie, hamlet-level questionnaires during the period of May-Aug
2020). However, these data depend on human estimates from village heads,
rather than direct interviews. Accordingly, final clustering will not be
carried out until late 2020, after the minicensus is finished.

### Clustering parameters

A cluster can be considered to be “complete” if it has the following
characteristics: - At least 30 children - At least 2 kilometers between
clusters of different treatment assignments (ie, a 1km “buffer” for each
cluster, except in the case that the nearby cluster is of identical
treatment assignment)

We consider that the number of clusters is “enough” if 144 are reached
(ie, sufficient for the random assignment of all clusters to 3
assignment groups of n=48).

We allow for clusters to be formed by more than one hamlet, but we do
not allow for the splitting of hamlets.

The clustering algorithm: - Starts at the hamlet of the district
headquarters - Assess whether the hamlet is a complete cluster, then -
If it is a complete cluster, it moves on to the next hamlet and starts a
new cluster - If it is not a complete cluster, it adds the nearest
hamlet to the same cluster (and so on) - Uses pre-assigned (but random)
treatment groups, so as to allow for the assignation of buffers only
when necessary - Assumes a perfectly circular hamlet shape and a radius
based on population (since true distribution of households is not
available). The assumed radius is 1 meter per person (except for hamlets
with \> 1,000 people, which are assumed to have a radius of 1,000
meters) - Assumes that 30% of people are children - Assumes an average
of 6 people per household - Assumes the following number of animals
(quantification from categorical variables): - “1 to 5”: 3 - “6 to 19”:
12 - “20 or more”: 30

### Code and documentation

The clustering algorithm is a utility built into the Bohemia R package
(see next section). It relies on a number of other custom-made
utilities, such as the functions for the generation of hamlet
boundaries, the generation of buffers, tesselation, and collapsation
based on assignment status. What follows is a brief overview of the
process with code snippets for examples.

The first step in clustering is geocoding: taking a population’s
geographic distribution (see below for an example of a hypothetical
district’s population distribution, wherein each color represents a
different hamlet).

``` r
set.seed(1)
library(tidyverse)
library(sp)
library(bohemia)
 # Generate some fake data
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 10,
                                sd = 0.04)
 # Plot the fake data
plot(fake$x, fake$y, col = rainbow(10)[fake$cluster])
```

![](figures_data_management/unnamed-chunk-3-1.png)<!-- -->

#### Generating village boundaries

Hamlet/village boundaries are not always clearly defined. Accordingly,
we generate them retrospectively based on the actual distribution of
households in the geographic area in question:

``` r
 # Generate boundaries from the point locations
boundaries <- bohemia::create_borders(df = fake)
 # Plot the boundaries
cols10 <- rainbow(10)
cols <- cols10[fake$cluster]
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols10, alpha.f = 0.3),
     border = NA)
```

![](figures_data_management/unnamed-chunk-4-1.png)<!-- -->

#### Generating external buffers

Once borders are defined, buffers can be formed. The below shows each
hamlet’s population (points), borders (filled polygons) and buffers
(empty polygons):

``` r
 # Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = 5000)
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
plot(buffers, add = T)
```

![](figures_data_management/unnamed-chunk-5-1.png)<!-- -->

#### Generating buffers based on tesselation

As an alternative to the above approach, and so as to generate
generealizable boundaries with no “holes”, we can use voronoi
tesselation as opposed to convex hulling.

``` r
boundaries <- create_borders(df = fake, voronoi = TRUE)
 # Plot the boundaries
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
```

![](figures_data_management/unnamed-chunk-6-1.png)<!-- -->

#### Generating tesselated buffers

Just like with convex hull generated borders, we can add buffers to
delauney triangles so as to create buffers between collapsed polygons.

``` r
 # Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = 5000)
plot(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3), border = NA)
plot(buffers, add = T, col = adjustcolor(cols10, alpha.f = 0.3))
```

![](figures_data_management/unnamed-chunk-7-1.png)<!-- -->

#### Generating tesselated internal buffers

In the above, we use *external* boundaries, which results in one areas
borders bleeding into the core of another area. As an alternative to
this, we can use *internal* boundaries.

``` r
 # Generate buffers from boundaries
buffers <- bohemia::create_buffers(shp = boundaries,
                                   meters = -5000)
plot(fake$x, fake$y, col = 'white', pch = 16, cex = 0.5)
 # plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.3))
plot(buffers, add = T, col = adjustcolor(cols10, alpha.f = 0.4))
points(fake$x, fake$y, col = cols, pch = 16, cex = 0.5)
```

![](figures_data_management/unnamed-chunk-8-1.png)<!-- -->

#### Generating “collapsed” tesselated internal buffers

For the purposes of an intervention in which each area is assigned
status A or B (ie, intervention or control), the need for buffers
between areas of identical intervention status is redundant (and can
unecessarily eliminate potential study participants). The below is an
example of redundant buffers.

``` r
 # Define some ids 
ids <- sample(1:2, nrow(boundaries), replace = TRUE)
cols2 <- c('lightblue', 'orange')
cols <- cols2[ids]

 # Create a dataframe for joining clusters to ids
merger <- data.frame(cluster = boundaries@data$cluster,
                     id = ids)
 # Bring the ids into the point data
old_fake <- fake
fake <- left_join(fake, merger, by = 'cluster')

 # Generate buffers from boundaries
buffers@data <- left_join(buffers@data, merger, by = 'cluster')
plot(fake$x, fake$y, col = cols2[fake$id], pch = 16, cex = 0.5)
 # plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.8))
plot(buffers, add = T, col = adjustcolor(cols2[buffers@data$id], alpha.f = 0.5))
points(fake$x, fake$y, col = cols2[fake$id], pch = 16, cex = 0.5)
```

![](figures_data_management/unnamed-chunk-9-1.png)<!-- -->

The below collapses redundant borders.

``` r
 # Define some ids 
ids <- sample(1:2, nrow(boundaries), replace = TRUE)
cols2 <- c('lightblue', 'orange')
cols <- cols2[ids]

 # Create a dataframe for joining clusters to ids
merger <- data.frame(cluster = boundaries@data$cluster,
                     id = ids)
 # Bring the ids into the point data
fake <- old_fake
fake <- left_join(fake, merger, by = 'cluster')

 # Generate buffers from boundaries
buffers <- create_buffers(shp = boundaries,
                                   meters = -5000,
                                   ids = ids)
plot(fake$x, fake$y, col = 'white', pch = 16, cex = 0.5)
 # plot(boundaries, add = T, col = adjustcolor(cols, alpha.f = 0.8))
plot(buffers, add = T, col = adjustcolor(cols2[buffers@data$id], alpha.f = 0.5))
points(fake$x, fake$y, col = cols2[fake$id], pch = 16, cex = 0.5)
```

![](figures_data_management/unnamed-chunk-10-1.png)<!-- -->

#### Generating village-agnostic clusters

Clusters can be defined *a priori* (ie, named administrative units) or
programatically (ie, village-agnostic groups of `n` people). The Bohemia
project has a preference for the former. However, in the case that
sample size cannot be obtained, there is an alternative: a cluster could
be formed programatically, but with certain restrictions (such as the a
rule prohibiting the division of a village into two). To do this, use
the `create_clusters` function.

``` r
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 10,
                                sd = 0.1) %>% dplyr::select(-cluster)
plot(fake$x, fake$y, pch = 16)
cs <- create_clusters(cluster_size = 100,
                      locations = fake)

rcols <- length(unique(cs$cluster))
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
```

The data generated from `create_clusters` is compatible with the other
functions herein described. Here are some usage examples:

``` r
set.seed(2)
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 5,
                                sd = 0.1) %>% dplyr::select(-cluster)
cs <- create_clusters(cluster_size = 100,
                      locations = fake)
rcols <- length(unique(cs$cluster))

 # Create true borders
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
boundaries <- create_borders(df = cs)
plot(boundaries, add = T)
```

![](figures_data_management/unnamed-chunk-12-1.png)<!-- -->

``` r

 # Create tesselation borders
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
boundaries <- create_borders(df = cs, voronoi = TRUE)
plot(boundaries, add = TRUE)
```

![](figures_data_management/unnamed-chunk-12-2.png)<!-- -->

``` r

 # Create internal buffered tesselation borders
plot(cs$x, cs$y, col = rainbow(rcols)[cs$cluster])
boundaries <- create_borders(df = cs, voronoi = TRUE)
buffered <- create_buffers(shp = boundaries, meters = -3000)
plot(buffered, add = TRUE)
```

![](figures_data_management/unnamed-chunk-12-3.png)<!-- -->

``` r

 # Create internal buffered tesselation borders with binary treatment status
id_df <- cs %>% 
  group_by(cluster) %>%
  tally 
id_df$id <- sample(1:2, nrow(id_df), replace = TRUE)
cs <- left_join(cs, id_df)
cols2 <- c('darkblue', 'pink')
plot(cs$x, cs$y, col = cols2[cs$id])
boundaries <- create_borders(df = cs, voronoi = TRUE)
buffered <- create_buffers(shp = boundaries, meters = -3000,
                           ids = id_df$id)
plot(buffered, add = TRUE)
```

![](figures_data_management/unnamed-chunk-12-4.png)<!-- -->

What follows below is a visualization of how the `create_buffers`
algorithm works.

``` r
set.seed(2)
fake <- generate_fake_locations(n = 1000,
                                n_clusters = 5,
                                sd = 0.1) %>% dplyr::select(-cluster)
cs <- create_clusters(cluster_size = 100,
                      locations = fake,
                      plot_map = TRUE,
                      save = 'animation')
setwd('animation')
system('convert -delay 100 -loop 0 *.png result.gif')
setwd('..')
```

![](animation/result.gif)

# Analysis for quality control and operational optimization

## GPS tracking

  - During the census phase of the Bohemia project, the location of data
    capture devices (tablets) will be tracked. The purpose of this
    tracking is to both:
  - Help with recovery in the case of device loss or theft
  - Enable, over time, the identification of travel routes through the
    aggregation of the GPS tracks/paths taken by each tablet, and the
    subsequent generation of travel route planning tools and maps
  - This guide details the technical set-up of the device tracking
    system

### Services used

  - Device-side: Devices will use Traccar Client, and Android
    application downloadable via the [Google Play
    Store](https://play.google.com/store/apps/details?id=org.traccar.client).
  - Server-side: The server will run Traccar Server, downloadable from
    Traccar’s
    [website](https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip)

### Steps

#### On tablets

##### Installation

  - Install Traccar client via the [Google Play
    Store](https://play.google.com/store/apps/details?id=org.traccar.client)

##### Configuration

  - On the android device, make sure location (in settings \> privacy)
    is enabled, AND that the locating method is as high as possible (GPS
    and Wi-Fi)
  - Open the Traccar app
  - Set the address of the server URL: `http://bohemia.fun`
  - Set the Frequency field to: `60`
  - Set location accuracy to: `high`
  - Do not change the Distance or Angles fields
  - At the top set “Service status” to on/running

##### Use

  - The Traccar app should be running (“Service status” set to on) at
    all times during operations
  - The app will automatically initialize upon device reboot
  - If for some reason the app is turned off, workers should turn it
    back on
  - We have tested the app on many devices. At the 60 second recording
    interval, it has only minimal effect on battery life.
  - When the device is offline, GPS coordinates are stored locally; when
    an internet connection is found, GPS coordinates are sent to the
    server.

### On server

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

  - So that your AWS instance’s public IP address does not change at
    reboot, etc., you need to create an “Elastic IP address”. To do
    this:
  - Go to the EC2 dashboard in aws
  - Click “Elastic IPs” under “Network & Security” in the left-most menu
  - Click “Allocate new address”
  - Select “Amazon pool”
  - Click “Allocate”
  - In the allocation menu, click “Associate address”
  - Select the instance you just created. Also select the corresponding
    “Private IP”
  - Click “Associate”
  - Note, this guide is written with the below elastic id. You’ll need
    to replace this with your own when necessary.

<!-- end list -->

    3.21.67.128

  - Go to instances menu
  - Name the newly spun-up server “traccar”

#### Connect to the server

  - In the “Instances” menu, click on “Connect” in the upper left
  - This will give instructions for connecting via an SSH client
  - It will be something very similar to the
    following:

<!-- end list -->

    ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-3-21-67-128.us-east-2.compute.amazonaws.com

  - Create an
    alias

<!-- end list -->

    alias traccar='ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@bohemia.fun'

  - Add the above line to ~/.bashrc to persist

#### Setting up the domain

  - In domains.google.com, click on the purchased domain.
  - Click on “DNS” on the left
  - Go to “Custom resource records”
  - You’re going to create two records:

<!-- end list -->

1.  Name: @; Type: A; TTL 1h; Data: 3.21.67.128
2.  Name: www; Type: CNAME; TTL: 1h; Data:
    ec2-3-21-67-128.us-east-2.compute.amazonaws.com.

#### Setting up Linux

  - SSH into the
    server:

<!-- end list -->

    ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-3-21-67-128.us-east-2.compute.amazonaws.com

  - Install some software:

<!-- end list -->

    sudo apt-get update
    sudo apt-get install openjdk-8-jdk-headless
    sudo apt-get install zip
    sudo apt-get install unzip
    sudo apt-get install wget
    sudo apt-get install curl
    sudo apt-get -y update
    sudo apt-get install nginx
    sudo apt-get install software-properties-common
    sudo apt install mysql-server

#### Setting up java

  - Java is already installed, but you need to set the `JAVA_HOME`
    environment variable. To do so:
  - `sudo nano /etc/environment`
  - Add line like `JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"`
  - Run `source /etc/environment`

#### Installing Traccar

  - Install the zip file
    [here](https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip)
    by running:

<!-- end list -->

    mkdir traccar
    cd traccar
    wget https://github.com/traccar/traccar/releases/download/v4.8/traccar-linux-64-4.8.zip

  - Extract the contents:

<!-- end list -->

    unzip traccar-linux-64-4.8.zip

  - Run the executable:

<!-- end list -->

    sudo ./traccar.run

  - Start the service:

<!-- end list -->

    sudo systemctl start traccar.service

  - Open web interface by navigating to <http://localhost:8082/> (on
    local machine) or bohemia.fun (if you have already configured the
    below) or bohemia.fun:8082
  - Log in as `admin` / `admin`

#### Deal with ports, nginx, etc.

  - Run the
    below:

<!-- end list -->

    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/bohemia.fun
    sudo nano /etc/nginx/sites-available/bohemia.fun

  - Make it as follows:

<!-- end list -->

    server_name bohemia.fun;
    
    location / {
    proxy_pass http://127.0.0.1:8082;
    }

  - Make a symlink as per
    below:

<!-- end list -->

    sudo ln -s /etc/nginx/sites-available/bohemia.fun /etc/nginx/sites-enabled/

  - Edit a file: `sudo nano /etc/nginx/nginx.conf` and remove the `#`
    before `server_names_hash_bucket_size 64;`
  - Remove the default nginx file: `sudo rm
    /etc/nginx/sites-enabled/default`
  - Check to make sure there are no syntax errors:

<!-- end list -->

    sudo nginx -t

  - Restart:

<!-- end list -->

    sudo systemctl restart nginx
    sudo nginx -s reload
    sudo systemctl start traccar.service

#### Add users/devices

  - For each user/tablet, do the following:
  - Click the “plus” icon in the upper left of the web interface
  - Add the name and worker ID for each user

#### Set up mysql database

    sudo mysql
    CREATE USER 'traccaruser'@'localhost' IDENTIFIED BY 'xxx';
    GRANT ALL PRIVILEGES ON * . * TO 'traccaruser'@'localhost';
    FLUSH PRIVILEGES;
    ctrl + d
    mysql -u traccaruser -p
    <enter password>
    CREATE DATABASE traccardb;

#### Configure Traccar for MySQL

  - Edit the [configuration
    file](https://www.traccar.org/configuration-file/) by running:

<!-- end list -->

    sudo nano /opt/traccar/conf/traccar.xml

Replace the below lines:

    <entry key='database.driver'>org.h2.Driver</entry>
    <entry key='database.url'>jdbc:h2:/home/user/Documents/traccar/target/database</entry>
    <entry key='database.user'>sa</entry>
    <entry key='database.password'></entry>

With:

    <entry key='database.driver'>com.mysql.jdbc.Driver</entry>
    <entry key='database.url'>jdbc:mysql://3.21.67.128:3306/traccardb?serverTimezone=UTC&amp;useSSL=false&amp;allowMultiQueries=true&amp;autoReconnect=true&amp;useUnicode=yes&amp;characterEncoding=UTF-8&amp;sessionVariables=sql_mode=''</entry>
    <entry key='database.user'>traccaruser</entry>
    <entry key='database.password'>xxx</entry>

  - Note in the above that the `3.21.67.128` is the server IP.

  - Also, add some filtering to ensure that we don’t capture too much
    jumpiness:

<!-- end list -->

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

#### Optimize MySQL

    sudo nano /etc/mysql/mysql.conf.d/custom.cnf

  - Add the following lines (adjusting the first line so that it is less
    than 75% of total memory)

<!-- end list -->

    [mysqld]
    innodb_buffer_pool_size = 2G
    innodb_log_file_size = 512M
    innodb_flush_method = O_DIRECT
    innodb_flush_log_at_trx_commit = 0

  - Restart:

<!-- end list -->

    sudo systemctl stop traccar
    sudo systemctl restart mysql
    sudo systemctl start traccar

  - To set an explicit number of days before deleting, add the following
    (for 60 days, for example):

<!-- end list -->

    <entry key='database.positionsHistoryDays'>60</entry>

Restart

    sudo systemctl daemon-reload
    sudo systemctl start traccar.service

Allow for remote access to database

    sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

  - Comment out this line

<!-- end list -->

    bind-address            = 127.0.0.1

  - Restart mysql:

<!-- end list -->

    sudo systemctl restart mysql

  - Create remote user and grant privileges

<!-- end list -->

    sudo mysql
    CREATE USER 'traccarremoteuser'@'%' IDENTIFIED BY 'xxx';
    CREATE USER 'traccaruser'@'%' IDENTIFIED BY 'xxx';
    FLUSH PRIVILEGES;
    GRANT ALL PRIVILEGES ON traccardb.* TO 'traccarremoteuser'@'%';
    GRANT ALL PRIVILEGES ON traccardb.* TO 'traccaruser'@'%';
    FLUSH PRIVILEGES;
    <ctrl +d>

  - Restart stuff:

<!-- end list -->

    sudo systemctl stop traccar
    sudo systemctl restart mysql
    sudo systemctl start traccar

  - Test the remote connection (from another box):

<!-- end list -->

    mysql -h 3.21.67.128 -u traccarremoteuser -p
    <traccarremotepass>

#### Data extraction

  - The [API](https://www.traccar.org/api-reference/) should be used for
    data extraction

  - Get a list of devices:

<!-- end list -->

    http://bohemia.fun/api/devices

etc.

  - The database can be accessed directly:

<!-- end list -->

    mysql traccardb -u traccaruser -p
    <xxx>
    show tables;
    select * from tc_positions;

#### Troubleshooting and logs

  - See logs at `/opt/traccar/logs/tracker-server.log`
  - See more details on the [troubleshooting
    page](https://www.traccar.org/troubleshooting/)

## Web app

Quality control and operational analysis will be carried out
automatically via the web app hosted at <https://bohemia.team/app>. This
app is accessible to authorized study members. Because its content is
dynamic and sponsor-driven, it is not documented in full detail here.
However, the purpose of this web app is to analyze, in real-time,
operational and content-area outcomes *as data is being collected* so as
to inform the study’s management practices.

The web app consists of two main types of data: (1) operational (ie,
data pertaining to what the data collection teams are doing) and (2)
scientific (ie, content-related data collected by the data collection
teams). It also consists of a number of utilities for downloading data,
generating operational helper sheets, etc.

<div>

<img src="img/dashboard/Selection_027.png" alt="" width="250" />
<img src="img/dashboard/Selection_028.png" alt="" width="200" />
<img src="img/dashboard/Selection_029.png" alt="" width="200" />
<img src="img/dashboard/Selection_030.png" alt="" width="160" />

</div>

The above screenshots are from the app as of 2020-10-26. From left to
right, they are (i) landing page, (ii) an example of operational
information as per sponsor request, (iii) a visualization of operational
information, (iv) utilities for generating operational helper sheets.

Just as the app exposes data pertaining to operations, incoming data
pertaining to questions of scientific importance can also be displayed.
A placeholder section is programmed for this content. Additionally,
variables and hypotheses of scientific interest have been elicited from
the Bohemia scientific team in order to prepare the work on this
section. These are as below:

    -Animal ownership/numbers/species and having had malaria
    -Does IVM show up in well, water hole, or surface water (river or lake) due to
    its mass administration?
    -Define the profile of people sleeping under mosquito nets (gender, age,
    education, livestock presence, ...)
    -Look for associations between IPTp intake and 1) age of the mother 2) gravidity
    (better than parity) 3) malaria risk perception (e.g.; sleep under ITN) of the
    mother, the hh head and the husband 4) hh wealth index 5) socioeconomic status
    of the mother 6) marital status of the mother 7) gender of household head 8)
    care seeking behavior (e.g.; frequency, provider type)
    -Determinants of usage of mosquito nets (my Master Final Project)
    -Use of ivermectine in animals vs animal´s contribution to the household´s
    income
    -Effect of livestock proximity on malaria incidence (controlling for ownership,
    which has too much socioeconomic bias). That is, among non.owners of livestock,
    does living near livestock increase or decrease your risk of malaria?
    -Look at associations between school.aged children and malaria: sleeping under
    bednets, receive treatment etc (since they do not receive that much attention
    as <5 and women)
    -Is there any association between the proximity to water body and 1) malaria
    control measures (in this check the different measures independently and
    collectively: IRS, bednets and others. In this case also consider house screens
    as part malaria control measures) 2) malaria disease
    -associations of household structure (family size, presence of both parents,
    marital status,..) with care.seeking behaviour and socioeconomic status
    -Animal ownership and snake bite
    -If IVM showing up in drinking water, how would common household water
    treatments affect the transformation of IVM?
    -In subjects who suffered from fever, is education related to the time taken
    before seeking formal care?
    -Look for relationships between frequent travel or movements and malaria or
    other diseases
    -Higher distance between cattle and human sleeping areas decrease significantly
    prevalence of zoonosis. /// Does livestock housing type play a significant role
    in the prevalence of zoonoses?
    -level of education and delivery attendance by a health professional
    -Bednet "spillover" (ie, positive externalities): how does nearby bednet usage
    protect neighbors (the theory being that insecticide from nearby bednets kills
    mosquitoes which would otherwise bite neighbors)
    -Look for associations between children that have been in the hospital and
    post.discharge mortality (maybe from one visit to another, or when doing the VA
    there is a question on helath care received before dying)
    -Does the timing of human behaviour that could contribute to outdoor malaria
    transmission match the timing of the vector behaviour? This will combine the
    information from the census on time spend indoors and outdoors after sunset
    without protection i.e. before going to sleep to the entomological data on
    mosquitoes collected indoors and outdoors at different hours. The general idea
    is to see if the timing of the activity of the mosquitoes (assessed by the
    number of host seeking mosquitoes collected per hour) matches the timing of the
    activity of the humans (assessed by the period which humans are awake).
    -Are people whose neighbours use bednets more often infected than people whose
    neighbours do not? (similar to repellants) That is also, do mosquitoes not only
    avoid resting on bednets but avoid bednet houses entirely?
    -Snake bite and socio.economic status/gender/ocupation
    -Do we see higher levels of IVM in the water sources that are closer to septic
    tanks or latrines than in those that are farther away?
    -Is the number of members in the household related to the presence of bed bugs?
    -See if there are any associations between gender of household head with other
    things (e.g. health seeking behavior, malaria, etc.)
    -Which are the rates of ceasarian section and which are its determinants?
    -Amount of work months associated to use of malaria prevention tool
    -Socioeconomic factors affecting childhood mortality
    -Does the blood feeding behaviour of the mosquitoes reflect the animal
    ownership?  This will be done by combining the entomological data on source of
    blood meal for the mosquitoes with the census data on animal ownership. In the
    case animal ownership does not mirror the mosquito source of blood meal can
    this be explained by where the animal sleeps by looking at what species sleeps
    in the household and how far are those that sleep outside
    -Associations of household religion and choice of provider or other careseeking
    behaviour (for identifying "allies" and targets for health messages)
    -Mapping animal distribution and poverty/morbidity at district level
    -Would there be higher levels of IVM in soil or nearby water of land where
    IVM.administrated cattle are grazing than in those of land without grazing
    IVM.administrated cattle?
    -Look at case management: relationships between reporting fever and taking
    antimalarials, not having a RDT done but taking antimalarials, reporting not
    having malaria but having taken antimalarials.
    -Is there any association between total number of rooms used to sleep and
    malaria disease cases per household?
    -Mapping LLIN ownership/universal coverage/Usage by village and having had
    malaria
    -How does the weather (wet vs. dry), type of water (standing vs. flowing),
    distance of water from IVM input sources (latrine, septic tanks, grazing land),
    size of the livestock, and affect the presence and fate of IVM in the natural
    environment?
    -Is there any association between the type of housing and malaria disease?

The above show the census-related scientific hypotheses elicited thus
far. In conjunction with the sponsor, these will be refined and
prioritized so as to render in-app content related to these hypotheses
in real-time during the collection of data for the main-census.
