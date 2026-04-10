#!/bin/bash

################################################################################
# Uninstall Claude Code CLI
# Removes Claude Code and optionally cleans up configuration
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Claude Code CLI Uninstaller              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Check current installation
################################################################################
echo -e "${YELLOW}Checking current installation...${NC}"
echo ""

if command -v claude &>/dev/null; then
    CLAUDE_PATH=$(which claude)
    echo -e "${GREEN}✓ Claude Code CLI is installed${NC}"
    echo "  Location: $CLAUDE_PATH"
    echo ""
    
    # Check version
    echo "  Version: $(claude --version 2>&1 || echo 'Unknown')"
    echo ""
else
    echo -e "${RED}✗ Claude Code CLI not found in PATH${NC}"
    echo "It may already be uninstalled, or installed in a non-standard location."
    echo ""
fi

################################################################################
# Detect installation method
################################################################################
echo -e "${YELLOW}Detecting installation method...${NC}"
echo ""

INSTALL_METHOD="unknown"

# Check Homebrew
if command -v brew &>/dev/null; then
    if brew list claude 2>/dev/null | grep -q claude; then
        INSTALL_METHOD="homebrew"
        echo -e "${GREEN}✓ Detected: Homebrew installation${NC}"
    fi
fi

# Check npm global
if command -v npm &>/dev/null; then
    if npm list -g claude 2>/dev/null | grep -q claude; then
        INSTALL_METHOD="npm"
        echo -e "${GREEN}✓ Detected: npm global installation${NC}"
    fi
fi

# Check if it's a symlink or direct binary
if [[ -n "$CLAUDE_PATH" ]]; then
    if [[ -L "$CLAUDE_PATH" ]]; then
        REAL_PATH=$(readlink "$CLAUDE_PATH")
        echo "  Claude is a symlink to: $REAL_PATH"
    fi
fi

if [[ "$INSTALL_METHOD" == "unknown" ]] && [[ -n "$CLAUDE_PATH" ]]; then
    INSTALL_METHOD="manual"
    echo -e "${YELLOW}⚠️  Could not detect installation method${NC}"
    echo "  Appears to be manual installation"
fi

echo ""

################################################################################
# Uninstall based on method
################################################################################
echo -e "${YELLOW}Uninstalling Claude Code CLI...${NC}"
echo ""

case "$INSTALL_METHOD" in
    homebrew)
        echo "Using Homebrew to uninstall..."
        brew uninstall claude
        echo -e "${GREEN}✓ Uninstalled via Homebrew${NC}"
        ;;
        
    npm)
        echo "Using npm to uninstall..."
        npm uninstall -g claude
        echo -e "${GREEN}✓ Uninstalled via npm${NC}"
        ;;
        
    manual)
        echo "Manual installation detected"
        echo ""
        echo -e "${YELLOW}To uninstall manually:${NC}"
        echo "  1. Remove the binary: rm $CLAUDE_PATH"
        if [[ -L "$CLAUDE_PATH" ]]; then
            REAL_PATH=$(readlink "$CLAUDE_PATH")
            echo "  2. Remove the real file: rm $REAL_PATH"
        fi
        echo ""
        read -p "Remove binary now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -f "$CLAUDE_PATH"
            if [[ -L "$CLAUDE_PATH" ]]; then
                sudo rm -f "$(readlink "$CLAUDE_PATH")"
            fi
            echo -e "${GREEN}✓ Binary removed${NC}"
        else
            echo "Skipped binary removal"
        fi
        ;;
        
    unknown)
        echo -e "${YELLOW}Could not detect installation method${NC}"
        echo "Claude Code may already be uninstalled"
        ;;
esac

echo ""

################################################################################
# Clean up configuration (optional)
################################################################################
echo -e "${YELLOW}Configuration cleanup...${NC}"
echo ""
echo "Claude Code stores configuration in:"
echo "  ~/.claude/"
echo "  ~/.config/claude/"
echo ""

read -p "Remove configuration files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Backup first
    BACKUP_DIR="$HOME/claude_config_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    if [[ -d "$HOME/.claude" ]]; then
        echo "  Backing up ~/.claude to $BACKUP_DIR"
        cp -r "$HOME/.claude" "$BACKUP_DIR/"
        rm -rf "$HOME/.claude"
        echo -e "${GREEN}  ✓ Removed ~/.claude${NC}"
    fi
    
    if [[ -d "$HOME/.config/claude" ]]; then
        echo "  Backing up ~/.config/claude to $BACKUP_DIR"
        cp -r "$HOME/.config/claude" "$BACKUP_DIR/"
        rm -rf "$HOME/.config/claude"
        echo -e "${GREEN}  ✓ Removed ~/.config/claude${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Configuration backed up to: $BACKUP_DIR${NC}"
else
    echo "Kept configuration files"
fi

echo ""

################################################################################
# Clean up LiteLLM (optional)
################################################################################
echo -e "${YELLOW}LiteLLM cleanup (optional)...${NC}"
echo ""
echo "You set up LiteLLM for local models. Remove it?"
echo ""

read -p "Uninstall LiteLLM? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v pip3 &>/dev/null; then
        pip3 uninstall -y litellm
        echo -e "${GREEN}✓ LiteLLM uninstalled${NC}"
    fi
    
    if [[ -f "$HOME/litellm_config.yaml" ]]; then
        read -p "Remove ~/litellm_config.yaml? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm "$HOME/litellm_config.yaml"
            echo -e "${GREEN}✓ Removed litellm_config.yaml${NC}"
        fi
    fi
else
    echo "Kept LiteLLM"
fi

echo ""

################################################################################
# Summary
################################################################################
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Uninstall Complete!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "What was removed:"
echo "  ✓ Claude Code CLI binary"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  ✓ Configuration files (backed up)"
fi
echo ""
echo "What remains:"
echo "  • Ollama (still installed, can be used with other tools)"
echo "  • This debugging toolkit"
echo ""
echo -e "${BLUE}If you want to reinstall later:${NC}"
echo "  Visit: https://claude.ai/download"
echo ""
echo -e "${YELLOW}Alternative tools you can try:${NC}"
echo "  • Devin CLI - https://cli.devin.ai"
echo "  • Aider - https://aider.chat"
echo "  • Continue.dev - https://continue.dev"
echo ""
