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

### Configure awscli
- Open a terminal and run `aws configure`. 
![]('img/aws_1')
- Add in the access key ID and secret access key form the credentials file. 
- then select the default region name and format.
aws_2

## Managing buckets

### Creating buckets
- To view all the buckets on your account type:
`aws s3 ls`
- You can either create a bucket on your IAM console or do it directly from the command line by typing 
`aws s3 mb s3://bucket-name`
- If a bucket already exists, you can view its contents by typing:
`aws s3 ls s3://bucket-name`
- If you create a bucket via the IAM console, you must select the same region you specified when running `aws configure`. In all cases, the sub region must be specified (example: us-west-1 is equivalent to us-west).

### Removing buckets
- To remove a bucket, type: 
`aws s3 rb s3://bucket-name`
- If the bucket is not empty, type: 
`aws s3 rb s3://bucket-name --force`

### Using buckets

- moving files from local to s3:
`aws s3 cp file.txt s3://bohemiabucket`

## from s3 to local
`aws s3 cp s3://bohemiabucket/file.txt ./`

## from server to s3

## from s3 to server
