#!/bin/bash

#Will be used to identify address
export NODE_NAME=$(hostname)
echo $NODE_NAME
cd /root

sudo apt-get update

yes | sudo apt-get install git
yes | sudo apt-get install python3-pip
yes | sudo apt install snapd
sudo snap install parity
pip3 install toml

git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
cd l16-deploy-node-gcloud
git checkout parity

sudo mkdir /l16

cp ./node.pwds /l16/

#Create account
/snap/parity/current/usr/bin/parity --base-path /l16/chain_data account new --password node.pwds > $NODE_NAME.txt

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
