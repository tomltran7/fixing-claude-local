#!/bin/bash

################################################################################
# Verify Repository Status
# Helps debug why git pull shows "already up to date"
################################################################################

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Repository Status Check                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Check current location
################################################################################
echo -e "${YELLOW}Current Directory:${NC}"
pwd
echo ""

################################################################################
# Check if in git repo
################################################################################
echo -e "${YELLOW}Git Repository Check:${NC}"
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Inside git repository${NC}"
else
    echo -e "${RED}✗ NOT in a git repository${NC}"
    echo "Please run from: ~/Downloads/fixing-claude-local"
    exit 1
fi
echo ""

################################################################################
# Check remote configuration
################################################################################
echo -e "${YELLOW}Remote Configuration:${NC}"
git remote -v
echo ""

################################################################################
# Check current branch
################################################################################
echo -e "${YELLOW}Current Branch:${NC}"
git branch -vv
echo ""

################################################################################
# Check local vs remote commits
################################################################################
echo -e "${YELLOW}Local Commit:${NC}"
git log --oneline -1
echo ""

echo -e "${YELLOW}Fetching from remote...${NC}"
git fetch origin
echo ""

echo -e "${YELLOW}Remote Commit (origin/main):${NC}"
git log origin/main --oneline -1
echo ""

################################################################################
# Check if files exist
################################################################################
echo -e "${YELLOW}Checking for New Files:${NC}"
FILES=(
    "diagnose_tool_calling.sh"
    "fixes/fix_tool_calling.sh"
    "TOOL_CALLING_FIX.md"
)

for FILE in "${FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        echo -e "  ✓ ${GREEN}$FILE${NC} - EXISTS"
    else
        echo -e "  ✗ ${RED}$FILE${NC} - MISSING"
    fi
done
echo ""

################################################################################
# Check git status
################################################################################
echo -e "${YELLOW}Git Status:${NC}"
git status
echo ""

################################################################################
# Check last 5 commits
################################################################################
echo -e "${YELLOW}Last 5 Commits (local):${NC}"
git log --oneline -5
echo ""

echo -e "${YELLOW}Last 5 Commits (remote):${NC}"
git log origin/main --oneline -5
echo ""

################################################################################
# Recommendations
################################################################################
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Diagnosis                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)

if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
    echo -e "${GREEN}✓ Local and remote are in sync${NC}"
    echo ""
    
    # Check if files exist
    if [[ -f "diagnose_tool_calling.sh" ]] && [[ -f "fixes/fix_tool_calling.sh" ]]; then
        echo -e "${GREEN}✓ All new files present${NC}"
        echo ""
        echo -e "${BLUE}You're ready to run:${NC}"
        echo "  ./fixes/fix_tool_calling.sh"
    else
        echo -e "${RED}✗ Files missing despite being in sync${NC}"
        echo ""
        echo "Try force checkout:"
        echo "  git checkout main -- diagnose_tool_calling.sh"
        echo "  git checkout main -- fixes/fix_tool_calling.sh"
        echo "  git checkout main -- TOOL_CALLING_FIX.md"
    fi
else
    echo -e "${YELLOW}⚠ Local and remote differ${NC}"
    echo ""
    echo "Local:  $LOCAL_COMMIT"
    echo "Remote: $REMOTE_COMMIT"
    echo ""
    echo "Run: git pull origin main"
fi
