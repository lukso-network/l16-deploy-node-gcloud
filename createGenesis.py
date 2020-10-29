import json
import os

addresses = []
    
for file in os.scandir('./addresses'):
     filename = os.fsdecode(file)
     if filename.endswith(".txt"): 
         print(filename)
         with open(filename) as f:
             address = f.read().strip().splitlines()[0]
             addresses.append(address)
         
with open('genesisEmpty-parity.json') as f:
    data = json.load(f)

data['engine']['authorityRound']['params']['validators']['list'] = addresses

with open('genesis-parity.json', 'w') as f:
    json.dump(data, f)
