#!/bin/bash

################################################################################
# Complete LiteLLM Fix Script
# Automatically fixes LiteLLM configuration and Claude Code integration
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║     LiteLLM Complete Fix for Claude       ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Step 1: Kill Existing LiteLLM
################################################################################
echo -e "${BOLD}${YELLOW}[Step 1/5] Stopping Existing LiteLLM${NC}"

LITELLM_PIDS=$(pgrep -f litellm || echo "")

if [[ -n "$LITELLM_PIDS" ]]; then
    echo "Found LiteLLM processes: $LITELLM_PIDS"
    for PID in $LITELLM_PIDS; do
        echo "Killing PID $PID..."
        kill $PID || true
        sleep 1
    done
    echo -e "${GREEN}✓ Stopped existing LiteLLM processes${NC}"
else
    echo -e "${YELLOW}No existing LiteLLM processes found${NC}"
fi

echo ""

################################################################################
# Step 2: Generate LiteLLM Configuration
################################################################################
echo -e "${BOLD}${YELLOW}[Step 2/5] Generating LiteLLM Configuration${NC}"

CONFIG_FILE="$HOME/litellm_config.yaml"

if [[ -f "$CONFIG_FILE" ]]; then
    BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Backed up existing config to: $BACKUP_FILE"
fi

cat > "$CONFIG_FILE" << 'EOF'
# LiteLLM Configuration for Claude Code + Ollama Integration

model_list:
  # Claude Model Names → Ollama Models
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

  # Direct Ollama Model Names
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

general_settings:
  master_key: "local"
  
litellm_settings:
  drop_params: true
  num_retries: 3
  request_timeout: 600
EOF

echo -e "${GREEN}✓ Configuration created: $CONFIG_FILE${NC}"
echo ""

################################################################################
# Step 3: Update Claude Code Settings
################################################################################
echo -e "${BOLD}${YELLOW}[Step 3/5] Updating Claude Code Settings${NC}"

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
    BACKUP_SETTINGS="$CLAUDE_SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CLAUDE_SETTINGS" "$BACKUP_SETTINGS"
    echo "Backed up existing settings to: $BACKUP_SETTINGS"
    
    # Update settings using jq if available
    if command -v jq &>/dev/null; then
        jq '.env.ANTHROPIC_BASE_URL = "http://localhost:4000" |
            .env.ANTHROPIC_API_KEY = "local" |
            .model = "claude-opus-4"' \
            "$CLAUDE_SETTINGS" > "${CLAUDE_SETTINGS}.tmp"
        mv "${CLAUDE_SETTINGS}.tmp" "$CLAUDE_SETTINGS"
        echo -e "${GREEN}✓ Updated Claude settings.json${NC}"
    else
        echo -e "${YELLOW}⚠️  jq not found, manual update required${NC}"
        echo "Update $CLAUDE_SETTINGS:"
        echo "  ANTHROPIC_BASE_URL: http://localhost:4000"
        echo "  ANTHROPIC_API_KEY: local"
        echo "  model: claude-opus-4"
    fi
else
    echo -e "${YELLOW}⚠️  Claude settings.json not found at $CLAUDE_SETTINGS${NC}"
fi

echo ""

################################################################################
# Step 4: Start LiteLLM
################################################################################
echo -e "${BOLD}${YELLOW}[Step 4/5] Starting LiteLLM${NC}"

# Check if screen is available for background process
if command -v screen &>/dev/null; then
    echo "Starting LiteLLM in screen session..."
    screen -dmS litellm litellm --config "$CONFIG_FILE" --port 4000 --detailed_debug
    echo -e "${GREEN}✓ LiteLLM started in screen session 'litellm'${NC}"
    echo "  View logs: screen -r litellm"
    echo "  Detach: Ctrl+A, then D"
