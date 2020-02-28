# Guide for converting xlsform to pdf

(See reference at:)

## Get server ready

```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install htop libfontconfig1 libxrender1 python3-pip python3-dev python3-venv nginx git vim

# Clone project
cd /opt
sudo git clone https://github.com/PMA-2020/ppp-web.git

# Create virtual environment
cd ppp-web
sudo python3 -m venv .venv
source .venv/bin/activate
sudo chmod -R a+rwx /opt
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt

# Install pmix
# pip install -r https://raw.githubusercontent.com/<git-suburl>/requirements.txt
pip install -r https://raw.githubusercontent.com/jkpr/pmix/develop/requirements.txt
pip install pmix
# pip install https://github.com/<git-suburl>
pip install https://github.com/jkpr/pmix/archive/develop.zip

# Edit config.py
cd ppp_web
sudo nano config_py
# Add the following line:
PYTHON_PATH='/opt/ppp-web/.venv/bin/python3'

# Set execution flag
sudo chmod +x bin/wkhtmltopdf

# Set up logging
mkdir logs/
touch access-logfile.log && touch error-logfile.log

# Run app_instance in background
gunicorn -b 0.0.0.0:8080 run:app_instance &

```
