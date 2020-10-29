#!/bin/bash

#Will be used to identify address
export NODE_NAME=$(hostname)

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
python3 setConfig.py $NODE_NAME.txt

gsutil cp ./$NODE_NAME.txt gs://l16-common/addresses
touch create.lock
gsutil cp ./create.lock gs://l16-common/addresses

if [ `gsutil du gs://l16-common/addresses/*.txt | wc -l` -eq 5 ]
  then
    echo "All addresses have been created, proceeding to create genesis."
    gsutil rm gs://l16-common/addresses/create.lock
    gsutil cp -r gs://l16-common/addresses .
    python3 createGenesis.py

fi
