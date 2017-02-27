const BytesHelper = artifacts.require('BytesHelper.sol')
const KeybaseRegistry = artifacts.require('KeybaseRegistry.sol')

module.exports = function(deployer) {
  deployer.deploy(BytesHelper);
  deployer.link(BytesHelper, KeybaseRegistry);
  deployer.deploy(KeybaseRegistry, '_ropsten', true, true);
};
