# Admin guide for setting up the Bohemia project data system (OpenHDS+)

## Spin up an EC2 instance on AWS

_The below should only be followed for the case of a remote server on AWS. In production, sites will use local servers, physically housed at the study sites._


- Log into the AWS console: aws.amazon.com
- Click the “Launch a virtual machine” option under “Build a solution”
- Select “Ubuntu Server 18.04 LTS (HVM)”
-To the far right select 64-bit (x86)  
-Click “select”  
-Choose the default instance type (General purpose, t2.micro, etc.)  
-Click “Review and launch”
-Click “Edit security groups”
-Ensure that there is an SSH tyupe rule with source set to 0.0.0.0/0 to allow any address to SSH in.
-Click “launch” in the bottom right
-A modal will show up saying “Select an existing key pair or create a new key pair”
-Select “Create a new key pair”
-Name it “openhdskey”
-Download the .pem file into your /home/<username>/.ssh/id_rsa directory
-If that directory does not exist, run the steps in the next section (“Setting up SSH keys”)
-Run the following to change permissions on your key: chmod 400 ~/.ssh/openhdskey.pem
-Click “Launch instances”
-Wait a few minutes for the system to launch (check the "launch log" if you’re impatient)
-Click on the name of the instance (once launched)
-This will bring you to the instances menu, where you can see things (in the “Description” tab below) like public IP address, etc.


### Setting up SSH keys

-If you don’t have an SSH key on your system yet, run the following:
`ssh-keygen -t rsa -b 4096 -C “youremail@host.com”`
-Select defaults (ie, press enter when it asks you the location, password, etc.)
-You will now have a file at /home/<username>/.ssh/id_rsa
-To verify, type: ls ~/.ssh/id_* (this will show your key)
-To change permissions to be slightly safer, run the following: chmod 400 ~/.ssh/id_rsa
