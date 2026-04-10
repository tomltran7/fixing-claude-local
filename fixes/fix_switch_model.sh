#!/bin/bash

################################################################################
# Fix: Switch Default Model Away from gemma4:e4b
# gemma4:e4b has structural output issues - use qwen2.5-coder:14b instead
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SETTINGS_FILE="$HOME/.claude/settings.json"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Fix gemma4:e4b Structural Output Issue  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Issue:${NC} gemma4:e4b returns structured output (tool_calls, thought)"
echo -e "${YELLOW}Solution:${NC} Switch to qwen2.5-coder:14b which works correctly"
echo ""

################################################################################
# Backup settings
################################################################################
if [[ -f "$SETTINGS_FILE" ]]; then
    BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backed up settings to: $BACKUP_FILE${NC}"
else
    echo -e "${RED}✗ Settings file not found: $SETTINGS_FILE${NC}"
    exit 1
fi

echo ""

################################################################################
# Update settings
################################################################################
echo -e "${YELLOW}Updating Claude settings...${NC}"

# Use Python to update JSON (more reliable than jq)
python3 << 'PYTHON_SCRIPT'
import json
import os

settings_file = os.path.expanduser("~/.claude/settings.json")

with open(settings_file, 'r') as f:
    settings = json.load(f)

# Update default model to qwen2.5-coder:14b (works well)
settings['model'] = 'qwen2.5-coder:14b'

# Keep gemma4:26b for opus (it's larger, works better)
settings['env']['ANTHROPIC_DEFAULT_OPUS_MODEL'] = 'gemma4:26b'

# Switch sonnet from gemma4:e4b to qwen2.5-coder:14b
settings['env']['ANTHROPIC_DEFAULT_SONNET_MODEL'] = 'qwen2.5-coder:14b'

# Haiku stays qwen2.5-coder:14b (already correct)
settings['env']['ANTHROPIC_DEFAULT_HAIKU_MODEL'] = 'qwen2.5-coder:14b'

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("✓ Settings updated")
PYTHON_SCRIPT

echo -e "${GREEN}✓ Configuration updated${NC}"
echo ""

################################################################################
# Show changes
################################################################################
echo -e "${BLUE}New Model Configuration:${NC}"
echo "  Default model: qwen2.5-coder:14b (was: gemma4:e4b or gemma4:26b)"
echo "  Opus (large): gemma4:26b"
echo "  Sonnet (medium): qwen2.5-coder:14b (was: gemma4:e4b)"
echo "  Haiku (small): qwen2.5-coder:14b"
echo ""

################################################################################
# Test
################################################################################
echo -e "${YELLOW}Testing new configuration...${NC}"
echo ""

echo "Test 1: Simple prompt"
echo "Command: claude -p 'hi'"
echo ""
claude -p 'hi' 2>&1 | head -20
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Configuration Updated!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  ✓ Switched away from gemma4:e4b (structural output issues)"
echo "  ✓ Now using qwen2.5-coder:14b (works correctly)"
echo "  ✓ Tested - should work now!"
echo ""
echo -e "${YELLOW}Try it:${NC}"
echo "  claude -p 'please review the current directory'"
echo ""
echo "Expected: Actual text response, not JSON/tool calls"
echo ""
