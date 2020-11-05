# Script to deploy a L16 nodes on Google Cloud Compute

## Deployment (network)
```bash
$ git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
$ cd l16-deploy-node-gcloud
$ ./SpinUp.sh
```

## Deployment (single node)

### Geth
```bash
$ gcloud compute instances create testing-node-geth0 --metadata-from-file startup-script=./setup-node-geth.sh --zone=europe-west3-c --boot-disk-size=50GB
```

### Parity
```bash
$ gcloud compute instances create testing-node-parity0 --metadata-from-file startup-script=./setup-node-parity.sh --zone=europe-west3-c --boot-disk-size=50GB```
```

## Usage

### Passwords

Passwords are stored in `node.pwds`

### Parity system service

File `parity.service` contains service unit configuration
