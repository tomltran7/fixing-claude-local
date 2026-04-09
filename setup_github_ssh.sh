#!/bin/bash

################################################################################
# GitHub SSH Access Setup & Diagnostic
# This script helps set up SSH authentication for GitHub
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}GitHub SSH Access Setup${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

################################################################################
# Step 1: Check existing SSH keys
################################################################################
echo -e "${YELLOW}[Step 1/5] Checking for existing SSH keys...${NC}"
echo ""

if [ -f ~/.ssh/id_ed25519.pub ]; then
    echo -e "${GREEN}✅ Found ED25519 key${NC}"
    SSH_KEY_PATH=~/.ssh/id_ed25519.pub
    SSH_KEY_EXISTS=true
elif [ -f ~/.ssh/id_rsa.pub ]; then
    echo -e "${GREEN}✅ Found RSA key${NC}"
    SSH_KEY_PATH=~/.ssh/id_rsa.pub
    SSH_KEY_EXISTS=true
else
    echo -e "${RED}❌ No SSH key found${NC}"
    SSH_KEY_EXISTS=false
fi
echo ""

################################################################################
# Step 2: Create SSH key if needed
################################################################################
if [ "$SSH_KEY_EXISTS" = false ]; then
    echo -e "${YELLOW}[Step 2/5] Creating new SSH key...${NC}"
    echo ""
    
    read -p "Enter your email for SSH key: " email
    
    if [ -z "$email" ]; then
        echo -e "${RED}Email required. Using default...${NC}"
        email="your-email@example.com"
    fi
    
    ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
    
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        echo -e "${GREEN}✅ SSH key created successfully${NC}"
        SSH_KEY_PATH=~/.ssh/id_ed25519.pub
        SSH_KEY_EXISTS=true
    else
        echo -e "${RED}❌ Failed to create SSH key${NC}"
        exit 1
    fi
    echo ""
else
    echo -e "${YELLOW}[Step 2/5] Using existing SSH key${NC}"
    echo ""
fi

################################################################################
# Step 3: Start SSH agent and add key
################################################################################
echo -e "${YELLOW}[Step 3/5] Adding key to SSH agent...${NC}"
echo ""

# Start ssh-agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
fi

# Add key to agent
if [ -f ~/.ssh/id_ed25519 ]; then
    ssh-add ~/.ssh/id_ed25519 2>/dev/null || true
elif [ -f ~/.ssh/id_rsa ]; then
    ssh-add ~/.ssh/id_rsa 2>/dev/null || true
fi

echo -e "${GREEN}✅ Key added to SSH agent${NC}"
echo ""

################################################################################
# Step 4: Display public key for GitHub
################################################################################
echo -e "${YELLOW}[Step 4/5] Your SSH Public Key${NC}"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────${NC}"
cat "$SSH_KEY_PATH"
echo -e "${BLUE}────────────────────────────────────────────────${NC}"
echo ""

echo -e "${GREEN}📋 Copy the key above (including 'ssh-ed25519' or 'ssh-rsa')${NC}"
echo ""

# Also copy to clipboard if possible
if command -v pbcopy &> /dev/null; then
    cat "$SSH_KEY_PATH" | pbcopy
    echo -e "${GREEN}✅ Key copied to clipboard!${NC}"
    echo ""
elif command -v xclip &> /dev/null; then
    cat "$SSH_KEY_PATH" | xclip -selection clipboard
    echo -e "${GREEN}✅ Key copied to clipboard!${NC}"
    echo ""
fi

################################################################################
# Step 5: Instructions to add key to GitHub
################################################################################
echo -e "${YELLOW}[Step 5/5] Add key to GitHub${NC}"
echo ""
echo "Follow these steps:"
echo ""
echo "1. Open GitHub SSH settings:"
echo "   ${BLUE}https://github.com/settings/keys${NC}"
echo ""
echo "2. Click 'New SSH key'"
echo ""
echo "3. Title: $(hostname) - $(date +%Y-%m-%d)"
echo ""
echo "4. Paste the key shown above"
echo ""
echo "5. Click 'Add SSH key'"
echo ""

read -p "Press Enter after you've added the key to GitHub..."
echo ""

################################################################################
# Step 6: Test GitHub connection
################################################################################
echo -e "${YELLOW}[Testing GitHub connection...]${NC}"
echo ""

if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo -e "${GREEN}✅ GitHub SSH authentication successful!${NC}"
    echo ""
    echo "You're all set to push to GitHub!"
    echo ""
    TEST_PASSED=true
else
    echo -e "${YELLOW}⚠️  Connection test inconclusive${NC}"
    echo ""
    echo "Full output:"
    ssh -T git@github.com 2>&1 || true
    echo ""
    echo "If you see 'successfully authenticated', you're good!"
    echo ""
    TEST_PASSED=false
fi

################################################################################
# Summary
################################################################################
echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Setup Summary${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "SSH Key Location: $SSH_KEY_PATH"
echo "GitHub Settings: https://github.com/settings/keys"
echo ""

if [ "$TEST_PASSED" = true ]; then
    echo -e "${GREEN}✅ Ready to push to GitHub!${NC}"
    echo ""
    echo "Next steps:"
    echo "  cd ~/Downloads/claude-debug-toolkit"
    echo "  ./push_to_github.sh"
else
    echo -e "${YELLOW}Manual verification needed${NC}"
    echo ""
    echo "Test command:"
    echo "  ssh -T git@github.com"
    echo ""
    echo "Expected output should include:"
    echo "  'Hi [username]! You've successfully authenticated'"
fi
echo ""
