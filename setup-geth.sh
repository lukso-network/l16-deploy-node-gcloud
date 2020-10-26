#!/bin/bash

echo "Checking geth installation..."

cd /root

if ! test -f "$FILE"; then

    echo "Installing geth..."

    sudo apt-get update
    yes | sudo apt-get install git

    git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
    cd l16-deploy-node-gcloud
    git checkout geth

    # move config files
    sudo mkdir /l16
    sudo cp ./geth /l16/
    sudo cp ./config.toml /l16/
    sudo cp ./l16_geth.json /l16/

    # geth system service
    sudo cp ./geth.service /etc/systemd/system
    sudo chmod +x /etc/systemd/system/geth.service
fi

echo "Starting geth..."

/l16/geth init /l16/l16_geth.json --datadir /l16/chain_data

sudo systemctl enable geth

sudo systemctl start geth
