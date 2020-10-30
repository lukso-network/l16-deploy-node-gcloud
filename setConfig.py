import sys
import toml

address_file = sys.argv[1]

with open ('./' + address_file) as f:
	address = f.read().splitlines()[0]

with open('config_empty.toml') as f:
    data = toml.load(f)
    data['Eth']['Miner']['Etherbase'] = address


with open('config.toml', 'w') as f:
    toml.dump(data, f)
