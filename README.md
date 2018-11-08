#Evolution Land

1. this project is a part of evolutionland
2. this part is based on truffle framework


###Contributor notice
please add the following files in .gitignore:
- package*.json
- truffle*.js

### tips for truffle
> for mac user only
```bash
# check  if the solidity version in truffle match the one in contracts
$ truffle version
 # if these two don't match, please update the solcjs in truffle to match them
$ cd /usr/local/lib/node_modules/truffle
$ npm install solc@0.4.23
```

after the operations above, problem solved.

#### NOTE
openZeppelin related dependency's name is :"openzeppelin-solidity", not "zeppelin-solidity"

### addresses on kovan
```python
IDSettingIds: 0xb961ad45881bb60b770a841f0a30d7f62ef30f06
ChannelDividend: 0xc02ae6568bd1c4937b720499315aa02be8838598

DividendPoolProxy: 0x66f81b6126a45f46aa5be3d2e2167698130b692c
DividendPool: 0x738d988d2c3f5c0792d96b77e7c5077ab7da0376

FrozenDividendProxy: 0xd2311e7b1f1df0f177d4b2b1134e91d16fce024f
FrozenDividend: 0xdbcfd1cf5a4bb785ab5869f06c0c5f89c14610d6

MintAndBurnAuthority(KTON): 0x540ac02d560a3ea209fdd592f54b5f49339e23a5
```