pragma solidity ^0.4.25;

import "./safemath.sol";

contract ZombieCoin {
    using SafeMath for uint256;

    string  public name     = "ZombieCoin";
    string  public symbol   = "ZMB";
    uint8   public decimals = 0;
    uint256 public totalSupply;

    uint256 public constant COINS_PER_ETH    = 10000; // 0.01 ETH = 100 ZMB
    uint256 public constant STARTER_AMOUNT   = 500;
    uint256 public constant MIN_BET          = 100;
    uint256 public constant WIN_BONUS        = 100;
    uint256 public constant ETH_PER_PURCHASE = 0.01 ether;
    uint256 public constant COINS_PER_PURCHASE = 100;

    mapping(address => uint256) public zombieCoins;
    mapping(address => bool)    public claimedStarter;

    event CoinsMinted(address indexed to, uint256 amount);
    event CoinsTransferred(address indexed from, address indexed to, uint256 amount);
    event StarterClaimed(address indexed player, uint256 amount);
    event CoinsPurchased(address indexed player, uint256 ethSpent, uint256 coinsReceived);

    function _mintCoins(address _to, uint256 _amount) internal {
        zombieCoins[_to] = zombieCoins[_to].add(_amount);
        totalSupply       = totalSupply.add(_amount);
        emit CoinsMinted(_to, _amount);
    }

    function _transferCoins(address _from, address _to, uint256 _amount) internal {
        require(zombieCoins[_from] >= _amount, "Insufficient ZMB");
        zombieCoins[_from] = zombieCoins[_from].sub(_amount);
        zombieCoins[_to]   = zombieCoins[_to].add(_amount);
        emit CoinsTransferred(_from, _to, _amount);
    }

    function claimStarterCoins() public {
        require(!claimedStarter[msg.sender], "Already claimed starter coins");
        claimedStarter[msg.sender] = true;
        _mintCoins(msg.sender, STARTER_AMOUNT);
        emit StarterClaimed(msg.sender, STARTER_AMOUNT);
    }

    function buyCoins() public payable {
        require(msg.value >= ETH_PER_PURCHASE, "Send at least 0.01 ETH");
        uint256 purchases = msg.value / ETH_PER_PURCHASE;
        uint256 coins     = purchases.mul(COINS_PER_PURCHASE);
        uint256 refund    = msg.value - purchases.mul(ETH_PER_PURCHASE);
        _mintCoins(msg.sender, coins);
        if (refund > 0) msg.sender.transfer(refund);
        emit CoinsPurchased(msg.sender, msg.value - refund, coins);
    }

    function getZombieCoins(address _player) public view returns (uint256) {
        return zombieCoins[_player];
    }

    function hasClaimedStarter(address _player) public view returns (bool) {
        return claimedStarter[_player];
    }
}
