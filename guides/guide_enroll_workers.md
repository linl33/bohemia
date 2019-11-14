# Enroll workers

This guide shows you how to enroll workers for the Bohemia project. Before starting this guide, one should have already finished the following steps:

- [1. Set up the server](guide_odk_setup.md)
- [2. Create forms](guide_forms.md)

## SSH into the server

- SSH into the server which is running ODKAggregate. If you followed the steps in the [server guide](guide_odk_setup.md), you should be able to do this by simply running `odk`

## Clone the Bohemia repo

- If you have not already done so, you'll need to clone the project repo. To do so, from the command line, run:
```
cd /home/ubuntu
mkdir Documents
cd Documents
git clone https://github.com/databrew/bohemia
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
```

## Install R

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo apt update
sudo apt install r-base
```

## Install R packages

(This will take a few minutes)

```
sudo su - -c "R -e \"install.packages('readxl')\"";
sudo su - -c "R -e \"install.packages('RPostgreSQL')\"";
sudo su - -c "R -e \"install.packages('devtools')\"";
sudo su - -c "R -e \"install.packages('tidyverse')\"";
sudo su - -c "R -e \"install.packages('DBI')\"";
sudo su - -c "R -e \"install.packages('tidyverse')\"";
sudo su - -c "R -e \"install.packages('RPostgres')\"";
sudo su - -c "R -e \"install.packages('dismo')\"";
sudo su - -c "R -e \"install.packages('dplyr')\"";
sudo su - -c "R -e \"install.packages('gpclib')\"";
sudo su - -c "R -e \"install.packages('gsheet')\"";
sudo su - -c "R -e \"install.packages('maptools')\"";
sudo su - -c "R -e \"install.packages('qrcode')\"";
sudo su - -c "R -e \"install.packages('readr')\"";
sudo su - -c "R -e \"install.packages('rgeos')\"";
sudo su - -c "R -e \"install.packages('sp')\"";
sudo su - -c "R -e \"install.packages('tidyr')\"";
sudo su - -c "R -e \"install.packages('rmarkdown')\"";
sudo su - -c "R -e \"install.packages('ggthemes')\"";
sudo su - -c "R -e \"install.packages('leaflet')\"";
sudo su - -c "R -e \"install.packages('maps')\"";
sudo su - -c "R -e \"install.packages('Hmisc')\"";
sudo su - -c "R -e \"install.packages('extrafont')\"";
sudo su - -c "R -e \"install.packages('rgdal')\"";
sudo su - -c "R -e \"install.packages('deldir')\"";
sudo su - -c "R -e \"install.packages('kableExtra')\"";
```

## Install the Bohemia R package

```
sudo chmod a+rwx /usr/local/lib/R/site-library
cd bohemia/rpackage/bohemia
Rscript build_package.R
```

## Set up postgresql

(Postgresql was already installed via `sudo apt install postgresql-10`)

```
sudo -i -u postgres
createuser --interactive
- name of role: ubuntu
- superuser: y
createdb ubuntu
exit
```

## Set up the tables/database

- Run the following scrip to set up the `ids` database:
```
cd /home/ubuntu/Documents/bohemia/scripts
./set_up_ids.sh
```

## Enroll a worker

- To enroll a worker, you need to have the following information:
  - First name
  - Last name
  - Location (Mozambique or Tanzania)
- Get into the R console: `R`
- Run the following to enroll, for example, John Doe from Tanzania:
```
library(bohemia)
enroll_worker(name_first='John', name_last='Doe', location='Tanzania')
```
- Confirm that the worker has been enrolled by leaving the R session and running the following:
```
psql ids #get into psql session
select * from workers;
select * from households;
```
- There is now:
  - 1 row in the `workers` table of the `ids` database with the worker information
  - 1000 rows in the `households` table of the `ids` database. These are the household ids assigned to this worker

## Install latex (for printing QR codes)

```
sudo apt-get install texlive-latex-base
```

## Generate QR codes

- To generate QR codes for the household IDs assigned to the worker, run the following in R:
```
library(bohemia)
# Assuming worker ID = 001
print_worker_qrs(wid='001', restrict = 1:3)
```
