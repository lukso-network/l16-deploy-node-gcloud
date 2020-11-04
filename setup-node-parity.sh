#!/bin/bash

#Will be used to identify address
export NODE_NAME=$(hostname)

#Set number of expected validators
export AUTHORITHIES=5

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
/snap/parity/current/usr/bin/parity --base-path /l16/chain_data --keys-path /l16/chain_data/keys/AuthorityRound account new --password node.pwds > $NODE_NAME.txt
mv /l16/chain_data/keys/AuthorityRound/ethereum/* /l16/chain_data/keys/AuthorityRound/

#Wait until all nodes will deliver their IP addresses
while [ `gsutil du gs://l16-common/ip/*.txt | wc -l` -ne $AUTHORITHIES ]; do
	#do nothing
	sleep 5
done

gsutil cp -r gs://l16-common/ip .


#Put address into config
python3 setConfig.py $NODE_NAME.txt
cp config.toml /l16/

#Upload address into common bucket
gsutil cp ./$NODE_NAME.txt gs://l16-common/addresses

#Create and upload .lock file
touch create.lock
gsutil cp ./create.lock gs://l16-common/addresses

#Wait until all nodes will deliver their wallet addresses
while [ `gsutil du gs://l16-common/addresses/*.txt | wc -l` -ne $AUTHORITHIES ]; do
	#do nothing
	sleep 5
done

#Is there genesis already?

if [ `gsutil du gs://l16-common/genesis-parity.json | wc -l` -eq 1 ]
  then
  	#Yes, let's download it.
  	echo "Downloading genesis"
    gsutil cp gs://l16-common/genesis-parity.json .
    sudo cp ./genesis-parity.json /l16/

  else
    #No, let's create it and upload to bucket.
    echo "All addresses have been created, proceeding to create genesis."
    gsutil rm gs://l16-common/addresses/create.lock
    gsutil cp -r gs://l16-common/addresses .
    python3 createGenesis.py && \
    sudo cp ./genesis-parity.json /l16/ && \
    gsutil cp genesis-parity.json gs://l16-common/



fi

#Share IP address
curl ipinfo.io/ip > ip_$NODE_NAME.txt

#daemonize process
sudo cp ./parity.service /etc/systemd/system
sudo chmod +x /etc/systemd/system/parity.service

#START!
echo "Starting parity..."

sudo systemctl enable parity
sudo systemctl start parity


# #######
# if [ `gsutil du gs://l16-common/addresses/*.txt | wc -l` -eq 5 ]
#   then
#     echo "All addresses have been created, proceeding to create genesis."
#     gsutil rm gs://l16-common/addresses/create.lock
#     gsutil cp -r gs://l16-common/addresses .
#     python3 createGenesis.py

# fi


