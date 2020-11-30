#!/bin/bash

#Will be used to identify address
export NODE_NAME=$(hostname)

#BUCKET
export BUCKET_NAME=<BUCKET>

cd /root

sudo apt-get update

yes | sudo apt-get install git
yes | sudo apt-get install python3-pip
pip3 install toml

git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
cd l16-deploy-node-gcloud
git cd geth

sudo mkdir /l16

cp ./geth /l16/
cp ./node.pwds /l16/

sudo chmod +x /l16/geth




#Initialize blockchain
sudo /l16/geth --datadir /l16/chain_data init /l16/genesis-geth.json

#daemonize process
sudo cp ./geth.service /etc/systemd/system
sudo chmod +x /etc/systemd/system/geth.service
sudo systemctl enable geth

#get enode
cp bootnode /l16/
chmod +x /l16/bootnode
export ENODEID=$(/l16/bootnode -nodekey /l16/chain_data/geth/nodekey -writeaddress)
export IP=$(curl ipinfo.io/ip)
export ENODE=$(echo enode://$ENODEID@$IP:30303)

echo $ENODE > enode_$NODE_NAME.txt
gsutil cp enode_$NODE_NAME.txt gs://$BUCKET_NAME/enodes


gsutil cp -r gs://$BUCKET_NAME/enodes .
python3 addBootnodes.py && \
cp config.toml /l16/config.toml

#START!
echo "Starting geth..."

sudo systemctl start geth
