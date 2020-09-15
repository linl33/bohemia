To deploy:


### On remote machine

sudo rm -r /home/ubuntu/Documents/bohemiapp


### On local machine

scp -r -i "/home/joebrew/.ssh/odkkey.pem" /home/joebrew/Documents/bohemia/rpackage/bohemia/inst/shiny/bohemiapp ubuntu@bohemia.team:/home/ubuntu/Documents


### On remote machine

sudo rm -r /srv/shiny-server/bohemiapp;
sudo cp -r /home/ubuntu/Documents/bohemiapp /srv/shiny-server/bohemiapp;
cd /srv/shiny-server;
sudo chmod -R 777 bohemiapp/;
sudo systemctl restart shiny-server;


