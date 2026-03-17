pragma solidity ^0.4.25;

import "./zombieownership.sol";

contract ZombieMarketplace is ZombieOwnership {

    struct Listing {
        uint256 zombieId;
        address seller;
        uint256 price;
        bool    active;
    }

    Listing[] public listings;
    mapping(uint256 => uint256) public zombieToListing;
    mapping(uint256 => bool)    public zombieIsListed;

    event ZombieListed(uint256 indexed zombieId, address indexed seller, uint256 price);
    event ZombieSold(uint256 indexed zombieId, address indexed buyer, uint256 price);
    event ZombieDelisted(uint256 indexed zombieId);

    function listZombie(uint256 _zombieId, uint256 _price) external onlyOwnerOf(_zombieId) {
        require(_price > 0, "Price must be > 0");
        require(!zombieIsListed[_zombieId], "Already listed");

        uint256 listingId = listings.push(Listing({
            zombieId: _zombieId,
            seller:   msg.sender,
            price:    _price,
            active:   true
        })) - 1;

        zombieToListing[_zombieId] = listingId;
        zombieIsListed[_zombieId]  = true;

        emit ZombieListed(_zombieId, msg.sender, _price);
    }

    function buyZombie(uint256 _zombieId) external payable {
        require(zombieIsListed[_zombieId], "Not listed");
        uint256 listingId = zombieToListing[_zombieId];
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        require(msg.sender != listing.seller, "Cannot buy your own zombie");
        require(msg.value >= listing.price, "Insufficient ETH");

        listing.active = false;
        zombieIsListed[_zombieId] = false;

        address seller = listing.seller;
        _transfer(seller, msg.sender, _zombieId);
        seller.transfer(listing.price);

        if (msg.value > listing.price) {
            msg.sender.transfer(msg.value - listing.price);
        }

        emit ZombieSold(_zombieId, msg.sender, listing.price);
    }

    function delistZombie(uint256 _zombieId) external onlyOwnerOf(_zombieId) {
        require(zombieIsListed[_zombieId], "Not listed");
        uint256 listingId = zombieToListing[_zombieId];
        listings[listingId].active = false;
        zombieIsListed[_zombieId]  = false;
        emit ZombieDelisted(_zombieId);
    }

    function getActiveListings() external view returns (uint256[]) {
        uint256 count = 0;
        for (uint256 i = 0; i < listings.length; i++) {
            if (listings[i].active) count++;
        }
        uint256[] memory result = new uint256[](count);
        uint256 idx = 0;
        for (uint256 j = 0; j < listings.length; j++) {
            if (listings[j].active) result[idx++] = j;
        }
        return result;
    }

    function getListingCount() external view returns (uint256) {
        return listings.length;
    }
}
