pragma solidity ^0.4.25;

import "./ZombieMarketplace.sol";
import "./ZombieCoin.sol";

contract ZombieBattle is ZombieMarketplace, ZombieCoin {

    event BattleResult(
        uint256 indexed attackerId,
        uint256 indexed targetId,
        address winner,
        address loser,
        uint256 betAmount,
        uint256 bonusAmount,
        bool    attackerWon
    );

    function attackWithBet(
        uint256 _zombieId,
        uint256 _targetId,
        uint256 _betAmount
    ) external onlyOwnerOf(_zombieId) {
        require(_betAmount >= MIN_BET,              "Minimum bet is 100 ZMB");
        require(zombieCoins[msg.sender] >= _betAmount, "Insufficient ZMB — buy more coins");

        Zombie storage myZombie     = zombies[_zombieId];
        Zombie storage enemyZombie  = zombies[_targetId];
        address enemyOwner          = zombieToOwner[_targetId];

        require(_isReady(myZombie), "Zombie is on cooldown");

        // Lock attacker coins
        zombieCoins[msg.sender] = zombieCoins[msg.sender].sub(_betAmount);

        // Battle logic (same 70% win rate)
        uint256 rand = _randMod(100);
        bool attackerWon = rand < 70;

        if (attackerWon) {
            // Attacker wins: gets bet back + enemy's equivalent + bonus
            myZombie.winCount   = myZombie.winCount.add(1);
            myZombie.level      = myZombie.level.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);

            uint256 reward = _betAmount.add(WIN_BONUS);
            // Take bet from enemy if they have enough, else just give bonus
            if (zombieCoins[enemyOwner] >= _betAmount) {
                zombieCoins[enemyOwner] = zombieCoins[enemyOwner].sub(_betAmount);
                reward = _betAmount.add(_betAmount).add(WIN_BONUS);
            }
            zombieCoins[msg.sender] = zombieCoins[msg.sender].add(reward);
            totalSupply = totalSupply.add(WIN_BONUS);

            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");

            emit BattleResult(_zombieId, _targetId, msg.sender, enemyOwner, _betAmount, WIN_BONUS, true);
        } else {
            // Attacker loses: enemy gets the bet
            myZombie.lossCount    = myZombie.lossCount.add(1);
            enemyZombie.winCount  = enemyZombie.winCount.add(1);
            _triggerCooldown(myZombie);

            zombieCoins[enemyOwner] = zombieCoins[enemyOwner].add(_betAmount);

            emit BattleResult(_zombieId, _targetId, enemyOwner, msg.sender, _betAmount, 0, false);
        }
    }

    function _randMod(uint256 _modulus) internal returns (uint256) {
        randNonce = randNonce.add(1);
        return uint256(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
    }
}
