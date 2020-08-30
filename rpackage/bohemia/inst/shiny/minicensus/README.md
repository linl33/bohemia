
### On remote machine

sudo rm -r /home/ubuntu/Documents/minicensus


### On local machine

scp -r -i "/home/joebrew/.ssh/odkkey.pem" /home/joebrew/Documents/bohemia/rpackage/bohemia/inst/shiny/minicensus ubuntu@bohemia.team:/home/ubuntu/Documents


### On remote machine

sudo rm -r /srv/shiny-server/minicensus;
sudo cp -r /home/ubuntu/Documents/minicensus /srv/shiny-server/minicensus;
cd /srv/shiny-server;
sudo chmod -R 777 minicensus/;
#sudo su - -c "R -e \"remove.packages('bohemia')\""; 
#sudo su - -c "R -e \"devtools::install_github('databrew/bohemia', subdir = 'rpackage/bohemia')\""; 
sudo systemctl restart shiny-server;

