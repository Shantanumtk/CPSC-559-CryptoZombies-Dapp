# CryptoZombies DApp (Dockerized Local Blockchain)

A fully dockerized CryptoZombies decentralized application running on a local Ethereum blockchain using Ganache, Truffle, and a simple Web3 frontend.

This project demonstrates the complete lifecycle of a smart contract application: contract development, deployment, and interaction through a browser-based UI connected with MetaMask.

The setup is containerized so the entire environment can be reproduced easily.

---

# Architecture Overview

Frontend (HTML + Web3.js)
        |
        | Web3 RPC
        v
MetaMask Wallet
        |
        | RPC Calls
        v
Ganache Local Ethereum Blockchain (Docker)
        |
        v
Smart Contracts (Solidity)
        |
        v
Deployment using Truffle (Docker)

---

# Tech Stack

Blockchain
Ethereum (Local Development Network)

Smart Contracts
Solidity

Blockchain Tools
Ganache CLI
Truffle

Frontend
HTML
JavaScript
Web3.js
jQuery

Containerization
Docker
Docker Compose

Wallet
MetaMask

---

# Project Structure

Cryptozombie-demo-package/

contracts/
    Migrations.sol
    ZombieFactory.sol
    ZombieFeeding.sol
    ZombieHelper.sol
    ZombieAttack.sol
    ZombieOwnership.sol

migrations/
    1_initial_migration.js
    2_deploy_contracts.js

build/
    contracts/
        ZombieOwnership.json

frontend/
    index.html

Dockerfile.truffle
Dockerfile.frontend
docker-compose.yml
truffle-config.js
README.md

---

# Prerequisites

Before running this project make sure the following tools are installed.

Docker
Docker Compose
MetaMask Browser Extension
Google Chrome or Firefox

---

# Running the Project

Follow these steps to start the full environment.

Step 1 Start the local Ethereum blockchain

docker compose up -d ganache

This starts a Ganache container which acts as the local Ethereum blockchain.

Ganache will expose RPC endpoint on port 8545.

---

Step 2 Deploy smart contracts

docker compose run --rm truffle truffle migrate --reset --network development

This will:

compile the Solidity contracts
deploy them to the local blockchain
generate contract artifacts in build/contracts

---

Step 3 Start the frontend

docker compose up -d frontend

The UI will be available at:

http://localhost:3000

---

# Viewing Ganache Accounts

Ganache automatically generates accounts for testing.

To view them run:

docker compose logs ganache

You will see something like:

Available Accounts

(0) 0xabc...
(1) 0xdef...
...

Private Keys

(0) xxxxxxxxx
(1) xxxxxxxxx

These private keys can be imported into MetaMask.

---

# Connecting MetaMask with Ganache

Follow these steps to connect your wallet to the local blockchain.

Step 1 Open MetaMask

Click the MetaMask icon in your browser.

---

Step 2 Import Ganache account

Click account icon

Select

Import Account

Select

Private Key

Copy a private key from the Ganache container logs and paste it.

Example

docker compose logs ganache

Copy any private key under the Private Keys section.

---

Step 3 Add Ganache network

Open MetaMask

Go to

Settings
Networks
Add Network
Add manually

Use the following values

Network Name: Ganache Local
RPC URL: http://127.0.0.1:8545
Chain ID: 1337
Currency Symbol: ETH

Save the network.

---

Step 4 Switch MetaMask network

Switch your MetaMask network to

Ganache Local

The imported account should now show a balance of 1000 ETH (test ETH).

---

# Using the Application

Open the frontend

http://localhost:3000

MetaMask will prompt you to connect.

Approve the connection.

You can now:

Create Zombie
Show Zombies
Level Up Zombie

Each action sends a transaction to the local Ethereum blockchain.

---

# Redeploying Contracts

If you want to redeploy contracts from scratch run

docker compose run --rm truffle truffle migrate --reset --network development

This redeploys the smart contracts to the Ganache blockchain.

---

# Resetting the Blockchain

To completely reset the blockchain run

docker compose down -v

This removes containers and Ganache data.

Then restart the system:

docker compose up -d ganache
docker compose run --rm truffle truffle migrate --reset --network development
docker compose up -d frontend

Note

Ganache will generate new private keys after reset.

You must re-import the keys in MetaMask.

---

# Troubleshooting

MetaMask cannot connect

Make sure Ganache container is running

docker compose ps

RPC endpoint must be

http://127.0.0.1:8545

---

Cannot import private key

Remove the 0x prefix from the key if MetaMask rejects it.

---

Transactions failing

Ensure MetaMask is connected to the Ganache Local network and not Ethereum Mainnet.

---

Frontend not updating

Hard refresh the browser

CMD + SHIFT + R

---

# Future Improvements

Add React frontend
Integrate Hardhat instead of Truffle
Deploy to Sepolia testnet
Add NFT metadata and visualization
Add IPFS storage

---

# Learning Goals

Understand Ethereum smart contract development
Learn local blockchain testing using Ganache
Interact with smart contracts using Web3.js
Understand wallet integration with MetaMask
Learn containerized blockchain development environments

---

# License

MIT License