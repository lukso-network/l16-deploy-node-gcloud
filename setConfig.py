import sys
import toml

address_file = sys.argv[1]

with open ('./' + address_file) as f:
	address = f.read().splitlines()[0]

with open('configEmpty.toml') as f:
    data = toml.load(f)
    data['mining']['engine_signer'] = address


with open('config.toml', 'w') as f:
    toml.dump(data, f)
