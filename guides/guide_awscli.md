# Guide for awscli and AWS S3

## Installing awscli

```
sudo apt-get update;
sudo apt-get install awscli
```

## Setting up awscli


### Credential file settings

- The AWS CLI stores the credentials that you specify with `aws configure` in a local file named `credentials`, in a folder named `.aws` in your home directory. 
- To generate these access keys create an IAM user account on aws and navigate to IAM console at `https://console.aws.amazon.com/iam/`.
- In the navigation pane, choose `Users`
- Choose the name of the user whose access keys you want to create, and then choose the Security credentials tab.
- In the `Access keys section`, choose `Create access key`.
- To download the key pair, choose Download .csv file. Store the keys in a secure location. You will not have access to the secret access key again after this dialog box closes. Store this file in a safe area.
![](img/credentials.png)

### Configure awscli
- Open a terminal and run `aws configure`. 
![](img/aws_1.png)
- Add in the access key ID and secret access key form the credentials file. 
- then select the default region name and format.
![](img/aws_2.png)

## Managing buckets

### Creating buckets

#### Create a bucket via IAM Console

- Though it is possible to create buckets via the command line (next section), it's recommended to use the IAM console interface for more functionality (namely creating sub folders within a bucket).
- Navigate to the `Services` tab and select `S3`.
![](img/servies.png)
- Click the `Create buckets` button.
![]('img/create_1.png')
- Name the bucket and specify the region. You have an option to import settings from other buckets.
![]('img/create_bucket_2.png')
- Specify settings, if not imported from existing bucket. Nothing to specify for this test.
![]('img/create_bucket_3.png')
- Set permissions (currently uncheck "Block all public access" for this test)
![]('img/create_bucket_.png')
- Then review and select `Create bucket`
![](img/create_bucket_5.png)
- To create a folder within a bucket: 
![](img/aws_3.png)

#### Create a bucket via command line 
- To view all the buckets on your account type:
`aws s3 ls`
- You can either create a bucket on your IAM console or do it directly from the command line by typing 
`aws s3 mb s3://test-bucket-bohemia`
- If a bucket already exists, you can view its contents by typing:
`aws s3 ls s3://test-bucket-bohemia`
- To create a new folder (though it's recommended to do this in the IAM console), you can make use of the cp command: 
`aws s3 cp <file_name> s3://<bucket_name>/<folder_name>/<file_name>` 


### Removing buckets
- To remove a bucket, type: 
`aws s3 rb s3://test-bucket-bohemia`
- If the bucket is not empty, type: 
`aws s3 rb s3://test-bucket-bohemia --force`
- This can also be done from the IAM dashboard by selecting the bucket and deleting it.

### Using buckets
- moving files from local (server) to s3:
`aws s3 cp file.txt s3://test-bucket-bohemia`

- moving files from s3 to local (server)
`aws s3 cp s3://test-bucket-bohemia/file.txt ./`

## Automatically backing up files to s3 bucket

### Create bash script to automate aws cli commands
- create a `backup.sh` script in the `/home/ubuntu/` directory on the bohemia server. 
- open the file and copy and paste the below information: 
`#!/bin/bash
file=data.RData
bucket=test-bucket-bohemia
resource="/${bucket}/${file}"
contentType="testupload"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key=AKIAQCHDFJQLYQFAB726
s3Secret=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
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
curl -X PUT -T "${file}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file}`

- When this file is run, it will replicate the awscli code written in the command line previously.

### Use crontab to automate backing up files to the s3 bucket `test-bucket-bohemia`

#### Crontab basics
- To edit a crontab: `crontab -e`
- To "list" the contents of your crontab: `crontab -l`
- To remove your crontab: `crontab -r`
- To edit crontab of a specific user: `sudo crontab -u <user-name> -e`
- To "list" the contents of another user's crontab: `suod crontab -l -u <user-name>`
- To remove the crontab of another user: `sudo crontab -r -u <user-name>`

#### Back up our data using crontab 
- Use the edit functionality of crontab: `crontab -e`
- To back up every minute, copy and use the following.
![](img/crontab.png)
- For everyday replace `* * * * *` with `0 0 * * *`. 



