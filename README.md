# CryptoZombies DApp — Dockerized Local Blockchain

A fully containerized CryptoZombies decentralized application running on a local Ethereum blockchain using Ganache, Truffle, and a Web3.js frontend.

Create, battle, and level up zombies — entirely on a local chain, reproducible with `docker compose up`.

---

## Architecture

```
Frontend (HTML + Web3.js)    →    MetaMask Wallet    →    Ganache (Local Ethereum)
     localhost:3000                Browser Extension           localhost:8545
                                                                    │
                                                          Smart Contracts (Solidity)
                                                          Deployed via Truffle
```

---

## Tech Stack

| Layer            | Technology                            |
|------------------|---------------------------------------|
| Blockchain       | Ethereum (Local Dev Network)          |
| Smart Contracts  | Solidity                              |
| Dev Framework    | Truffle                               |
| Local Chain      | Ganache CLI                           |
| Frontend         | HTML, JavaScript, Web3.js, jQuery     |
| Wallet           | MetaMask                              |
| Infrastructure   | Docker, Docker Compose                |

---

## Project Structure

```
Cryptozombie-demo-package/
├── contracts/
│   ├── Migrations.sol
│   ├── ZombieFactory.sol
│   ├── ZombieFeeding.sol
│   ├── ZombieHelper.sol
│   ├── ZombieAttack.sol
│   └── ZombieOwnership.sol
├── migrations/
│   ├── 1_initial_migration.js
│   └── 2_deploy_contracts.js
├── build/contracts/
│   └── ZombieOwnership.json
├── frontend/
│   └── index.html
├── Dockerfile.truffle
├── Dockerfile.frontend
├── docker-compose.yml
├── truffle-config.js
└── README.md
```

---

## Prerequisites

- Docker & Docker Compose
- MetaMask browser extension
- Chrome or Firefox

---

## Quick Start

**1. Start the local blockchain**

```bash
docker compose up -d ganache
```

Ganache exposes RPC at `http://localhost:8545`.

**2. Deploy contracts**

```bash
docker compose run --rm truffle truffle migrate --reset --network development
```

Compiles Solidity contracts, deploys to Ganache, outputs artifacts to `build/contracts/`.

**3. Start the frontend**

```bash
docker compose up -d frontend
```

Open `http://localhost:3000` in your browser.

---

## MetaMask Setup

### Import a Ganache Account

```bash
docker compose logs ganache
```

Copy any private key from the `Private Keys` section. In MetaMask: **Account Icon → Import Account → Private Key → Paste**.

> Remove the `0x` prefix if MetaMask rejects the key.

### Add Ganache Network

In MetaMask: **Settings → Networks → Add Network → Add Manually**

```
Network Name:    Ganache Local
RPC URL:         http://127.0.0.1:8545
Chain ID:        1337
Currency Symbol: ETH
```

Switch to **Ganache Local** — the imported account should show 1000 ETH (test ETH).

---

## Usage

1. Open `http://localhost:3000`
2. Approve the MetaMask connection prompt
3. Available actions:
   - **Create Zombie** — mint a new zombie on-chain
   - **Show Zombies** — view your zombie army
   - **Level Up Zombie** — power up a zombie

Each action sends a transaction to the local blockchain.

---

## Common Operations

**Redeploy contracts**

```bash
docker compose run --rm truffle truffle migrate --reset --network development
```

**Full reset (wipes blockchain state)**

```bash
docker compose down -v
docker compose up -d ganache
docker compose run --rm truffle truffle migrate --reset --network development
docker compose up -d frontend
```

> Ganache generates new private keys after reset — re-import them in MetaMask.

---

## Troubleshooting

| Problem                  | Fix                                                                      |
|--------------------------|--------------------------------------------------------------------------|
| MetaMask can't connect   | Check Ganache is running: `docker compose ps`. RPC must be `http://127.0.0.1:8545` |
| Private key import fails | Strip the `0x` prefix                                                    |
| Transactions failing     | Verify MetaMask is on Ganache Local, not Mainnet                         |
| Frontend stale           | Hard refresh: `Cmd+Shift+R` / `Ctrl+Shift+R`                            |
