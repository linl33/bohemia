#!/bin/bash
#ROOT_FOLDER_PATH=/home/ubuntu/Documents/bohemia
# Runs odk_get_data for instance id's not already retrieved.
set -e
source ~/.virtualenvs/bohemia/bin/activate
cd ~/Documents/bohemia/scripts
python3 check_virtualenv.py
echo "Activated"
echo "Deactivated"
deactivate