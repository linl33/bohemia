To deploy:

sudo su - -c "R -e \"install.packages('shinydashboard')\""
sudo su - -c "R -e \"install.packages('packagenme', repos = 'http://cran.rstudio.com/',dependencies =TRUE)\""


sudo systemctl restart shiny-server


### On local machine

scp -r -i "/home/joebrew/.ssh/openhdskey.pem" /home/joebrew/Documents/bohemia/shiny/ids ubuntu@bohemia.team:/home/ubuntu/Documents


### On remote machine

sudo cp -r /home/ubuntu/Documents/ids /srv/shiny-server/ids

sudo systemctl restart shiny-server
