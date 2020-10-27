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
    git checkout parity
    cd l16-deploy-node-gcloud

    sudo mkdir /l16

    #create account
    sudo parity --base-path=/l16/chain_data account new

    # parity system service
    sudo cp ./parity.service /etc/systemd/system
    sudo chmod +x /etc/systemd/system/parity.service
fi

echo "Starting parity..."

sudo systemctl enable parity