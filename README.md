# Keybase <> Ethereum Registry

Read the [article](https://medium.com/@izqui9/ethereum-keybase-registry-proposal-c6497e3b2af7)

Mainnet address: [0x390A6AB0684073ae6caBe6c390A43e87B117Ed0A](https://etherscan.io/address/0x390a6ab0684073ae6cabe6c390a43e87b117ed0a#readContract)

### JSON Interface 

```
[ { "constant": false, "inputs": [ { "name": "myid", "type": "bytes32" }, { "name": "result", "type": "string" } ], "name": "__callback", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "myUsername", "outputs": [ { "name": "", "type": "string", "value": "ji" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "u", "type": "string" } ], "name": "getAddress", "outputs": [ { "name": "", "type": "address", "value": "0x0000000000000000000000000000000000000000" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "a", "type": "address" } ], "name": "getUsername", "outputs": [ { "name": "", "type": "string", "value": "" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "username", "type": "string" } ], "name": "keybasePubURL", "outputs": [ { "name": "", "type": "string", "value": "https://.keybase.pub/eth" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "username", "type": "string" } ], "name": "claim", "outputs": [], "payable": true, "type": "function" }, { "payable": false, "type": "fallback" } ]
```

