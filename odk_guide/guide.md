# Admin guide for setting up the Bohemia project data system

The below guide is a walk-through of setting up the Bohemia data infrastructure. It assumes you are running a cloud server on AWS (which will not be the case for local sites). For local servers, much of the ssh, tunneling, etc. sections can simply be ignored/altered.

## Spin up an EC2 instance on AWS

_The below should only be followed for the case of a remote server on AWS. In production, sites will use local servers, physically housed at the study sites. In the latter case, skip to the [Setting up OpenHDS section](https://github.com/databrew/bohemia/blob/master/guide/guide.md#setting-up-openhds)_


- Log into the AWS console: aws.amazon.com
- In the upper right hand corner select "Sign-into Console"
- Click the “Launch a virtual machine” option under “Build a solution”
- Select "Ubuntu Server 16.04 LTS (HVM), SSD Volume Type"
-To the far right select 64-bit (x86)  
- Click “select”  
- Choose the instance type: General purpose, t2.large, 2 vCPUs, 8 gb memory, etc.
- Click “Review and launch”
- Click “Edit security groups”
- Ensure that there is an SSH type rule with source set to `0.0.0.0/0` to allow any address to SSH in. Set "Source" to "Anywhere"
- Create a second rule with "Type" set to "All traffic", the "Port Range" set to 0-65535. Set "Source" to "Anywhere"
- Create a third rule with "Type" set to "HTTP" and "Port Range" set to 80. Set "Source" to "Anywhere"
- Create a fourth rule with "Type" set to "HTTPS", Port Range set to 443. Set "Source" to "Anywhere"
- Create a fifth rule with Type "Custom TCP Rule", Port Range 8080. Set "Source" to "Anywhere"
- Your security configuration will look like this
![](img/security.png)
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

### Allocate a persistent IP

- So that your AWS instance's public IP address does not change at reboot, etc., you need to create an "Elastic IP address". To do this:
  - Go to the EC2 dashboard in aws
  - Click "Elastic IPs" under "Network & Security" in the left-most menu
  - Click "Allocate new address"
  - Select "Amazon pool"
  - Click "Allocate"
  - In the allocation menu, click "Associate address"
  - Select the instance you just created
  - Click "Associate"
- Note, this guide is written with the below elastic id. You'll need to replace this with your own when necessary.

```
3.130.255.155
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
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-3-130-255-155.us-east-2.compute.amazonaws.com
```

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


### Setting up Linux  

- This guide was written for, and assumes, Linux Ubuntu 16.04. Details below:
```
Linux ip-172-31-5-87 4.4.0-1087-aws #98-Ubuntu SMP Wed Jun 26 05:50:53 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

- SSH into the server:
```
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@ec2-3-130-255-155.us-east-2.compute.amazonaws.com
```
- Run the following after ssh'ing into the server: `sudo apt-get update; sudo apt-get dist-upgrade`

administrator
papU

cloudfare - CDN - already has certificate - can use for https


sudo certbot run --nginx --non-interactive --agree-tos -m joebrew@gmail.com --redirect -d papu.us

Edit `etc/letsencrypt/options-ssl-nginx.conf` and add a line with `server_name:papu.us;``
sudo nginx
sudo service nginx restart

To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option.

   Your account credentials have been saved in your Certbot
      configuration directory at /etc/letsencrypt.


- Clone ODK central: `git clone https://github.com/opendatakit/central`
- `cd central`
- `git submodule update -i`
- Edit `.env`
  - Change `SSL_TYPE=letsencrypt`
  - Change `DOMAIN=3.130.255.155`
  - Change `SYSADMIN_EMAIL=joebrew@gmail.com`

- Install docker:
```
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo docker-compose build

sudo docker-compose up --no-start
```
- At this point, ODK Central is installed

## Starting up ODK Central

- Make sure ODK runs as a service:
```
sudo cp files/docker-compose@.service /etc/systemd/system
sudo systemctl start docker-compose@central
```
- Check to see if Docker itself is running: `systemctl status docker-cmopose@central`
