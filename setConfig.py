import os
import sys
import toml

address_file = sys.argv[1]
ip_addresses =[]

for file in os.scandir('./ip'):
     filename = os.fsdecode(file)
     if filename.endswith(".txt"):
         with open(filename) as f:
             ip_address = f.read().strip().splitlines()[0]
             ip_addresses.append(ip_address)

with open ('./' + address_file) as f:
	address = f.read().splitlines()[0]

with open('configEmpty.toml') as f:
    data = toml.load(f)
    data['mining']['engine_signer'] = address
    data['network']['bootnodes'] = ip_addresses


with open('config.toml', 'w') as f:
    toml.dump(data, f)
