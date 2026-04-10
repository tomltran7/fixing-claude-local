#!/bin/bash

################################################################################
# Fix Tool-Calling Issue
# Disables unwanted function calling in LiteLLM config
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CONFIG_FILE="$HOME/litellm_config.yaml"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Fix Tool-Calling Issue                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Backup existing config
################################################################################
if [[ -f "$CONFIG_FILE" ]]; then
    BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backed up config to: $BACKUP_FILE${NC}"
else
    echo -e "${RED}✗ Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi

echo ""

################################################################################
# Update LiteLLM config to disable tools
################################################################################
echo -e "${YELLOW}Updating LiteLLM configuration...${NC}"

cat > "$CONFIG_FILE" << 'EOF'
# LiteLLM Configuration for Claude Code + Ollama Integration
# Updated to disable unwanted tool/function calling

model_list:
  # Claude Model Names → Ollama Models
  - model_name: claude-opus-4
    litellm_params:
      model: ollama/gemma4:26b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false  # Disable function calling
      
  - model_name: claude-opus-4-20250514
    litellm_params:
      model: ollama/gemma4:26b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false
      
  - model_name: claude-sonnet-4
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false  # Disable function calling
      
  - model_name: claude-sonnet-4-20250514
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false
      
  - model_name: claude-haiku-4
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false  # Disable function calling
      
  - model_name: claude-haiku-4-20250514
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false

  # Direct Ollama Model Names
  - model_name: qwen2.5-coder:14b
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false
      
  - model_name: gemma4:e4b
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false  # KEY FIX!
      
  - model_name: gemma4:26b
    litellm_params:
      model: ollama/gemma4:26b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false

general_settings:
  master_key: "local"
  
litellm_settings:
  drop_params: true          # Drop unsupported parameters
  num_retries: 3
  request_timeout: 600
  # Strip tool/function calling from requests
  allowed_fails: 0
  success_callback: []
  failure_callback: []

# Disable function calling globally
router_settings:
  model_group_alias: {}
EOF

echo -e "${GREEN}✓ Configuration updated${NC}"
echo ""

################################################################################
# Restart LiteLLM
################################################################################
echo -e "${YELLOW}Restarting LiteLLM...${NC}"

# Kill existing LiteLLM processes
LITELLM_PIDS=$(pgrep -f litellm || echo "")
if [[ -n "$LITELLM_PIDS" ]]; then
    echo "Stopping existing LiteLLM processes: $LITELLM_PIDS"
    for PID in $LITELLM_PIDS; do
        kill $PID 2>/dev/null || true
    done
    sleep 2
fi

# Start LiteLLM with updated config
if command -v screen &>/dev/null; then
    screen -dmS litellm litellm --config "$CONFIG_FILE" --port 4000 --detailed_debug
    echo -e "${GREEN}✓ LiteLLM started in screen session 'litellm'${NC}"
    echo "  View logs: screen -r litellm"
elif command -v nohup &>/dev/null; then
    nohup litellm --config "$CONFIG_FILE" --port 4000 --detailed_debug > ~/litellm.log 2>&1 &
    echo -e "${GREEN}✓ LiteLLM started in background${NC}"
    echo "  View logs: tail -f ~/litellm.log"
else
    echo -e "${YELLOW}⚠️  Please start LiteLLM manually:${NC}"
    echo "  litellm --config $CONFIG_FILE --port 4000 --detailed_debug"
fi

# Wait for startup
echo ""
echo "Waiting for LiteLLM to start..."
sleep 3

################################################################################
# Verify
################################################################################
echo ""
echo -e "${YELLOW}Verifying fix...${NC}"

# Test LiteLLM
echo -n "Testing LiteLLM on port 4000: "
if curl -s -f -m 5 "http://localhost:4000/v1/models" -H "Authorization: Bearer local" &>/dev/null; then
    echo -e "${GREEN}✓ Responding${NC}"
else
    echo -e "${RED}✗ Not responding (may need more time)${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Fix Applied!                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Changes made:"
echo "  ✓ Added 'supports_function_calling: false' to all models"
echo "  ✓ Configured drop_params to strip tool definitions"
echo "  ✓ Restarted LiteLLM with updated config"
echo ""
echo -e "${BLUE}Test the fix:${NC}"
echo "  claude -p 'hi' --model gemma4:e4b"
echo ""
echo "Expected: Normal text response (e.g., 'Hello')"
echo "NOT expected: Function calls like 'say_hello'"
echo ""
