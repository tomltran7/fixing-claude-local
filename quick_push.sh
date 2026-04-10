#!/bin/bash

################################################################################
# Quick Push (No Prompts)
# Instantly add, commit, and push diagnostics - no questions asked
################################################################################

set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Quick Push to GitHub...${NC}"

# Add diagnostics (force add to override .gitignore)
git add -f diagnostics/output/run_*/ 2>/dev/null || true
git add -f diagnostics/output/json_spill_analysis_*.txt 2>/dev/null || true
git add -f diagnostics/output/empty_response_diagnostic_*.txt 2>/dev/null || true
git add -f diagnostics/output/git_pull_issue_*.txt 2>/dev/null || true
git add -f diagnostics/output/tool_calling_diagnostic_*.txt 2>/dev/null || true
git add diagnostics/analysis/*.md 2>/dev/null || true

# Check if anything to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}No new diagnostics to push${NC}"
    exit 0
fi

# Commit
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
git commit -m "Diagnostics run $TIMESTAMP"

# Push
if git push origin main; then
    echo -e "${GREEN}✅ Pushed! https://github.com/tomltran7/fixing-claude-local${NC}"
else
    echo -e "${RED}❌ Push failed - check connection${NC}"
    exit 1
fi
