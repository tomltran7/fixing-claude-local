#!/bin/bash

################################################################################
# Quick Start - Claude Local Debugging
# Run this script to perform initial setup and diagnostics
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Claude Local Debugging - Quick Start${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Make all scripts executable
echo -e "${YELLOW}Making scripts executable...${NC}"
chmod +x "${SCRIPT_DIR}/collect_diagnostics.sh"
chmod +x "${SCRIPT_DIR}/analyze_json_spill.sh"
chmod +x "${SCRIPT_DIR}/fixes/"*.sh 2>/dev/null || true
echo -e "${GREEN}✅ Done${NC}"
echo ""

# Check if git is initialized
if [ ! -d "${SCRIPT_DIR}/.git" ]; then
    echo -e "${YELLOW}Git repository not initialized. Initializing...${NC}"
    cd "${SCRIPT_DIR}"
    git init
    git add .
    git commit -m "Initial commit: Claude local debugging toolkit"
    echo -e "${GREEN}✅ Git initialized${NC}"
    echo ""
    echo -e "${YELLOW}Don't forget to add remote:${NC}"
    echo "  git remote add origin git@github.com:tomltran7/fixing-claude-local.git"
    echo "  git push -u origin main"
    echo ""
fi

# Run diagnostics
echo -e "${YELLOW}Running full diagnostics...${NC}"
echo ""
"${SCRIPT_DIR}/collect_diagnostics.sh"
echo ""

# Run JSON spill analyzer
echo -e "${YELLOW}Running JSON spill analysis...${NC}"
echo ""
"${SCRIPT_DIR}/analyze_json_spill.sh"
echo ""

# Final instructions
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. Review diagnostics in: diagnostics/output/latest/"
echo ""
echo "2. Push to GitHub:"
echo "   git add diagnostics/"
echo "   git commit -m 'Add diagnostic run $(date +%Y%m%d)'"
echo "   git push"
echo ""
echo "3. Devin will analyze and create fix scripts"
echo ""
echo "4. Pull updates and run fixes:"
echo "   git pull"
echo "   ./fixes/[fix_script].sh"
echo ""
