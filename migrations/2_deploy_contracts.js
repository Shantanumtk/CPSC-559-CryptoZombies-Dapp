var ZombieOwnership = artifacts.require("./zombieownership.sol");
var LocalKitty      = artifacts.require("./LocalKitty.sol");

module.exports = async function(deployer) {
  await deployer.deploy(LocalKitty);
  const kitty = await LocalKitty.deployed();

  await deployer.deploy(ZombieOwnership);
  const zombie = await ZombieOwnership.deployed();

  // Wire the kitty contract address into ZombieOwnership
  await zombie.setKittyContractAddress(kitty.address);

  // Pre-mint 3 kitties so the frontend can immediately feed on them
  await kitty.createKitty("243234500124345");
  await kitty.createKitty("124356789012345");
  await kitty.createKitty("987654321098765");

  console.log("ZombieOwnership:", zombie.address);
  console.log("LocalKitty:     ", kitty.address);
};
