#!/bin/bash

#Will be used to identify address
export NODE_NAME=$(hostname)

#BUCKET
export BUCKET_NAME=<BUCKET>

#Set number of expected validators
export AUTHORITHIES=<TOTAL>

cd /root

sudo apt-get update

#Download dependencies
yes | sudo apt-get install git
yes | sudo apt-get install python3-pip
yes | sudo apt install snapd

sudo snap install parity
pip3 install toml

#Download project files
git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
cd l16-deploy-node-gcloud
git checkout parity

sudo mkdir /l16

cp ./node.pwds /l16/

#Create account
/snap/parity/current/usr/bin/parity --base-path /l16/chain_data --keys-path /l16/chain_data/keys/AuthorityRound account new --password node.pwds > $NODE_NAME.txt
mv /l16/chain_data/keys/AuthorityRound/ethereum/* /l16/chain_data/keys/AuthorityRound/

#Share IP address
curl ipinfo.io/ip > ip_$NODE_NAME.txt
gsutil cp ip_$NODE_NAME.txt gs://$BUCKET_NAME/ip

#Upload address into common bucket
gsutil cp ./$NODE_NAME.txt gs://$BUCKET_NAME/addresses

#Create and upload .lock file
touch create.lock
gsutil cp ./create.lock gs://$BUCKET_NAME/addresses

#Wait until all nodes will deliver their wallet addresses
while [ `gsutil du gs://$BUCKET_NAME/addresses/*.txt | wc -l` -ne $AUTHORITHIES ]; do
	#do nothing
	sleep 5
done

#Create genesis

echo "All addresses have been created, proceeding to create genesis."
gsutil rm gs://$BUCKET_NAME/addresses/create.lock
gsutil cp -r gs://$BUCKET_NAME/addresses .
python3 createGenesis.py && \
sudo cp ./genesis-parity.json /l16/ && \
gsutil cp genesis-parity.json gs://$BUCKET_NAME/

#daemonize process
sudo cp ./parity.service /etc/systemd/system
sudo chmod +x /etc/systemd/system/parity.service
sudo systemctl enable parity

#Start parity to generate node key
cp configEmpty.toml /l16/config.toml
sudo systemctl start parity
sleep 3
sudo systemctl stop parity


#get enode
cp bootnode /l16/
chmod +x /l16/bootnode
export ENODEID=$(/l16/bootnode -nodekey /l16/chain_data/network/key -writeaddress)
export IP=$(curl ipinfo.io/ip)
export ENODE=$(echo enode://$ENODEID@$IP:30303)

echo $ENODE > enode_$NODE_NAME.txt
gsutil cp enode_$NODE_NAME.txt gs://$BUCKET_NAME/enodes

#Wait until all enodes are delivered
while [ `gsutil du gs://$BUCKET_NAME/enodes/*.txt | wc -l` -ne $AUTHORITHIES ]; do
	#do nothing
	sleep 5
done

#Put address into config
python3 setConfig.py $NODE_NAME.txt

gsutil cp -r gs://$BUCKET_NAME/enodes .
python3 addBootnodes.py && \
cp config.toml /l16/config.toml

#START!
echo "Starting parity..."

sudo systemctl start parity
