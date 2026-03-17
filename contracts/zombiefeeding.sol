pragma solidity ^0.4.25;

import "./zombiefactory.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  KittyInterface kittyContract;

  modifier onlyOwnerOf(uint _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    _;
  }

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    return (_zombie.readyTime <= now);
  }

  function _generateSpawnName(uint _dna) internal pure returns (string) {
    bytes32[8] memory parts;
    parts[0] = "Shadow"; parts[1] = "Blood";  parts[2] = "Grave";
    parts[3] = "Skull";  parts[4] = "Toxic";  parts[5] = "Venom";
    parts[6] = "Rotten"; parts[7] = "Death";

    bytes32[8] memory endings;
    endings[0] = "Walker"; endings[1] = "Ripper"; endings[2] = "Gnawer";
    endings[3] = "Feeder"; endings[4] = "Biter";  endings[5] = "Lurker";
    endings[6] = "Mauler"; endings[7] = "Ravager";

    uint pi = (_dna / 1000000000000) % 8;
    uint si = (_dna / 100000000000)  % 8;

    bytes memory pa = _b32ToBytes(parts[pi]);
    bytes memory sa = _b32ToBytes(endings[si]);
    bytes memory result = new bytes(pa.length + 1 + sa.length);
    uint k = 0;
    for (uint i = 0; i < pa.length; i++) result[k++] = pa[i];
    result[k++] = " ";
    for (uint j = 0; j < sa.length; j++) result[k++] = sa[j];
    return string(result);
  }

  function _b32ToBytes(bytes32 _b) internal pure returns (bytes) {
    bytes memory tmp = new bytes(32);
    uint len = 0;
    for (uint i = 0; i < 32; i++) {
      if (_b[i] == 0) break;
      tmp[len++] = _b[i];
    }
    bytes memory out = new bytes(len);
    for (uint j = 0; j < len; j++) out[j] = tmp[j];
    return out;
  }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal onlyOwnerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    string memory spawnName = _generateSpawnName(newDna);
    _createZombie(spawnName, newDna);
    _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
