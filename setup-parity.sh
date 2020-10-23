#!/bin/bash

echo "Checking parity installation..."

FILE=/snap/bin/parity
if ! test -f "$FILE"; then

    echo "Installing parity..."

    sudo apt-get update
    yes | sudo apt-get install git
    yes | sudo apt install snapd
    sudo snap install parity

    git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
    cd l16-deploy-node-gcloud
    #git checkout l16

    # move config files
    sudo mkdir /etc/parity/
    sudo cp ./config.toml /etc/parity/
    sudo cp ./l16_parity.json /etc/parity/

    # parity system service
    sudo cp ./parity.service /etc/systemd/system
    sudo chmod +x /etc/systemd/system/parity.service
fi

echo "Starting parity..."

sudo systemctl enable parity

sudo systemctl start parity
