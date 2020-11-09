# Script to deploy a L16 nodes on Google Cloud Compute


## Deployment (entire network)
* Create Google Cloud project
* In that project create Google Cloud Storage bucket
* Download repository
* Run `SpinUp.sh` shell script

```bash
$ gcloud projects create l16-network
$ gsutil mb gs://l16-storage -p l16-network
$ git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
$ cd l16-deploy-node-gcloud
```

### Interactive method: 
```bash
$ ./SpinUp.sh //interactive
Enter number of geth nodes: 3
Enter number of parity nodes: 2
What's the name of bucket?: l16-storage
```
### Non-interactive method: 
```
$ ./SpinUp.sh --non-interactive --geth 3 --parity 2 --bucket l16-common //non-interactive
```

Make sure to check created nodes on your account to avoid unexpected charges.

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

### Accounts

For security, accounts are created dynamically on the instances, wallet addresses are uploaded into `addresses` "folder" on a given cloud storage bucket.

### Passwords

Passwords are stored in `node.pwds`

### System service

Files `parity.service` and `geth.service` contains service unit configuration
NOTE: For automation purposes 
