# Guide for awscli and AWS S3

## Installing awscli

```
sudo apt-get update;
sudo apt-get install awscli
```

## Configure awscli 


### Credential file settings

- The AWS CLI stores the credentials that you specify with `aws configure` in a local file named `credentials`, in a folder named `.aws` in your home directory. The other configuration options that you specify with `aws configure` are stored in a local file named `config`, also stored in the `.aws` folder in your `home` directory. Where you find your `home` directory location varies based on the operating system, but is referred to using the environment variables `%UserProfile%` in Windows and `$HOME` or `~` (tilde) in Unix-based systems.

Linux of MacOS
```
ls ~/.aws
```
```
dir "%UserProfile%\.aws"
```