elif command -v nohup &>/dev/null; then
    echo "Starting LiteLLM with nohup..."
    nohup litellm --config "$CONFIG_FILE" --port 4000 --detailed_debug > ~/litellm.log 2>&1 &
    echo -e "${GREEN}✓ LiteLLM started in background${NC}"
    echo "  View logs: tail -f ~/litellm.log"
else
    echo -e "${YELLOW}⚠️  Please start LiteLLM manually:${NC}"
    echo "  litellm --config $CONFIG_FILE --port 4000 --detailed_debug"
    echo ""
    read -p "Press Enter after starting LiteLLM..."
fi

# Wait for LiteLLM to start
echo ""
echo "Waiting for LiteLLM to start..."
sleep 3

echo ""

################################################################################
# Step 5: Verify Configuration
################################################################################
echo -e "${BOLD}${YELLOW}[Step 5/5] Verifying Configuration${NC}"

# Check if LiteLLM is running
if pgrep -f litellm &>/dev/null; then
    echo -e "${GREEN}✓ LiteLLM process running${NC}"
else
    echo -e "${RED}✗ LiteLLM process not found${NC}"
fi

# Test port 4000
echo -n "Testing port 4000... "
if curl -s -f -m 5 "http://localhost:4000/health" &>/dev/null; then
    echo -e "${GREEN}✓ Responding${NC}"
elif curl -s -f -m 5 "http://localhost:4000/v1/models" &>/dev/null; then
    echo -e "${GREEN}✓ Responding${NC}"
else
    echo -e "${RED}✗ Not responding (may need more time to start)${NC}"
fi

# Test Ollama connection
echo -n "Testing Ollama... "
if curl -s -f -m 2 "http://localhost:11434/api/tags" &>/dev/null; then
    echo -e "${GREEN}✓ Responding${NC}"
else
    echo -e "${RED}✗ Not responding${NC}"
fi

# Test LiteLLM → Ollama with Claude model name
echo ""
echo "Testing LiteLLM with Claude model name..."
TEST_RESPONSE=$(curl -s -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer local" \
  -d '{
    "model": "claude-opus-4",
    "messages": [{"role": "user", "content": "Say hello in one word"}],
    "max_tokens": 10
  }' 2>/dev/null || echo "")

if [[ -n "$TEST_RESPONSE" ]] && echo "$TEST_RESPONSE" | grep -q "content"; then
    echo -e "${GREEN}✓ LiteLLM responding correctly${NC}"
    echo "Response preview:"
    echo "$TEST_RESPONSE" | head -5
else
    echo -e "${YELLOW}⚠️  LiteLLM may need more time to start${NC}"
    echo "Response: $TEST_RESPONSE"
fi

echo ""

################################################################################
# Summary
################################################################################
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║          Fix Applied Successfully!        ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Configuration:"
echo "  ✓ LiteLLM Config: $CONFIG_FILE"
echo "  ✓ LiteLLM Port: 4000"
echo "  ✓ Ollama Port: 11434"
echo "  ✓ Claude Settings: $CLAUDE_SETTINGS"
echo ""
echo "Model Mappings:"
echo "  claude-opus-4   → gemma4:26b"
echo "  claude-sonnet-4 → gemma4:e4b"
echo "  claude-haiku-4  → qwen2.5-coder:14b"
echo ""
echo -e "${BOLD}${BLUE}Testing Claude Code:${NC}"
echo "  cd ~/Downloads/fixing-claude-local"
echo "  claude -p \"Say hello\""
echo ""
echo -e "${BOLD}${BLUE}View LiteLLM Logs:${NC}"
if command -v screen &>/dev/null; then
    echo "  screen -r litellm"
else
    echo "  tail -f ~/litellm.log"
fi
echo ""
echo -e "${BOLD}${BLUE}Run Diagnostics:${NC}"
echo "  cd ~/Downloads/fixing-claude-local"
echo "  ./quick_start.sh"
echo "  ./quick_push.sh"
echo ""
echo -e "${GREEN}Ready to use Claude Code with local models! 🎉${NC}"
