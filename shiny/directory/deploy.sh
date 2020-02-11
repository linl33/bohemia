#!/bin/sh
echo "Starting deploy of directory app"
scp -r -i "/home/joebrew/.ssh/openhdskey.pem" ~/Documents/bohemia/shiny/directory ubuntu@bohemia.team:/home/ubuntu
ssh -i "/home/joebrew/.ssh/openhdskey.pem" -o StrictHostKeyChecking=no -l ubuntu bohemia.team "cd /home/ubuntu; sudo cp -r directory /srv/shiny-server; sudo systemctl restart shiny-server"

# chmod a+x deploy.sh
