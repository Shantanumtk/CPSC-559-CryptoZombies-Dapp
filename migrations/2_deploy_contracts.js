var ZombieMarketplace = artifacts.require("./ZombieMarketplace.sol");
var LocalKitty        = artifacts.require("./LocalKitty.sol");

module.exports = async function(deployer) {
  await deployer.deploy(LocalKitty);
  const kitty = await LocalKitty.deployed();

  await deployer.deploy(ZombieMarketplace);
  const market = await ZombieMarketplace.deployed();

  await market.setKittyContractAddress(kitty.address);

  await kitty.createKitty("243234500124345");
  await kitty.createKitty("124356789012345");
  await kitty.createKitty("987654321098765");

  console.log("ZombieMarketplace:", market.address);
  console.log("LocalKitty:       ", kitty.address);
};
