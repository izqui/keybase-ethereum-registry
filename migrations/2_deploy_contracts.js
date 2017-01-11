module.exports = function(deployer) {
  //deployer.deploy(HelperLib);
  //deployer.autolink();
  deployer.deploy(KeybaseRegistry, '_dev', true, false);
};
