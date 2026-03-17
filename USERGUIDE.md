# CryptoZombies DApp — User Guide

## Getting Started

### Step 1 — Start the DApp
```bash
./demo_setup.sh
```
Wait for it to finish. It will print your private keys and addresses.

### Step 2 — Setup MetaMask
1. Open MetaMask in your browser
2. Click Networks → Add Network → Add Manually
3. Enter:
```
   Network Name: Ganache Local
   RPC URL:      http://127.0.0.1:8545
   Chain ID:     1337
   Symbol:       ETH
```
4. Click Save → Switch to Ganache Local

### Step 3 — Import Accounts
1. MetaMask → Account icon → Import Account
2. Paste **Account A** private key from the script output
3. Repeat for **Account B** and **Account C**
4. Each account shows **1000 ETH**

### Step 4 — Open the DApp
```
http://localhost:3000
```
Press `Cmd + Shift + R` to hard refresh.

---

## Features Guide

---

### 🪙 ZombieCoin (ZMB) — Always visible in navbar

ZombieCoin is the in-game currency used for battle betting.

**Claim Free Coins:**
1. Click **🪙 ZMB** in top navbar
2. Click **Claim Starter** → get 500 ZMB free
3. Do this for each account (A, B, C)

**Buy More Coins:**
1. Click **🪙 ZMB** in navbar
2. Click **Buy ZMB** → costs 0.01 ETH per 100 ZMB
3. Approve MetaMask popup
4. Balance updates instantly in navbar

**ZMB Economics:**
```
Starter Bonus:  500 ZMB free (once per account)
Buy Rate:       0.01 ETH = 100 ZMB
Minimum Bet:    100 ZMB per battle
Win:            get opponent's bet + 100 bonus ZMB
Loss:           lose your bet
```

---

### ➕ Create Zombie

Each account can create **one free zombie**.

1. Switch MetaMask to **Account A**
2. Click **Create** tab
3. Type a name (e.g. `DeathClaw X9`)
4. Watch the **live preview avatar** appear as you type
5. Click **Create Zombie** → approve MetaMask
6. Wait for confirmation → zombie appears in My Army
7. Repeat for **Account B** and **Account C**

> **Note:** Each address can only create one zombie for free. Win battles to spawn more!

---

### ⚔️ My Army

View and manage all your zombies.

**My Zombies:**
- Click **My Army** tab → **Refresh**
- Shows all zombies you own with:
  - Unique DNA avatar
  - Level + cooldown status
  - Win/Loss stats + Win Rate %
  - Level Up and Battle buttons

**All Zombies:**
- Click **All Zombies** button
- See every zombie across all accounts

**Search:**
- Type in search bar to filter by name, DNA, or level

**Click any zombie card:**
- Opens a detail popup with full stats
- DNA breakdown by segment
- Quick action buttons (Battle, Level Up, Sell, Transfer)

---

### 🥊 Battle Arena

Battle your zombie against others and bet ZMB.

1. Click **Battle** tab
2. Select **your zombie** from left dropdown
3. Enter **enemy zombie ID** in right field
4. Both zombie avatars preview on screen
5. Set your **bet amount** (minimum 100 ZMB)
   - Quick buttons: 100 / 250 / 500 / ALL IN
6. Click **⚔️ ATTACK!** → approve MetaMask

**Result:**
- **Win (70% chance):** Victory screen + ZMB earned + new zombie spawned
- **Loss (30% chance):** Defeat screen + ZMB lost to opponent
- Navbar ZMB balance updates instantly

**Not enough ZMB?**
- Auto-buy prompt appears
- Click **Buy & Battle** → buys 100 ZMB and battles automatically

**Cooldown:**
- After battle → 10 second cooldown before next attack
- Card shows ⏳ Cooldown status

---

### 🐱 Feed on Kitty

Feed your zombie on a CryptoKitty to mutate its DNA.

1. Click **Feed on Kitty** tab
2. Select **your zombie** from dropdown
3. Click on one of the **3 pre-minted kitties** shown
4. Click **🐱 Feed!** → approve MetaMask
5. New zombie spawns with:
   - **Cat ears** in avatar
   - **✦ Kitty DNA** badge
   - Last 2 DNA digits = 99

> Zombie must not be on cooldown to feed.

---

### 🏪 NFT Marketplace

Buy and sell zombies using ETH.

**List a Zombie for Sale:**
1. Click **Market** tab
2. Select your zombie from **List Your Zombie** section
3. Enter price in ETH (e.g. `0.05`)
4. Click **🏷️ List for Sale** → approve MetaMask
5. Zombie appears in **Active Listings**

