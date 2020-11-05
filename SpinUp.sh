#!/bin/bash
read -p "Enter number of geth nodes: " GETH_NODES
read -p "Enter number of parity nodes: " PARITY_NODES
read -p "What's the name of bucket?: " BUCKET

export TOTAL=$(echo $GETH_NODES + $PARITY_NODES | bc)
echo $TOTAL

#PREPARE STARTUP SCRIPTS FOR GETH
sed  -e "s/<TOTAL>/$TOTAL/g; s/<BUCKET>/$BUCKET/g" setup-geth-Template.sh > setup-node-geth.sh

#PREPARE STARTUP SCRIPTS FOR PARITY
sed  -e "s/<TOTAL>/$TOTAL/g; s/<BUCKET>/$BUCKET/g" setup-parity-Template.sh > setup-node-parity.sh


#DEPLOY GETH NODES
for (( c=0; c<$GETH_NODES; c++ ))
do
  echo compute instances create l16-node-geth$c --metadata-from-file \
  startup-script=./setup-node-geth.sh --zone=europe-west3-c \
  --boot-disk-size=50GB --scopes storage-full;
  sleep 10
done

#DEPLOY PARITY NODES
for (( c=0; c<$PARITY_NODES; c++ ))
do
  echo compute instances create l16-node-parity$c --metadata-from-file \
  startup-script=./setup-node-parity.sh --zone=europe-west3-c \
  --boot-disk-size=50GB --scopes storage-full;
  sleep 10
done
