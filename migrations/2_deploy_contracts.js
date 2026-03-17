var ZombieBattle = artifacts.require("./ZombieBattle.sol");
var LocalKitty   = artifacts.require("./LocalKitty.sol");

module.exports = async function(deployer) {
  await deployer.deploy(LocalKitty);
  const kitty = await LocalKitty.deployed();

  await deployer.deploy(ZombieBattle);
  const battle = await ZombieBattle.deployed();

  await battle.setKittyContractAddress(kitty.address);

  await kitty.createKitty("243234500124345");
  await kitty.createKitty("124356789012345");
  await kitty.createKitty("987654321098765");

  console.log("ZombieBattle: ", battle.address);
  console.log("LocalKitty:   ", kitty.address);
};
