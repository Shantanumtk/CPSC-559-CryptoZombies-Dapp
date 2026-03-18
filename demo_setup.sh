#!/usr/bin/env bash
# demo_setup.sh — full local deployment for CryptoZombies DApp
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RED='\033[0;31m'; NC='\033[0m'
NAMES=("Account A" "Account B" "Account C" "Account D" "Account E")

# ── Prerequisites ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 1: Checking prerequisites…${NC}"
command -v docker        >/dev/null || { echo -e "${RED}[ERR]${NC} Docker not installed"; exit 1; }
docker compose version   >/dev/null || { echo -e "${RED}[ERR]${NC} Docker Compose not installed"; exit 1; }
echo -e "${GREEN}[DONE]${NC} Prerequisites checked"

# ── Tear down ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 2: Tearing down existing containers…${NC}"
docker compose down -v 2>/dev/null || true
rm -rf build/
echo -e "${GREEN}[DONE]${NC} Cleaned"

# ── Start Ganache ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 3: Starting Ganache…${NC}"
docker compose up -d ganache
echo "Waiting 8 seconds for Ganache to be ready…"
sleep 8
echo -e "${GREEN}[DONE]${NC} Ganache ready"

# ── Deploy contracts ──────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 4: Deploying contracts…${NC}"
docker compose run --rm truffle truffle migrate --reset --network development
echo -e "${GREEN}[DONE]${NC} Contracts deployed"

# ── Start frontend ────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 5: Starting frontend…${NC}"
docker compose up -d frontend
echo -e "${GREEN}[DONE]${NC} Frontend started"

# ── Fetch keys ────────────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}Step 6: Fetching keys and addresses…${NC}"
sleep 2

KEYS=($(docker compose logs ganache | grep -E "cz-ganache\s+\|\s+\([0-9]\) 0x" | grep -v "ETH" | awk '{print $NF}' | sed 's/0x//' | head -5))
ADDRS=($(docker compose logs ganache | grep -E "cz-ganache\s+\|\s+\([0-9]\).*ETH" | awk '{print $4}' | head -5))

# ── Verify contracts deployed ─────────────────────────────────────────────────
echo -e "${YELLOW}Step 7: Verifying deployment…${NC}"
for f in "build/contracts/ZombieBattle.json" "build/contracts/LocalKitty.json"; do
  [[ -f "$f" ]] && echo -e "${GREEN}[DONE]${NC} $f exists" || echo -e "${RED}[WARN]${NC} $f missing"
done

# ── Final output ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}   CryptoZombies DApp — Ready!                          ${NC}"
echo -e "${BOLD}${GREEN}   ${CYAN}http://localhost:3000${NC}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}MetaMask Network Settings:${NC}"
echo -e "  RPC URL:  ${CYAN}http://127.0.0.1:8545${NC}"
echo -e "  Chain ID: ${CYAN}1337${NC}"
echo -e "  Symbol:   ${CYAN}ETH${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  PRIVATE KEYS (paste directly into MetaMask)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
for i in 0 1 2 3 4; do
  echo -e "  ${BOLD}${NAMES[$i]}:${NC}"
  echo -e "    Key:     ${CYAN}${KEYS[$i]:-not_found}${NC}"
  echo -e "    Address: ${CYAN}${ADDRS[$i]:-not_found}${NC}"
  echo ""
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  ADDRESSES (for Transfer / Marketplace demo)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
for i in 0 1 2 3 4; do
  echo -e "  ${BOLD}${NAMES[$i]}:${NC} ${CYAN}${ADDRS[$i]:-not_found}${NC}"
done
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  ZombieCoin DEMO STEPS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Import Account A, B, C keys into MetaMask"
echo "  2. Open http://localhost:3000 → hard refresh Cmd+Shift+R"
echo "  3. Add network → RPC http://127.0.0.1:8545 Chain ID 1337"
echo "  4. Click 🪙 ZMB in navbar → Claim 500 free ZMB"
echo "  5. Switch to Account B, C → Claim their 500 ZMB too"
echo "  6. Create zombies on A, B, C"
echo "  7. Battle tab → set bet → ATTACK!"
echo "  8. Win = ZMB balance updates in navbar instantly"
echo "  9. List zombie on Marketplace → buy from another account"
echo " 10. Check Leaderboard, Graveyard, Explorer"
echo ""
echo -e "${GREEN}  Hard refresh: Cmd + Shift + R${NC}"
echo ""