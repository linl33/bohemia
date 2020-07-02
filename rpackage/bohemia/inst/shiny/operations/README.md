To deploy:

sudo apt-get install libxml2-dev
sudo su - -c "R -e \"install.packages('leaflet.extras')\""
sudo su - -c "R -e \"install.packages('shinydashboard')\""
sudo su - -c "R -e \"install.packages('sp')\""
sudo su - -c "R -e \"install.packages('rmarkdown')\""
sudo su - -c "R -e \"install.packages('googlesheets')\""


sudo su - -c "R -e \"remove.packages('bohemia')\""
sudo su - -c "R -e \"devtools::install_github('databrew/bohemia', subdir = 'rpackage/bohemia', dependencies = TRUE, force = TRUE)\""





sudo systemctl restart shiny-server


### On local machine

scp -r -i "/home/joebrew/.ssh/odkkey.pem" /home/joebrew/Documents/bohemia/rpackage/bohemia/inst/shiny/operations ubuntu@bohemia.team:/home/ubuntu/Documents


### On remote machine

sleep 500 ;
sudo cp -r /home/ubuntu/Documents/operations /srv/shiny-server/operations;
cd /srv/shiny-server;
sudo chmod -R 777 operations/;
sudo systemctl restart shiny-server;

