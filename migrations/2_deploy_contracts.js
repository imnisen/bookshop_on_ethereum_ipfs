var Bookshop = artifacts.require("./Bookshop.sol");

module.exports = function(deployer) {
  deployer.deploy(Bookshop);
};
