pragma solidity ^0.4.25;

contract LocalKitty {

    struct Kitty {
        uint256 genes;
        uint64  birthTime;
        uint32  matronId;
        uint32  sireId;
        uint16  generation;
    }

    Kitty[] public kitties;

    event KittyCreated(uint256 kittyId, uint256 genes);

    function createKitty(uint256 _genes) public returns (uint256) {
        Kitty memory k = Kitty({
            genes:      _genes,
            birthTime:  uint64(now),
            matronId:   0,
            sireId:     0,
            generation: 0
        });
        uint256 id = kitties.push(k) - 1;
        emit KittyCreated(id, _genes);
        return id;
    }

    function getKitty(uint256 _id) external view returns (
        bool  isGestating,
        bool  isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    ) {
        Kitty storage k = kitties[_id];
        isGestating  = false;
        isReady      = true;
        cooldownIndex = 0;
        nextActionAt  = 0;
        siringWithId  = 0;
        birthTime     = uint256(k.birthTime);
        matronId      = uint256(k.matronId);
        sireId        = uint256(k.sireId);
        generation    = uint256(k.generation);
        genes         = k.genes;
    }

    function totalSupply() public view returns (uint256) {
        return kitties.length;
    }
}
