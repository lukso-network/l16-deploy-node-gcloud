#!/bin/bash

#Will be used to identify address
export NODE_NAME=$(hostname)

#BUCKET
export BUCKET_NAME=<BUCKET>

#Set number of expected validators
export AUTHORITHIES=<TOTAL>

cd /root

sudo apt-get update

yes | sudo apt-get install git
yes | sudo apt-get install python3-pip
pip3 install toml

git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
cd l16-deploy-node-gcloud
git checkout geth

sudo mkdir /l16

cp ./geth /l16/
cp ./node.pwds /l16/

sudo chmod +x /l16/geth

#Create account
/l16/geth --datadir /l16/chain_data account new --password /l16/node.pwds | grep -Eo '0x[a-fA-F0-9]{40}' > $NODE_NAME.txt

#Share IP address
curl ipinfo.io/ip > ip_$NODE_NAME.txt
gsutil cp ip_$NODE_NAME.txt gs://$BUCKET_NAME/ip

#Put address into config
python3 setConfig.py $NODE_NAME.txt && \
sudo cp ./config.toml /l16/

#Upload address into common bucket
gsutil cp ./$NODE_NAME.txt gs://$BUCKET_NAME/addresses

#Create and upload .lock file
touch create.lock
gsutil cp ./create.lock gs://$BUCKET_NAME/addresses

#Wait until all nodes will deliver their addresses
while [ `gsutil du gs://$BUCKET_NAME/addresses/*.txt | wc -l` -ne $AUTHORITHIES ]; do
	#do nothing
	sleep 5
done

#Create genesis

echo "All addresses have been created, proceeding to create genesis."
gsutil rm gs://$BUCKET_NAME/addresses/create.lock
gsutil cp -r gs://$BUCKET_NAME/addresses .
python3 createGenesis.py &&  \
sudo cp genesis-geth.json /l16/ && \
gsutil cp genesis-geth.json gs://$BUCKET_NAME/

#Initialize blockchain
sudo /l16/geth --datadir /l16/chain_data init /l16/genesis-geth.json

#daemonize process
sudo cp ./geth.service /etc/systemd/system
sudo chmod +x /etc/systemd/system/geth.service
sudo systemctl enable geth

#get enode
export ENODEID=$(/l16/bootnode -nodekey /l16/chain_data/geth/nodekey -writeaddress)
export IP=$(curl ipinfo.io/ip)
export ENODE=$(echo enode://$ENODEID@$IP:30303)

echo $ENODE > enode_$NODE_NAME.txt
gsutil cp enode_$NODE_NAME.txt gs://$BUCKET_NAME/enodes

#Wait until all enodes are delivered
while [ `gsutil du gs://$BUCKET_NAME/enodes/*.txt | wc -l` -ne $AUTHORITHIES ]; do
	#do nothing
	sleep 5
done

gsutil cp -r gs://$BUCKET_NAME/enodes .
python3 addBootnodes.py && \
cp config.toml /l16/config.toml

#

#START!
echo "Starting geth..."

sudo systemctl start geth
