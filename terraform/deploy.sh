#!/usr/bin/env bash
# terraform/deploy.sh — full AWS end to end deployment for CryptoZombies DApp
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RED='\033[0;31m'; NC='\033[0m'

KEY_PATH="$HOME/.ssh/ai-inference-key.pem"
NAMES=("Account A" "Account B" "Account C" "Account D" "Account E")

# ── Prerequisites ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 1: Checking prerequisites…${NC}"
command -v terraform >/dev/null || { echo -e "${RED}[ERR]${NC} Terraform not installed"; exit 1; }
command -v aws       >/dev/null || { echo -e "${RED}[ERR]${NC} AWS CLI not installed"; exit 1; }
[[ -f "$KEY_PATH" ]]            || { echo -e "${RED}[ERR]${NC} Key not found at $KEY_PATH"; exit 1; }
chmod 400 "$KEY_PATH"
aws sts get-caller-identity > /dev/null || { echo -e "${RED}[ERR]${NC} AWS credentials not configured. Run: aws configure"; exit 1; }
echo -e "${GREEN}[DONE]${NC} Prerequisites checked"

# ── Terraform ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 2: Provisioning AWS infrastructure…${NC}"
terraform init -upgrade -input=false
terraform apply -auto-approve -input=false
echo -e "${GREEN}[DONE]${NC} Infrastructure provisioned"

# ── Get outputs ───────────────────────────────────────────────────────────────
PUBLIC_IP=$(terraform output -raw public_ip)
FRONTEND_URL=$(terraform output -raw frontend_url)
GANACHE_RPC=$(terraform output -raw ganache_rpc)
PUBLIC_DNS=$(terraform output -raw public_dns)
GANACHE_RPC_DNS=$(terraform output -raw ganache_rpc_dns)

# ── Wait for SSH ──────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 3: Waiting for EC2 SSH to be ready…${NC}"
sleep 30
for i in $(seq 1 15); do
  echo -n "  Attempt $i/15: "
  if ssh -i "$KEY_PATH" \
      -o StrictHostKeyChecking=no \
      -o ConnectTimeout=5 \
      -o ConnectionAttempts=1 \
      -o BatchMode=yes \
      ubuntu@"$PUBLIC_IP" "echo ok" 2>/dev/null | grep -q ok; then
    echo -e "${GREEN}SSH ready!${NC}"
    break
  fi
  if [[ $i -eq 15 ]]; then
    echo -e "${RED}SSH not available. Check your network or key.${NC}"
    exit 1
  fi
  echo -e "${YELLOW}not ready — waiting 15s…${NC}"
  sleep 15
done
echo -e "${GREEN}[DONE]${NC} EC2 reachable"

# ── Install Docker ────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 4: Installing Docker on EC2…${NC}"
ssh -i "$KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=15 \
  ubuntu@"$PUBLIC_IP" << 'REMOTE'
set -e
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg git
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker
echo "Docker installed!"
REMOTE
echo -e "${GREEN}[DONE]${NC} Docker installed"

# ── Clone repo ────────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 5: Cloning CryptoZombies repo…${NC}"
ssh -i "$KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=15 \
  ubuntu@"$PUBLIC_IP" << 'REMOTE'
set -e
cd /home/ubuntu
if [[ -d "app" ]]; then
  echo "Repo exists — pulling latest..."
  cd app && git pull
else
  git clone https://github.com/Shantanumtk/CPSC-559-CryptoZombies-Dapp.git app
fi
chown -R ubuntu:ubuntu /home/ubuntu/app
echo "Repo ready!"
REMOTE
echo -e "${GREEN}[DONE]${NC} Repo cloned"

# ── Deploy DApp ───────────────────────────────────────────────────────────────
echo -e "${YELLOW}Step 6: Starting Ganache…${NC}"
ssh -i "$KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=15 \
  ubuntu@"$PUBLIC_IP" \
  "cd /home/ubuntu/app && sudo -u ubuntu docker compose up -d ganache"
echo "Waiting 10 seconds for Ganache to be ready…"
sleep 10
echo -e "${GREEN}[DONE]${NC} Ganache ready"

echo -e "${YELLOW}Step 7: Deploying contracts…${NC}"
ssh -i "$KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=60 \
  ubuntu@"$PUBLIC_IP" \
  "cd /home/ubuntu/app && sudo -u ubuntu docker compose run --rm truffle truffle migrate --reset --network development"
echo -e "${GREEN}[DONE]${NC} Contracts deployed"

echo -e "${YELLOW}Step 8: Starting frontend…${NC}"
ssh -i "$KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=15 \
  ubuntu@"$PUBLIC_IP" \
  "cd /home/ubuntu/app && sudo -u ubuntu docker compose up -d frontend && echo DEPLOYED > /home/ubuntu/deploy.log"
echo -e "${GREEN}[DONE]${NC} Frontend started"

# ── Fetch keys ────────────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}Step 9: Fetching keys and addresses…${NC}"
sleep 3

KEYS=($(ssh -i "$KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=10 \
  ubuntu@"$PUBLIC_IP" \
  "cd /home/ubuntu/app && docker compose logs ganache | grep -E '\([0-9]\) 0x' | grep -v ETH | sed 's/.*0x//' | head -5" 2>/dev/null || echo ""))

ADDRS=($(ssh -i "$KEY_PATH" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=10 \
  ubuntu@"$PUBLIC_IP" \
  "cd /home/ubuntu/app && docker compose logs ganache | grep -E '\([0-9]\).*ETH' | awk '{print \$4}' | head -5" 2>/dev/null || echo ""))

# ── Final output ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}   CryptoZombies DApp — Ready!                          ${NC}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}  Access URLs:${NC}"
echo -e "  IP:  ${CYAN}${FRONTEND_URL}${NC}"
echo -e "  DNS: ${CYAN}${PUBLIC_DNS}${NC}"
echo ""
echo -e "${BOLD}MetaMask Network Settings:${NC}"
echo -e "  RPC URL (IP):  ${CYAN}${GANACHE_RPC}${NC}"
echo -e "  RPC URL (DNS): ${CYAN}${GANACHE_RPC_DNS}${NC}"
echo -e "  Chain ID:      ${CYAN}1337${NC}"
echo -e "  Symbol:        ${CYAN}ETH${NC}"
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
echo "  2. Open ${PUBLIC_DNS}"
echo "  3. Add Ganache AWS network → RPC ${GANACHE_RPC_DNS} Chain ID 1337"
echo "  4. Click 🪙 ZMB in navbar → Claim 500 free ZMB"
echo "  5. Switch to Account B, C → Claim their 500 ZMB too"
echo "  6. Create zombies on A, B, C"
echo "  7. Battle tab → set bet → ATTACK!"
echo "  8. Win = ZMB balance updates in navbar instantly"
echo "  9. List zombie on Marketplace → buy from another account"
echo " 10. Check Leaderboard, Graveyard, Explorer"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}  Note: If frontend doesn't load, wait 30s and hard refresh: Ctrl + Shift + R${NC}"
echo ""
