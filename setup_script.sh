cat > demo_setup.sh << 'EOF'
#!/usr/bin/env bash
# demo_setup.sh — full deploy + print keys and addresses cleanly
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

echo -e "${YELLOW}Step 1: Tearing down…${NC}"
docker compose down -v 2>/dev/null || true
rm -rf build/
echo -e "${GREEN}[DONE]${NC} Cleaned"

echo -e "${YELLOW}Step 2: Starting Ganache…${NC}"
docker compose up -d ganache
echo "Waiting 8 seconds for Ganache to be ready…"
sleep 8
echo -e "${GREEN}[DONE]${NC} Ganache ready"

echo -e "${YELLOW}Step 3: Deploying contracts…${NC}"
docker compose run --rm truffle truffle migrate --reset --network development
echo -e "${GREEN}[DONE]${NC} Contracts deployed"

echo -e "${YELLOW}Step 4: Starting frontend…${NC}"
docker compose up -d frontend
echo -e "${GREEN}[DONE]${NC} Frontend started"

echo ""
echo -e "${YELLOW}Step 5: Fetching keys and addresses…${NC}"
sleep 2

KEYS=($(docker compose logs ganache | grep -E "cz-ganache\s+\|\s+\([0-9]\) 0x" | grep -v "ETH" | awk '{print $NF}' | sed 's/0x//' | head -5))
ADDRS=($(docker compose logs ganache | grep -E "cz-ganache\s+\|\s+\([0-9]\).*ETH" | awk '{print $4}' | head -5))
NAMES=("Account A" "Account B" "Account C" "Account D" "Account E")

echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}   CryptoZombies DApp — Ready!                          ${NC}"
echo -e "${BOLD}${GREEN}   http://localhost:3000                                 ${NC}"
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
  echo -e "    Key:     ${CYAN}${KEYS[$i]}${NC}"
  echo -e "    Address: ${CYAN}${ADDRS[$i]}${NC}"
  echo ""
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  ADDRESSES (for Transfer / Marketplace demo)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
for i in 0 1 2 3 4; do
  echo -e "  ${BOLD}${NAMES[$i]}:${NC} ${CYAN}${ADDRS[$i]}${NC}"
done
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  ZombieCoin DEMO STEPS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Import Account A, B, C keys into MetaMask"
echo "  2. Open http://localhost:3000 → hard refresh Cmd+Shift+R"
echo "  3. Click 🪙 ZMB in navbar → Claim 500 free ZMB"
echo "  4. Switch to Account B, C → Claim their 500 ZMB too"
echo "  5. Create zombies on A, B, C"
echo "  6. Battle tab → set bet → ATTACK!"
echo "  7. Win = ZMB balance updates in navbar instantly"
echo "  8. Buy more ZMB if needed (auto-prompt appears)"
echo "  9. List zombie on Marketplace → buy from another account"
echo " 10. Check Leaderboard, Graveyard, Explorer"
echo ""
echo -e "${GREEN}  Hard refresh: Cmd + Shift + R${NC}"
echo ""
EOF
