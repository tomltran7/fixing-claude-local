#!/bin/bash

################################################################################
# GitHub Token Configuration Script
# Securely configures GitHub access token for HTTPS authentication
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   GitHub Token Configuration (Secure)     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Security Warning
################################################################################
echo -e "${YELLOW}⚠️  SECURITY REMINDER:${NC}"
echo "  • Never commit tokens to git repositories"
echo "  • Never share tokens in chat/email"
echo "  • Revoke tokens if accidentally exposed"
echo ""

################################################################################
# Check if token already configured
################################################################################
CURRENT_HELPER=$(git config --global credential.helper 2>/dev/null || echo "none")
CURRENT_USER=$(git config --global credential.https://github.com.username 2>/dev/null || echo "none")

if [[ "$CURRENT_HELPER" == "store" ]] && [[ "$CURRENT_USER" != "none" ]]; then
    echo -e "${GREEN}✓ GitHub token already configured${NC}"
    echo "  Username: $CURRENT_USER"
    echo "  Helper: $CURRENT_HELPER"
    echo ""
    read -p "Reconfigure? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting without changes."
        exit 0
    fi
fi

################################################################################
# Get GitHub username
################################################################################
echo -e "${BLUE}Step 1: GitHub Username${NC}"
read -p "Enter your GitHub username (e.g., tomltran7): " GITHUB_USER

if [[ -z "$GITHUB_USER" ]]; then
    echo -e "${RED}Error: Username cannot be empty${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Username: $GITHUB_USER${NC}"
echo ""

################################################################################
# Get Personal Access Token (hidden input)
################################################################################
echo -e "${BLUE}Step 2: Personal Access Token${NC}"
echo "Your token will be hidden as you type."
echo ""

# Read token with hidden input
read -s -p "Paste your GitHub token (ghp_...): " GITHUB_TOKEN
echo ""

if [[ -z "$GITHUB_TOKEN" ]]; then
    echo -e "${RED}Error: Token cannot be empty${NC}"
    exit 1
fi

# Validate token format
if [[ ! "$GITHUB_TOKEN" =~ ^ghp_ ]]; then
    echo -e "${YELLOW}⚠️  Warning: Token doesn't start with 'ghp_'${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 1
    fi
fi

echo -e "${GREEN}✓ Token received (${#GITHUB_TOKEN} characters)${NC}"
echo ""

################################################################################
# Configure git credential storage
################################################################################
echo -e "${BLUE}Step 3: Configuring Git${NC}"

# Set credential helper to store (plain text storage)
git config --global credential.helper store

# Set username for GitHub
git config --global credential.https://github.com.username "$GITHUB_USER"

echo -e "${GREEN}✓ Git configured${NC}"
echo ""

################################################################################
# Store credentials by triggering a git operation
################################################################################
echo -e "${BLUE}Step 4: Testing & Storing Token${NC}"

# Create credentials file with token
CRED_FILE="$HOME/.git-credentials"

# Check if credentials file exists and backup
if [[ -f "$CRED_FILE" ]]; then
    cp "$CRED_FILE" "$CRED_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}  → Backed up existing credentials${NC}"
fi

# Add/update GitHub credentials
# Remove old GitHub entries
if [[ -f "$CRED_FILE" ]]; then
    grep -v "github.com" "$CRED_FILE" > "$CRED_FILE.tmp" 2>/dev/null || touch "$CRED_FILE.tmp"
    mv "$CRED_FILE.tmp" "$CRED_FILE"
fi

# Add new GitHub credentials
echo "https://$GITHUB_USER:$GITHUB_TOKEN@github.com" >> "$CRED_FILE"
chmod 600 "$CRED_FILE"

echo -e "${GREEN}✓ Token stored in $CRED_FILE${NC}"
echo ""

################################################################################
# Test the configuration
################################################################################
echo -e "${BLUE}Step 5: Testing Connection${NC}"

# Test with a simple ls-remote
if git ls-remote https://github.com/tomltran7/fixing-claude-local.git HEAD &>/dev/null; then
    echo -e "${GREEN}✓ Successfully authenticated to GitHub!${NC}"
else
    echo -e "${RED}✗ Authentication failed${NC}"
    echo "Please check your token and try again."
    exit 1
fi

echo ""

################################################################################
# Success Summary
################################################################################
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Configuration Complete!          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Git is now configured to use your GitHub token."
echo ""
echo -e "${BLUE}Configuration Details:${NC}"
echo "  • Credential helper: store"
echo "  • Username: $GITHUB_USER"
echo "  • Token stored in: ~/.git-credentials"
echo "  • Token length: ${#GITHUB_TOKEN} characters"
echo ""
echo -e "${YELLOW}Security Notes:${NC}"
echo "  • Your token is stored in plain text at ~/.git-credentials"
echo "  • This file is only readable by you (chmod 600)"
echo "  • Never commit this file to git"
echo "  • To revoke access, delete the token from GitHub settings"
echo ""
echo -e "${GREEN}Ready to push to GitHub! 🚀${NC}"
echo ""

# Clear token from memory
unset GITHUB_TOKEN
