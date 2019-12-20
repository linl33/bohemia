To deploy:

### Set up psql

```
psql
CREATE DATABASE fixmopeia
ctrl +d
```

R
```
library(dplyr)
```

### Install packages

sudo su - -c "R -e \"install.packages('leaflet.extras')\""
sudo su - -c "R -e \"install.packages('shinydashboard')\""
sudo su - -c "R -e \"install.packages('DBI')\""

(etc.)



### On local machine

scp -r -i "/home/joebrew/.ssh/openhdskey.pem" /home/joebrew/Documents/bohemia/shiny/fixmopeia ubuntu@bohemia.team:/home/ubuntu/Documents


### On remote machine

sudo cp -r /home/ubuntu/Documents/fixmopeia /srv/shiny-server/fixmopeia
cd /srv/shiny-server
sudo chmod -R 777 fixmopeia/
cd fixmopeia
Rscript set_up_database.R
sudo systemctl restart shiny-server
