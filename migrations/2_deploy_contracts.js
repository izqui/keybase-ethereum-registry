module.exports = function(deployer) {
  deployer.deploy(BytesHelper);
  deployer.link(BytesHelper, KeybaseRegistry);
  deployer.deploy(KeybaseRegistry, '_dev', true, true);
};
