import json
import os

addresses = []
    
for file in os.scandir('./addresses'):
     filename = os.fsdecode(file)
     if filename.endswith(".txt"): 
         print(filename)
         with open(filename) as f:
             address = f.read().splitlines()[0]
             addresses.append(address)
         
with open('genesisEmpty-geth.json') as f:
    data = json.load(f)

data['config']['aura']['authorities'] = addresses

with open('genesis-geth.json', 'w') as f:
    json.dump(data, f)
