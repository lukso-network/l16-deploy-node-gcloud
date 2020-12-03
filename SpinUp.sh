#!/bin/bash

export INTERACTIVE=true
export GETH_NODES=0
export PARITY_NODES=0
export BUCKET=""

params="$(getopt -o h -l geth:,parity:,bucket:,non-interactive --name \
"$0" -- "$@")"

while true
do
    case "$1" in
       # This case does nothing but is necessary, getops requires at least one
       # short option.
       -h)
            shift
            ;;

        --non-interactive)
            INTERACTIVE=false
            shift
            ;;

        --geth)
          GETH_NODES=$2
          shift 2
          ;;

        --parity)
          PARITY_NODES=$2
          shift 2
          ;;

        --bucket)
          BUCKET=$2
          shift 2
          ;;

        --)
          shift
          break
          ;;
        *)
          echo "Not implemented: $1" >&2
          exit 1
          ;;

    esac
done

if [ $INTERACTIVE == true ]; then

  CONFIRM_STATUS=false
  while [ $CONFIRM_STATUS == false ]
  do
    read -p "Enter number of geth nodes: " GETH_NODES
    read -p "Enter number of parity nodes: " PARITY_NODES
    read -p "What's the name of bucket?: " BUCKET
    echo

    echo "Geth nodes:    " $GETH_NODES
    echo "Parity nodes:  " $PARITY_NODES
    echo "GS Bucket:     " $BUCKET
    read -p "Confirm? (Y/n) " CONFIRM_CHECK
    if [ $CONFIRM_CHECK == "Y" ]; then
      CONFIRM_STATUS=true
    fi
  done

fi

export TOTAL=$(echo $GETH_NODES + $PARITY_NODES | bc)
echo $TOTAL

#PREPARE STARTUP SCRIPTS FOR GETH
sed  -e "s/<TOTAL>/$TOTAL/g; s/<BUCKET>/$BUCKET/g" setup-geth-Template.sh > setup-node-geth.sh

#PREPARE STARTUP SCRIPTS FOR PARITY
sed  -e "s/<TOTAL>/$TOTAL/g; s/<BUCKET>/$BUCKET/g" setup-parity-Template.sh > setup-node-parity.sh


#DEPLOY GETH NODES
for (( c=0; c<$GETH_NODES; c++ ))
do
  gcloud compute instances create l16-node-geth$c --metadata-from-file \
  startup-script=./setup-node-geth.sh --zone=europe-west3-c \
  --boot-disk-size=50GB --scopes storage-full --image-project=ubuntu-os-cloud \
  --image-family=ubuntu-2004-lts;
  sleep 10
done

#DEPLOY PARITY NODES
for (( c=0; c<$PARITY_NODES; c++ ))
do
  gcloud compute instances create l16-node-parity$c --metadata-from-file \
  startup-script=./setup-node-parity.sh --zone=europe-west3-c \
  --boot-disk-size=50GB --scopes storage-full --image-project=ubuntu-os-cloud \
  --image-family=ubuntu-2004-lts;
  sleep 10
done
