# Script to deploy a L16 nodes on Google Cloud Compute


## Deployment (network)
* Create Google Cloud project
* In that project create Google Cloud Storage bucket 
```bash
$ git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
$ cd l16-deploy-node-gcloud
$ ./SpinUp.sh //interactive
Enter number of geth nodes: 3
Enter number of parity nodes: 2
What's the name of bucket?: l16-common
$ ./SpinUp.sh --geth 3 --parity 2 --bucket l16-common --non-interactive --proceed //non-interactive
```

## Deployment (archive node)
To deploy an archive node, genesis from one of the authorithy nodes must be created and placed in a storage bucket.

### Geth
```bash
$ gcloud compute instances create archive-node-geth --metadata-from-file startup-script=./setup-archive-node-geth.sh --zone=europe-west3-c --boot-disk-size=50GB
```

### Parity
```bash
$ gcloud compute instances create archive-node-parity --metadata-from-file startup-script=./setup-archive-node-parity.sh --zone=europe-west3-c --boot-disk-size=50GB
```

## Usage

### Passwords

Passwords are stored in `node.pwds`

### System service

Files `parity.service` and `geth.service` contains service unit configuration
