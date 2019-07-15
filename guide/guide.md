# Admin guide for setting up the Bohemia project data system (OpenHDS+)

## Spin up an EC2 instance on AWS

_The below should only be followed for the case of a remote server on AWS. In production, sites will use local servers, physically housed at the study sites. In the latter case, skip to the [Setting up OpenHDS section](https://github.com/databrew/bohemia/blob/master/guide/guide.md#setting-up-openhds)_


- Log into the AWS console: aws.amazon.com
- Click the “Launch a virtual machine” option under “Build a solution”
- Select “Ubuntu Server 18.04 LTS (HVM)”
-To the far right select 64-bit (x86)  
- Click “select”  
- Choose the default instance type (General purpose, t2.micro, etc.)  
- Click “Review and launch”
- Click “Edit security groups”
- Ensure that there is an SSH tyupe rule with source set to `0.0.0.0/0` to allow any address to SSH in.
- Click “launch” in the bottom right
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
- It will be something very similar to the following: `ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-3-17-72-248.us-east-2.compute.amazonaws.com`
- Congratulations! You are now able to run linux commands on your new ubuntu server

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

## Setting up OpenHDS

### Setting up Ubuntu  

- Install Ubuntu on the server. There are many online guides for doing this. This guide was written using the following version:
```
Description:	Ubuntu 18.04.2 LTS
Release:	18.04
Codename:	bionic
```
- Update the hostname of the machine to be `data-management.local`. You can check the hostname by running `hostnamectl` and examing the `Static hostname` parameter. To update the hostname, run the following:
```
sudo hostnamectl set-hostname data-management.local
```
- Then, open /etc/hosts by running `sudo nano /etc/hosts` and add the following line:
```
127.0.0.1 data-management.local
```
- Then, open the /etc/cloud/cloud.cfg file by running `sudo nano /etc/cloud/cloud.cfg` and change the `preserve_hostname` parameter from `false` to `true`.

### Installing Java 8

- Run the following to install Java 8: `sudo apt-get install openjdk-8-jre-headless`
- This guide was written with the following version (produced running `java -version`):

```
openjdk version "1.8.0_212"
OpenJDK Runtime Environment (build 1.8.0_212-8u212-b03-0ubuntu1.18.04.1-b03)
OpenJDK 64-Bit Server VM (build 25.212-b03, mixed mode)
```

### Installing MySQL Server

- Run the following to install MySQL Server: `sudo apt-get install mysql-server`  
- If prompted, set the password of the root user during installation to `data`

#### Setting up MySQL Server

- Log-in: `sudo mysql -uroot -pdata` (this opens the MySQL command line interface using the `root` user and `data` password)
- The following should now appear (indicating that you are succesfully in the MySQL CLI): `mysql>`
- Create a user: `CREATE USER 'data'@'%' IDENTIFIED BY 'data';` (this will throw an error if run more than once)
- Create databases:
```
CREATE DATABASE IF NOT EXISTS 'openhds';
CREATE DATABASE IF NOT EXISTS 'odk_prod';
```
- Grant access privileges to user:
`GRANT ALL ON *.* TO 'data'@'%';`
- Flush privileges: `flush privileges;`
- Grant outside access to MySQL (optional): Comment out the line starting with `Bind-Address` by adding a `#` prior to it in `/etc/mysql/my.cnf`, and then restart MySQL-service by running: `sudo service mysql restart`

### Installing Tomcat 8

- Run the following `sudo apt install tomcat8`
- Run a package update: `sudo apt-get update`
- Ensure tomcat is up and running: `sudo service tomcat8 start`
- Set `JAVA_HOME` variable in `/etc/environment`: `sudo nano /etc/environment` and add line like `JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"`
- Run `source /etc/environment`
- If issues with `JAVA_HOME`, uncomment the `JAVA_HOME` line in `/etc/default/tomcat8/` and set it to the java installation folder. For example:
```
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
```
- Install tomcat8 admin: `sudo apt-get install tomcat8-admin`
- Edit `etc/tomcat8/tomcat-users.xml` by running `sudo nano /etc/tomcat8/tomcat-users.xml`
- In the `tomcat-users` section, create a new role by adding the following lines:
```
<role rolename="manager-gui" />
<user username="data" password="data" roles="manager-gui" />
```
- Restart the tomcat service: `sudo service tomcat8 restart`
- Increase memory allocation to Tomcat: `sudo nano /etc/default/tomcat8` and replace  the line starting with `JAVA_OPTS=` with the following (DO NOT RUN THIS. This is recommended per the OpenHDS guide, but it causes errors with starting the Tomcat service, so for now keeping memory small)
```
JAVA_OPTS="-Djava.awt.headless=true -Xmx1024M -Xms1024M -XX:+UseConcMarkSweepGC"
```
- Ensure that everything is working up until now by ssh-tunneling. Something similar to the below code (with AWS endpoints and `.pem` file location adjusted appropriately):
```
ssh -i /home/joebrew/.ssh/openhdskey.pem -N -L 8999:ec2-3-17-72-248.us-east-2.compute.amazonaws.com:8080 ubuntu@ec2-3-17-72-248.us-east-2.compute.amazonaws.com -v
```

Then, on your local machine, open the following url in a web browser: http://localhost:8999/manage. You can now log-in as Username: `data` and Password: `data`. Once logged-in, the below will appear in the web browswer.

![](img/tomcat.png)


### Installing the MySQL-J Connector


- Install the mysql lib package with `sudo apt-get install libmysql-java` which will put the MySQL connector into `/usr/share/java`
- `cd` to `/usr/share/tomcat8/lib`
- Create a symbolic link:
```
sudo ln -s ../../java/mysql-connector-java-5.1.45.jar mysql-connector-java-5.1.45.jar
sudo ln -s ../../java/mysql.jar mysql.jar
```
- Restart the Tomcat service: `sudo service tomcat8 restart`

### Install SSH-server

```
sudo apt-get install -y openssh-server
```
- Ensure it's up and running `sudo service ssh status`


### Getting and setting up openhds

- On your _local_ machine, run the following to download openhds-server
```
cd /home/ubuntu # change to any directory you prefer
mkdir openhds
cd openhds
wget https://github.com/SwissTPH/openhds-server/releases/download/openhds-1.6/openhds.war
```
- If you need to edit fields, do the below and then re-jar
  - Extract via: `unzip openhds.war`
  - Edit the fields in `WEB-INF/classes/database.properties` to ensure that `dbURL`, `dbUser` and `dbPass` are adequate (only if changed from this guide)
  - Put everything back in the .war file: `rm openhds.war; jar -cvf openhds.war *`

### Deploying OpenHDS in Tomcat
- If running on a remote server (ie, AWS EC2), you'll need to tunnel. For example:
```
ssh -i /home/joebrew/.ssh/openhdskey.pem -N -L 8999:ec2-3-17-72-248.us-east-2.compute.amazonaws.com:8080 ubuntu@ec2-3-17-72-248.us-east-2.compute.amazonaws.com -v
```
- In the (local) web browser, scroll down to the "Select WAR file to upload" section
- Select the `openhds.war` file you downloaded a few minutes ago in the "Choose File" menu.
- Click "Deploy" button (see below image)
![](img/tomcat2.png)
- Click the "start" button on the 'openhds' row of the 'Applications table'. The app is now running.
