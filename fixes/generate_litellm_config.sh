#!/bin/bash

################################################################################
# Generate LiteLLM Configuration
# Creates a proper litellm_config.yaml for Claude Code integration
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CONFIG_FILE="$HOME/litellm_config.yaml"

echo -e "${BLUE}=== LiteLLM Configuration Generator ===${NC}"
echo ""

################################################################################
# Check if config already exists
################################################################################
if [[ -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}⚠️  Config file already exists: $CONFIG_FILE${NC}"
    echo ""
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    # Backup existing config
    BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backed up to: $BACKUP_FILE${NC}"
    echo ""
fi

################################################################################
# Generate Configuration
################################################################################
echo -e "${YELLOW}Generating configuration...${NC}"

cat > "$CONFIG_FILE" << 'EOF'
# LiteLLM Configuration for Claude Code + Ollama Integration
# Generated: 2026-04-09
# Purpose: Translate Claude API calls to Ollama models

model_list:
  #############################################################################
  # Claude Model Names → Ollama Models
  # Claude Code sends requests with model names like "claude-opus-4"
  # LiteLLM translates these to Ollama model names
  #############################################################################
  
  # Claude Opus 4 → Gemma4 26B
  - model_name: claude-opus-4
    litellm_params:
      model: ollama/gemma4:26b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: claude-opus-4-20250514
    litellm_params:
      model: ollama/gemma4:26b
      api_base: http://localhost:11434
      stream: true
      
  # Claude Sonnet 4 → Gemma4 E4B
  - model_name: claude-sonnet-4
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: claude-sonnet-4-20250514
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      
  # Claude Haiku 4 → Qwen 2.5 Coder 14B
  - model_name: claude-haiku-4
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: claude-haiku-4-20250514
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434
      stream: true

  #############################################################################
  # Direct Ollama Model Names
  # Also support calling Ollama models directly by name
  #############################################################################
  
  - model_name: qwen2.5-coder:14b
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: gemma4:e4b
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: gemma4:26b
    litellm_params:
      model: ollama/gemma4:26b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: gemma4:31b
    litellm_params:
      model: ollama/gemma4:31b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: llama3.2:latest
    litellm_params:
      model: ollama/llama3.2:latest
      api_base: http://localhost:11434
      stream: true
      
  - model_name: llama3-groq-tool-use:8b
    litellm_params:
      model: ollama/llama3-groq-tool-use:8b
      api_base: http://localhost:11434
      stream: true

#############################################################################
# General Settings
#############################################################################
general_settings:
  master_key: "local"  # Authentication key (matches Claude's ANTHROPIC_API_KEY)
  
litellm_settings:
  drop_params: true          # Drop parameters not supported by Ollama
  num_retries: 3            # Retry failed requests
  request_timeout: 600      # 10 minute timeout for large models
  success_callback: []
  failure_callback: []
  
# Optional: Enable detailed logging for debugging
# router_settings:
#   routing_strategy: simple
#   num_retries: 3
#   retry_after: 10
EOF

echo -e "${GREEN}✓ Configuration created: $CONFIG_FILE${NC}"
echo ""

################################################################################
# Display Configuration
################################################################################
echo -e "${BLUE}Configuration Summary:${NC}"
echo ""
echo "Model Mappings:"
echo "  claude-opus-4          → gemma4:26b"
echo "  claude-sonnet-4        → gemma4:e4b"
echo "  claude-haiku-4         → qwen2.5-coder:14b"
echo ""
echo "Direct Ollama Models:"
echo "  qwen2.5-coder:14b"
echo "  gemma4:e4b"
echo "  gemma4:26b"
echo "  gemma4:31b"
echo "  llama3.2:latest"
echo "  llama3-groq-tool-use:8b"
echo ""
echo "Authentication: master_key = 'local'"
echo "Ollama API: http://localhost:11434"
echo ""

################################################################################
# Next Steps
################################################################################
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Start LiteLLM with this config:"
echo "   litellm --config $CONFIG_FILE --port 4000"
echo ""
echo "2. Or use the automated fix script:"
echo "   ./fixes/fix_litellm_complete.sh"
echo ""
echo -e "${GREEN}Configuration complete!${NC}"
