# Keybase <> Ethereum Registry

Mapping Keybase identities with Ethereum addresses in a secure, cryptographically verifiable manner.

A project by [Aragon](https://aragon.one) to provide Ethereum identity.

Ropsten (deployed Feb 27th, 2017): ['0x18feabc5f9437676143df8e925554eb4fdb55a91'](https://testnet.etherscan.io/address/0x18feabc5f9437676143df8e925554eb4fdb55a91)

Read the original [article](https://medium.com/@izqui9/ethereum-keybase-registry-proposal-c6497e3b2af7)

## API

ENS compliance is being worked on.

For now API for the registry is:

### Getting information

To get data regarding a registry, these three constant functions can be used:

* `getAddress(string username) returns (address)`: Lookup for an address given a username.
* `getUsername(address ethAddress) returns (string username)`: Reverse lookup of username for a given address
* `myUsername() returns (string username)`: Reverse lookup for sender

### Registering

Both funcions are payable and if registry doesn't have funds, it will need some to pay for Oraclize costs.

* `register(string username, address ethAddress)`: Starts registration for the provided address and username.
* `registerSender(string username)`: Starts registration for tx sender for the provided username.

### Fallback

Anyone can send ether to the contract to pay for verification costs on behalf of the users of the contract.

There is no suicide call nor any way the contract will send ether to anyone that is not Oraclize. Be sure that if you donate, funds will only be used for verifying records in the registry.

## Gas & costs

These are the gas costs I'm experiencing:

* Create register request: [**230k** gas](https://testnet.etherscan.io/tx/0x0919a674902e89ff7acb510431f432cff6854685778613c0991b97a89098d97d) + $0.01 USD in Ether for Oraclize + 1M gas for callback transaction

* Successfully verify and create registry (performs ecrecover and bytes black magic): [**480k** gas](https://testnet.etherscan.io/tx/0x10b4cab44afdaa066341db89c7b45fb1b50b377e992ceaab02233ec6b67bcbb8)

* Failed verify: Will **throw** and eat all gas :(

Note: See that we are paying for 1M gas to Oraclize and the transaction is only using 480k gas based on my testing, will keep it on 1M on testnet to see the variance among different users, and will settle to a less wasteful value.
