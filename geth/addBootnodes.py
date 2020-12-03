import sys
import os
import toml

bootnodes = []

for file in os.scandir('./enodes'):
     filename = os.fsdecode(file)
     if filename.endswith(".txt"):
         print(filename)
         with open(filename) as f:
             bootnode = f.read().splitlines()[0]
             bootnodes.append(bootnode)

with open('config.toml') as f:
    data = toml.load(f)
    data['Node']['P2P']['BootstrapNodes'] = bootnodes
    data['Node']['P2P']['BootstrapNodesV5'] = bootnodes


with open('config.toml', 'w') as f:
    toml.dump(data, f)