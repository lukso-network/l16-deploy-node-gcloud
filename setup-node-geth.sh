#!/bin/bash

#Will be used to identify address
export NODE_NAME=$(hostname)

#Set number of expected validators
export AUTHORITHIES=5

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

#Put address into config
python3 setConfig.py $NODE_NAME.txt && \
sudo cp ./config.toml /l16/

#Upload address into common bucket
gsutil cp ./$NODE_NAME.txt gs://l16-common/addresses

#Create and upload .lock file
touch create.lock
gsutil cp ./create.lock gs://l16-common/addresses

#Wait until all nodes will deliver their addresses
while [ `gsutil du gs://l16-common/addresses/*.txt | wc -l` -ne 5  ]; do
	#do nothing
	sleep 5
done

#Is there genesis already?
if [ `gsutil du gs://l16-common/genesis-geth.json | wc -l` -eq 1 ]
  then
  	#Yes, let's download it.
  	echo "Downloading genesis"
    gsutil cp gs://l16-common/genesis-geth.json .
    sudo cp ./genesis-geth.json /l16/
  	
  else
    #No, let's create it and upload to bucket.
  	echo "All addresses have been created, proceeding to create genesis."
    gsutil rm gs://l16-common/addresses/create.lock
    gsutil cp -r gs://l16-common/addresses/ .
    python3 createGenesis.py &&  \
    gsutil cp genesis-geth.json gs://l16-common/

fi

#Initialize blockchain
sudo /l16/geth --datadir /l16/chain_data init /l16/genesis-geth.json

#daemonize process
sudo cp ./geth.service /etc/systemd/system
sudo chmod +x /etc/systemd/system/geth.service

#START!
echo "Starting geth..."

sudo systemctl enable geth

#sudo systemctl start geth