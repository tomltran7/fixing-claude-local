#!/bin/bash

################################################################################
# Full Workflow: Diagnose → Push → Done
# Runs diagnostics and automatically pushes to GitHub in one command
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Full Workflow: Diagnose → Push → Done    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Step 1: Run Diagnostics
################################################################################
echo -e "${YELLOW}[Step 1/2] Running diagnostics...${NC}"
echo ""

./quick_start.sh

echo ""
echo -e "${GREEN}✅ Diagnostics complete!${NC}"
echo ""

################################################################################
# Step 2: Push to GitHub
################################################################################
echo -e "${YELLOW}[Step 2/2] Pushing to GitHub...${NC}"
echo ""

# Small delay to let user see diagnostics results
sleep 2

./quick_push.sh

################################################################################
# Done
################################################################################
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            All Done! 🎉                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "What just happened:"
echo "  ✅ Collected full diagnostics"
echo "  ✅ Analyzed JSON spill issues"
echo "  ✅ Committed to git"
echo "  ✅ Pushed to GitHub"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Notify Devin: 'Diagnostics uploaded!'"
echo "  2. Wait for analysis and fixes"
echo "  3. Pull updates: git pull"
echo "  4. Run fixes: ./fixes/fix_*.sh"
echo ""
echo -e "${YELLOW}Repository:${NC}"
echo "  https://github.com/tomltran7/fixing-claude-local"
echo ""
