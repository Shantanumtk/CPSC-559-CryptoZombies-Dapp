var ZombieOwnership = artifacts.require("./zombieownership.sol");

module.exports = function(deployer) {
  deployer.deploy(ZombieOwnership);
};