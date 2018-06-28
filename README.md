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
