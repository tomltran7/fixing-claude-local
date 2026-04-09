#!/bin/bash

################################################################################
# Push to GitHub Repository
# Run this script on your personal machine with GitHub access
################################################################################

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_URL="git@github.com:tomltran7/fixing-claude-local.git"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Push to GitHub${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

cd "$REPO_DIR"

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    echo "Run this from the claude-debug-toolkit directory"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
    echo ""
    git status --short
    echo ""
    read -p "Do you want to commit them now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .
        read -p "Commit message: " commit_msg
        git commit -m "$commit_msg"
        echo -e "${GREEN}✅ Changes committed${NC}"
    else
        echo -e "${YELLOW}Continuing without committing...${NC}"
    fi
fi

# Check if remote exists
if ! git remote get-url origin >/dev/null 2>&1; then
    echo -e "${YELLOW}Adding remote origin...${NC}"
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}✅ Remote added${NC}"
fi

# Verify remote URL
CURRENT_REMOTE=$(git remote get-url origin)
if [ "$CURRENT_REMOTE" != "$REMOTE_URL" ]; then
    echo -e "${YELLOW}Warning: Remote URL doesn't match${NC}"
    echo "Current: $CURRENT_REMOTE"
    echo "Expected: $REMOTE_URL"
    read -p "Update remote URL? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote set-url origin "$REMOTE_URL"
        echo -e "${GREEN}✅ Remote URL updated${NC}"
    fi
fi

# Show what will be pushed
echo ""
echo -e "${BLUE}Files to be pushed:${NC}"
git ls-tree -r HEAD --name-only | head -20
echo ""

# Try to push
echo -e "${YELLOW}Pushing to GitHub...${NC}"
if git push -u origin main; then
    echo ""
    echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
    echo ""
    echo "Repository: https://github.com/tomltran7/fixing-claude-local"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Run diagnostics: ./quick_start.sh"
    echo "2. Push diagnostic results"
    echo "3. Notify Devin to analyze"
else
    echo ""
    echo -e "${RED}❌ Push failed${NC}"
    echo ""
    echo "Common issues:"
    echo "1. SSH key not configured: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
    echo "2. Repository doesn't exist: Create it at https://github.com/new"
    echo "3. No push permission: Check repository settings"
    echo ""
    echo "Manual push command:"
    echo "  git push -u origin main"
fi
