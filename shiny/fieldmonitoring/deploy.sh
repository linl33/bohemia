#!/bin/sh
echo "Starting deploy of datamanager app"
scp -r -i "/home/joebrew/.ssh/openhdskey.pem" ~/Documents/bohemia/shiny/datamanager ubuntu@bohemia.team:/srv/shiny-server
# chmod a+x deploy.sh
