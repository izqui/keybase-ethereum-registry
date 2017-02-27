const BytesHelper = artifacts.require('BytesHelper.sol')
const KeybaseRegistry = artifacts.require('KeybaseRegistry.sol')
const KeybaseResolver = artifacts.require('KeybaseResolver.sol')

module.exports = function(deployer) {
  deployer.deploy(BytesHelper);
  deployer.link(BytesHelper, [KeybaseRegistry, KeybaseResolver]);
  deployer.deploy(KeybaseRegistry, '_ropsten', false);
  deployer.deploy(KeybaseResolver, '0x1234', '_ropsten', false);
};
