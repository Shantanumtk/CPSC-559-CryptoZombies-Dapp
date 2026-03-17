pragma solidity ^0.4.25;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  // Name parts stored as bytes32 for gas efficiency
  bytes32[10] private prefixes;
  bytes32[10] private suffixes;

  constructor() public {
    prefixes[0] = "Death";   prefixes[1] = "Shadow";  prefixes[2] = "Blood";
    prefixes[3] = "Grave";   prefixes[4] = "Skull";   prefixes[5] = "Bone";
    prefixes[6] = "Toxic";   prefixes[7] = "Venom";   prefixes[8] = "Dark";
    prefixes[9] = "Rotten";

    suffixes[0] = "Walker";  suffixes[1] = "Crusher"; suffixes[2] = "Stalker";
    suffixes[3] = "Feeder";  suffixes[4] = "Gnawer";  suffixes[5] = "Ripper";
    suffixes[6] = "Lurker";  suffixes[7] = "Biter";   suffixes[8] = "Mauler";
    suffixes[9] = "Ravager";
  }

  function _generateZombieName(uint _dna) internal view returns (string) {
    uint prefixIdx = (_dna / 1000000000000) % 10;
    uint suffixIdx = (_dna / 100000000000)  % 10;
    string memory prefix = _bytes32ToString(prefixes[prefixIdx]);
    string memory suffix = _bytes32ToString(suffixes[suffixIdx]);
    return _concat(prefix, suffix);
  }

  function _bytes32ToString(bytes32 _b) internal pure returns (string) {
    bytes memory result = new bytes(32);
    uint len = 0;
    for (uint i = 0; i < 32; i++) {
      if (_b[i] == 0) break;
      result[len++] = _b[i];
    }
    bytes memory trimmed = new bytes(len);
    for (uint j = 0; j < len; j++) trimmed[j] = result[j];
    return string(trimmed);
  }

  function _concat(string memory _a, string memory _b) internal pure returns (string) {
    bytes memory ba = bytes(_a);
    bytes memory bb = bytes(_b);
    bytes memory bc = new bytes(ba.length + 1 + bb.length);
    uint k = 0;
    for (uint i = 0; i < ba.length; i++) bc[k++] = ba[i];
    bc[k++] = " ";
    for (uint j = 0; j < bb.length; j++) bc[k++] = bb[j];
    return string(bc);
  }

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    address _owner = owner();
    _owner.transfer(address(this).balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level.add(1);
  }

  function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
}
