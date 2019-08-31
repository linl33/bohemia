# ODK Services

(For full reference, see: https://docs.opendatakit.org/odk-x/services-managing/#prerequisites)

## ODK Application Designer

(For full reference, see: https://docs.opendatakit.org/odk-x/app-designer-intro/)

### Prerequistes

#### Java

- Jave should already be installed. If not, `sudo apt install openjdk-8-jre openjdk-8-jdk`. Assuming it is:
- Set the `JAVA_HOME` environment variable. To do so:
- `sudo nano /etc/environment`
- Add line like `JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"`
- Run `source /etc/environment`

#### NodeJS, NPM and Grunt

- Run the following:
```
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -`
sudo apt install nodejs
```
- Ensure that it's all working
```
node --version
npm --version
```
- Install grunt:
```
npm install -g grunt-cli
```
- And ensure that it's working:
```
grunt --version
```

#### Android SDK
- First, install some prerequistes:
```
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
```
- Then install Android Studio via:
```
sudo snap install android-studio --classic
```
- Then install android sdk
```
sudo apt update && sudo apt install android-sdk
```
- Open AndroidStudio, select "Do not import settings" when prompted, select custom installation
- In the SDK Components setup, select everything. Keep the Android SDK Location as default (`/home/<user>/Android/Sdk`). Go through the other menus and click "Finish"
- Ensure that you have adb (Android Debug Bridge) by running:
```
adb version
```

### Install Application Designer itself

- Create a local folder called `odkx`
- Download into it the zip file at https://github.com/opendatakit/app-designer/releases/tag/2.1.4
- `cd` into `odkx` and unzip the file there
- Due to a bug in Designer (meant for max, not linux), you'll need to make a mionr change in one file. Open `app-designer-2.1.4/Gruntfile.js` and change the line with the words "Google Chrome" from
```
return 'Google Chrome';
```
to:
```
return 'google-chrome';
```
- `cd` into `app-designer-2.1.4`
- Run `grunt`
- A chrome tab should open with the ODK interace
- For more info on using Application Designer, see: https://docs.opendatakit.org/odk-x/app-designer-using/

## ODK Cloud Endpoints

(For full reference, see: https://docs.opendatakit.org/odk-x/cloud-endpoints-intro/)

- ssh into the server:
```
ssh -i "/home/joebrew/.ssh/openhdskey.pem" ubuntu@papu.us
```

#### Install docker

- Install docker by running the following line-by-line:
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install docker-ce
sudo apt-get install virtualbox
```
- Check that docker is running:
```
sudo systemctl status docker
```
- Make it so docker runs at start
```
sudo systemctl start docker && sudo systemctl enable docker
```
- Make it so that you don't have to be sudo to run docker
```
sudo usermod -aG docker
```
- Configure swarm mode:
```
sudo ufw allow 2376/tcp && sudo ufw allow 7946/udp &&
sudo ufw allow 7946/tcp && sudo ufw allow 80/tcp &&
sudo ufw allow 2377/tcp && sudo ufw allow 4789/udp
```
- Reload firewall and set it up to start on boot:
```
sudo ufw reload && sudo ufw enable
```
- Restart docker:
```
sudo systemctl restart docker
```
- Install docker-machine:
```
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine
```
- Make docker-machine executable: `cd /usr/local/bin; chmod 755 docker-machine`

- Create docker cluster (cluster manager will be node-1):
```
docker-machine create manager1
docker-machine ssh manager1
```

## ODK Survey

(For full reference, see: https://docs.opendatakit.org/odk-x/survey-install/)

### Prerequisites and set-up

#### Set up android device

- On your Android device, install OI Fall Manager from the Google Play Store: https://play.google.com/store/apps/details?id=org.openintents.filemanager
- On your Android device, go to `Settings` and then `Security and Privacy` and make sure that "Unknown Sources" is checked/enabled
- On your Android device, open a web browser and go to https://github.com/opendatakit/services/releases/latest. Download the APK.
- Open the file and install
