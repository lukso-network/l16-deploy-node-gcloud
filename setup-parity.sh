#!/bin/bash

echo "Checking parity installation..."

cd /root
FILE=/snap/bin/parity
if ! test -f "$FILE"; then

    echo "Installing parity..."

    sudo apt-get update
    yes | sudo apt-get install git
    yes | sudo apt install snapd
    sudo snap install parity

    git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
    cd l16-deploy-node-gcloud

    # move config files
    sudo mkdir /l16
    sudo cp ./config.toml /l16/
    sudo cp ./l16_parity.json /l16/

    # parity system service
    sudo cp ./parity.service /etc/systemd/system
    sudo chmod +x /etc/systemd/system/parity.service
fi

echo "Starting parity..."

sudo systemctl enable parity

sudo systemctl start parity
