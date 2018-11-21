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

DividendPoolProxy: 0x66f81b6126a45f46aa5be3d2e2167698130b692c
DividendPool: 0x738d988d2c3f5c0792d96b77e7c5077ab7da0376
DividendPool_V2: 0xf405da23e060204df9b1f2c71a8c4fcd79145930

FrozenDividendProxy: 0xd2311e7b1f1df0f177d4b2b1134e91d16fce024f
FrozenDividend: 0xdbcfd1cf5a4bb785ab5869f06c0c5f89c14610d6
FrozenDividend_V2: 0x07af3af7b6888532cd5e005e149361755a7422b7

MintAndBurnAuthority(KTON): 0x540ac02d560a3ea209fdd592f54b5f49339e23a5

UserRolesProxy: 0x449fee4453b7bd71d67b707dab489b02a764d1b3
UserRoles: 0x96f2d19bac6c5e62042ba2b5227203eeb615539a

RolesUpdater: 0x7550f7dceaa0b4ccda34ae84a303ab274523e65a
UserRolesAuthority: 0x0ca587a904bbc7fa511c7ffbc310ffef27460d65

RedBag: 0xc8f3da7f80423f7f2df7f8479f4300119af9517d

```