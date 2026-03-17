# CryptoZombies DApp — CPSC-559 Midterm

## Team Members

| Name                 | CWID | Email |
|----------------------|------|-------|
| Fardeen Kachawa      |      |       |
| Shantanu Mitkari     |      |       |
| John Paul Gomez-Reed |      |       |
| Jaiveer Kapadia      |      |       |

---

## Project Overview

A fully containerized CryptoZombies decentralized application running on a local Ethereum blockchain. Players create, battle, breed, and trade zombies as NFTs on a local Ganache chain. Features a custom ERC-20 token (ZombieCoin) for betting, a full NFT marketplace, leaderboard, graveyard, and DNA-based SVG avatar generation.

---

## Tech Stack

| Layer            | Technology                          |
|------------------|-------------------------------------|
| Blockchain       | Ethereum (Ganache local dev)        |
| Smart Contracts  | Solidity 0.4.25                     |
| Dev Framework    | Truffle 5.x                         |
| Local Chain      | Ganache 7.x (Docker)                |
| Token Standard   | ERC-20 (ZombieCoin)                 |
| NFT Standard     | ERC-721 (ZombieOwnership)           |
| Kitty Contract   | LocalKitty.sol (custom, local)      |
| Frontend         | HTML5 + Vanilla JS + Web3.js 1.7.5  |
| Wallet           | MetaMask                            |
| Infrastructure   | Docker + Docker Compose             |

---

## Smart Contract Architecture
```
ZombieCoin.sol          ← ERC-20 token (ZMB)
    ↓
ZombieFactory.sol       ← creates zombies, DNA generation
    ↓
ZombieFeeding.sol       ← feed on kitty, breed zombies
    ↓
ZombieHelper.sol        ← level up, name/DNA change, generated names
    ↓
ZombieAttack.sol        ← battle logic (70% win rate)
    ↓
ZombieOwnership.sol     ← ERC-721 transfer, approve
    ↓
ZombieMarketplace.sol   ← list, buy, delist zombies
    ↓
ZombieBattle.sol        ← battle with ZMB betting (extends all above)
    ↓
LocalKitty.sol          ← local kitty contract (3 pre-minted kitties)
```

---

## Project Structure
```
CPSC-559-CryptoZombies-Dapp/
├── contracts/
│   ├── ZombieBattle.sol        ← main contract (betting + battle)
│   ├── ZombieMarketplace.sol   ← NFT marketplace
│   ├── ZombieCoin.sol          ← ERC-20 ZMB token
│   ├── ZombieOwnership.sol     ← ERC-721 NFT
│   ├── ZombieAttack.sol
│   ├── ZombieHelper.sol        ← name generator
│   ├── ZombieFeeding.sol
│   ├── ZombieFactory.sol
│   ├── LocalKitty.sol          ← local kitty contract
│   ├── ownable.sol
│   ├── safemath.sol
│   └── erc721.sol
├── migrations/
│   ├── 1_initial_migration.js
│   └── 2_deploy_contracts.js   ← deploys ZombieBattle + LocalKitty
├── test/
│   ├── CryptoZombies.js
│   └── helpers/
│       ├── time.js
│       └── utils.js
├── index.html                  ← full frontend (9 tabs)
├── truffle-config.js           ← Ganache + Sepolia configs
├── docker-compose.yml
├── Dockerfile.ganache
├── Dockerfile.frontend
├── Dockerfile.truffle
├── demo_setup.sh               ← one command full deploy
└── README.md
```

---

## Quick Start
```bash
# One command does everything
./demo_setup.sh
```

This script:
1. Tears down existing containers
2. Starts Ganache
3. Deploys all contracts
4. Starts frontend
5. Prints private keys + addresses ready to paste

Then open `http://localhost:3000` and hard refresh `Cmd + Shift + R`.

### Manual Deploy
```bash
# Start Ganache
docker compose up -d ganache

# Deploy contracts
docker compose run --rm truffle truffle migrate --reset --network development

# Start frontend
docker compose up -d frontend
```

---

## MetaMask Setup
```
Network Name: Ganache Local
RPC URL:      http://127.0.0.1:8545
Chain ID:     1337
Symbol:       ETH
```

Import private keys from `./demo_setup.sh` output.

---

## Smart Contract Details

### ZombieCoin (ZMB)

| Function              | Description                        |
|-----------------------|------------------------------------|
| `claimStarterCoins()` | Claim 500 free ZMB (once per addr) |
| `buyCoins()`          | Pay 0.01 ETH → get 100 ZMB         |
| `getZombieCoins(addr)`| Check ZMB balance                  |
| `hasClaimedStarter()` | Check if starter claimed           |

### ZombieBattle

| Function                          | Description                       |
|-----------------------------------|-----------------------------------|
| `createRandomZombie(name)`        | Create zombie (one per address)   |
| `attackWithBet(id, target, bet)`  | Battle with ZMB bet (min 100)     |
| `feedOnKitty(zombieId, kittyId)`  | Feed zombie on local kitty        |
| `levelUp(zombieId)`               | Level up for 0.001 ETH            |
| `listZombie(id, price)`           | List on marketplace               |
| `buyZombie(id)`                   | Buy listed zombie                 |
| `delistZombie(id)`                | Remove listing                    |
| `transferFrom(from, to, id)`      | ERC-721 transfer                  |
| `approve(addr, id)`               | Approve delegated transfer        |
| `ownerOf(id)`                     | Look up zombie owner              |

### ZombieCoin Economics
```
Starting Bonus:  500 ZMB free (one time per address)
Buy Rate:        0.01 ETH = 100 ZMB
Minimum Bet:     100 ZMB per battle
Win Reward:      opponent's bet + 100 bonus ZMB
Loss Penalty:    lose your bet to opponent
```

---

## Bug Fixes from Starter Code

| Bug | Fix |
|-----|-----|
| Port mismatch (7545 vs 8545) | Fixed to 8545 |
| `_transfer` decrementing `msg.sender` instead of `_from` | Fixed to `_from` |
| No one-zombie guard | Added `require(ownerZombieCount == 0)` |
| Inverted assert in `shouldThrow` test helper | Fixed logic |
| Deprecated `ganache-cli` | Replaced with `ganache` |
| Spawned zombies named "NoName" | Auto-generated scary names |

---

## Improvements Made

1. DNA-based SVG zombie avatar generator
2. ZombieCoin ERC-20 betting system
3. NFT Marketplace (list, buy, delist)
4. Local KittyContract (feed on kitty)
5. Global Leaderboard (players + zombies)
6. Zombie Graveyard (transferred zombies)
7. Chain Explorer (all zombies)
8. Battle animations + win/loss screen
9. Clickable zombie detail modal
10. Sticky navbar with live ZMB balance
11. Win rate % display per zombie
12. Sepolia testnet config
13. Single command demo setup script

---

## Testnet Deployment (Sepolia)

Add to `.env`:
```
MNEMONIC=your twelve word phrase
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
```

Then:
```bash
truffle migrate --reset --network sepolia
```

---

## References

- CryptoZombies lessons: https://cryptozombies.io
- Zombie factory GitHub: https://github.com/loomnetwork/cryptozombies-lesson-code
- OpenZeppelin contracts: https://openzeppelin.com/contracts
- Web3.js docs: https://web3js.readthedocs.io
