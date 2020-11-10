# Script to deploy an L16 nodes on Google Compute Engine


## Deployment (entire network)

You need to have authorized `gcloud` SDK on your local machine: https://cloud.google.com/sdk/docs/install

* Create Google Cloud project
```bash
  gcloud projects create [project-name]
$ gcloud projects create l16-network

  gcloud config set project [project-name]
$ gcloud config set project l16-network  
```
* Create Google Cloud Storage bucket in selected Google Cloud project
```bash
  gsutil mb gs://[bucket-name] -p [project-name]
$ gsutil mb gs://l16-storage -p l16-network
```
* Download repository
```bash
$ git clone https://github.com/lukso-network/l16-deploy-node-gcloud.git
```
* Run `SpinUp.sh` shell script and provide number of demanded geth nodes, parity nodes and the name of google storage bucket
```bash
$ ./SpinUp.sh
```

### Interactive method: 
```bash
$ ./SpinUp.sh
Enter number of geth nodes: 3
Enter number of parity nodes: 2
What's the name of bucket?: l16-storage
```
### Non-interactive method: 
```
  ./SpinUp.sh --non-interactive --geth [amount] --parity [amount] --bucket [bucket name]
$ ./SpinUp.sh --non-interactive --geth 3 --parity 2 --bucket l16-storage
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

### Genesis

Genesis files, are created under root directory of bucket, separately for geth and parity.

### Accounts

For security, accounts are created dynamically on the instances, wallet addresses are uploaded into `addresses` folder on a given cloud storage bucket.



### Enode URL's

Enode URL's, necessary for synchronization are uploaded into `enodes` folder on bucket.

### System service

Files `parity.service` and `geth.service` contains service unit configuration.

NOTE: For automation purposes geth nodes use `--unlock 0` argument in .service file. 
This may cause issues in future updates as this way of unlocking may be deprecated.

