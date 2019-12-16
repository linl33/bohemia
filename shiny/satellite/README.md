To deploy:

sudo su - -c "R -e \"install.packages('leaflet.extras')\""
sudo su - -c "R -e \"install.packages('shinydashboard')\""
sudo su - -c "R -e \"install.packages('sp')\""

sudo systemctl restart shiny-server


### On local machine

scp -r -i "/home/joebrew/.ssh/openhdskey.pem" /home/joebrew/Documents/bohemia/shiny/satellite ubuntu@bohemia.team:/home/ubuntu/Documents


### On remote machine

sudo cp -r /home/ubuntu/Documents/satellite /srv/shiny-server/satellite

sudo systemctl restart shiny-server