**Buy a Zombie:**
1. Browse **Active Listings**
2. Click **💰 Buy Now** on any listing
3. Approve MetaMask → zombie transfers to you
4. Check **My Army** to see your new zombie

**Delist a Zombie:**
1. Enter zombie ID in **Delist** section
2. Click **Remove Listing** → approve MetaMask

> You cannot buy your own zombie.

---

### ↔️ Transfer

Send zombies between accounts or approve others to transfer.

**Direct Transfer:**
1. Click **Transfer** tab
2. Enter **Zombie ID**
3. Enter **recipient address** (copy from demo_setup.sh output)
4. Click **Transfer** → approve MetaMask
5. Switch to recipient account → check My Army

**Approve Transfer (ERC-721 flow):**
1. Enter **Zombie ID** and **approved address**
2. Click **Approve** → MetaMask popup
3. Switch to approved account
4. Use Transfer section to complete the transfer
   - This is how NFT marketplaces work (OpenSea style)

**Owner Lookup:**
1. Enter any **Zombie ID**
2. Click **Look Up**
3. See the owner's address

---

### 🏆 Leaderboard

See global rankings across all players and zombies.

1. Click **Ranks** tab
2. Auto-loads all player and zombie data

**Players Tab:**
- Ranked by total wins
- Shows: Zombies owned, Wins, Losses, Win Rate bar, Max Level
- **YOU** badge highlights your account
- Gold/Silver/Bronze medals for top 3

**Zombies Tab:**
- Ranked by wins then level
- Shows zombie avatar, owner, stats
- **MINE** badge on your zombies

Click **↻ Refresh** to get latest data.

---

### 💀 Graveyard

See zombies that left your wallet.

1. Click **Graveyard** tab
2. Shows zombies you previously owned but transferred away
3. Displayed in greyscale with **RIP** badge
4. Shows last known level and new owner address

> Transfer a zombie to another account first, then check the graveyard to see it there.

---

### 🌍 Explorer

See every zombie ever minted on the blockchain.

1. Click **Explore** tab
2. Click **↻ Load All**
3. All zombies from all accounts appear
4. Search by name or DNA
5. Click any zombie to see full details

---

### ⬆️ Level Up

Increase your zombie's level for 0.001 ETH.

1. Go to **My Army**
2. Click **⬆ LvUp** on any zombie card
3. Approve MetaMask (costs 0.001 ETH)
4. Level increases instantly

> At Level 2+ you can rename your zombie (changeName function).

---

## Demo Flow (8 minutes)
```
1. Run ./demo_setup.sh                    (before demo)
2. Import A, B, C accounts               (1 min)
3. Claim 500 ZMB on each account         (1 min)
4. Create zombies on A, B, C             (1 min)
5. Show My Army — DNA avatars, stats     (30 sec)
6. Battle with bet — show ZMB update     (1.5 min)
7. Feed on Kitty — kitty DNA zombie      (1 min)
8. Marketplace — list + buy              (1 min)
9. Transfer — send zombie to B           (30 sec)
10. Leaderboard + Explorer               (30 sec)
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Contracts not deployed" | Hard refresh `Cmd+Shift+R` |
| MetaMask wrong network | Switch to Ganache Local (Chain 1337) |
| "Already own a zombie" | Switch to a different account |
| "Insufficient ZMB" | Claim starter or buy more ZMB |
| Zombie on cooldown | Wait 10 seconds |
| Transfer fails | Make sure you own the zombie |
| Can't buy own zombie | Switch to different account |
| Blank page | Run `docker compose up -d frontend` |

---

## Account Addresses (from demo_setup.sh output)

Run `./demo_setup.sh` to get fresh addresses printed automatically.
```
Account A: 0x...  (use for Transfer recipient)
Account B: 0x...  (use for Transfer recipient)
Account C: 0x...  (use for Transfer recipient)
```

---

## ZombieCoin Quick Reference

| Action | Cost | Reward |
|--------|------|--------|
| Claim starter | Free | 500 ZMB |
| Buy ZMB | 0.01 ETH | 100 ZMB |
| Battle (win) | 100+ ZMB bet | Bet × 2 + 100 ZMB |
| Battle (loss) | 100+ ZMB bet | —0 ZMB |
| Level up zombie | 0.001 ETH | +1 Level |

---

*CryptoZombies DApp · CPSC-559 Midterm · Spring 2026*
