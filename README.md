# CryptoZombies DApp — CPSC-559 Midterm

## Team Members

| Name                   | CWID      | Email                        |
|------------------------|-----------|------------------------------|
| Fardeen Kachawa        |           |                              |
| Shantanu Mitkari       |           |                              |
| John Paul Gomez-Reed   |           |                              |
| Jaiveer Kapadia        |           |                              |

---

## Improvements Made

### 1. Zombie DNA Avatar Generator
Every zombie displays a unique SVG avatar generated from its 16-digit DNA.
Head shape, eye style, eye color, shirt color, and skin tone all vary based on
DNA segments. Kitty-DNA zombies (last 2 digits = 99) render with cat ears.

### 2. Full-Featured Battle Arena
Players can select their zombie, enter an enemy ID, and fight.
The contract's 70% win-rate logic is preserved. Winning levels up the attacker
and spawns a new zombie. The UI shows a live victory/defeat result with animated feedback.

### 3. Feed on Kitty (Local KittyContract)
A local `LocalKitty.sol` contract is deployed alongside `ZombieOwnership`.
Three kitties are pre-minted at migration time. The Feed tab shows
each kitty with a generated avatar and lets players feed their zombie,
mutating its DNA (last 2 digits become 99) and spawning a new kitty-zombie.

### 4. Zombie Army Gallery with Explorer
The My Army tab shows all owned zombies with level, win/loss stats,
cooldown status, and Level Up button. The Explore tab scans the entire
chain and shows every zombie ever minted, searchable by name or DNA.

### 5. Transfer, Approve & Owner Lookup
Full ERC-721 transfer flow: direct `transferFrom`, `approve` for delegated
transfer, and `ownerOf` lookup — all in a dedicated Transfer tab with
address validation and transaction feedback.

### 6. Sepolia Testnet Support
`truffle-config.js` includes a `sepolia` network configuration.
Set `MNEMONIC` and `SEPOLIA_RPC_URL` in `.env` and run:
```
truffle migrate --reset --network sepolia
```

---

## Tech Stack

| Layer           | Technology                          |
|-----------------|-------------------------------------|
| Blockchain      | Ethereum (Ganache local dev)        |
| Smart Contracts | Solidity 0.4.25                     |
| Dev Framework   | Truffle 5.x                         |
| Local Chain     | Ganache 7.x (Docker)                |
| Kitty Contract  | LocalKitty.sol (custom, local)      |
| Frontend        | HTML5 + Vanilla JS + Web3.js 1.7.5  |
| Wallet          | MetaMask                            |
| Infrastructure  | Docker + Docker Compose             |

---

## Quick Start
```bash
# 1. Start Ganache
docker compose up -d ganache

# 2. Deploy contracts (inside Docker)
docker compose run --rm truffle truffle migrate --reset --network development

# 3. Start frontend
docker compose up -d frontend

# 4. Open http://localhost:3000
```

## MetaMask Setup

- **Network Name**: Ganache Local
- **RPC URL**: `http://127.0.0.1:8545`
- **Chain ID**: `1337`
- **Currency**: ETH

Import a private key from: `docker compose logs ganache` (copy any key from the Private Keys section, strip the `0x` prefix if rejected).

---

## Project Structure
```
├── contracts/
│   ├── LocalKitty.sol        ← NEW: local kitty contract for feed functionality
│   ├── ZombieOwnership.sol   ← top-level contract (ERC-721)
│   ├── ZombieAttack.sol
│   ├── ZombieHelper.sol
│   ├── ZombieFeeding.sol
│   ├── ZombieFactory.sol
│   ├── ownable.sol
│   ├── safemath.sol
│   └── erc721.sol
├── migrations/
│   ├── 1_initial_migration.js
│   └── 2_deploy_contracts.js  ← deploys both ZombieOwnership + LocalKitty
├── index.html                 ← full rewrite: 6-tab UI with DNA avatars
├── truffle-config.js          ← Ganache + Sepolia configs
├── docker-compose.yml
├── Dockerfile.ganache
├── Dockerfile.frontend
└── README.md
```
