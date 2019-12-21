To deploy:

sudo su - -c "R -e \"install.packages('leaflet.extras')\""
sudo su - -c "R -e \"install.packages('shinydashboard')\""
sudo su - -c "R -e \"install.packages('sp')\""
sudo su - -c "R -e \"install.packages('rmarkdown')\""

sudo su - -c "R -e \"remove.packages('bohemia')\""
sudo su - -c "R -e \"devtools::install_github('databrew/bohemia', subdir = 'rpackage/bohemia', dependencies = TRUE)\""





sudo systemctl restart shiny-server


### On local machine

scp -r -i "/home/joebrew/.ssh/openhdskey.pem" /home/joebrew/Documents/bohemia/shiny/bohemiaops ubuntu@bohemia.team:/home/ubuntu/Documents


### On remote machine

sudo cp -r /home/ubuntu/Documents/bohemiaops /srv/shiny-server/bohemiaops

cd /srv/shiny-server
sudo chmod -R 777 bohemiaops/
cd bohemiaops

sudo systemctl restart shiny-server
