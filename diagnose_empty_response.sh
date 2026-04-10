#!/bin/bash

################################################################################
# Diagnose Empty Response / Function Calling Issue
# Captures what happens when Claude returns function calls instead of text
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/diagnostics/output"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/empty_response_diagnostic_${TIMESTAMP}.txt"

mkdir -p "$OUTPUT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Empty Response Diagnostic                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Testing why Claude returns function calls but no actual response..."
echo ""

{
    echo "==================================================================="
    echo "EMPTY RESPONSE / FUNCTION CALLING DIAGNOSTIC"
    echo "Timestamp: $(date)"
    echo "Issue: Claude returns function calls (e.g., read_file) but no response"
    echo "==================================================================="
    echo ""

    ########################################################################
    # TEST 1: Simple "hi" prompt with gemma4:e4b
    ########################################################################
    echo "=== TEST 1: Simple 'hi' with gemma4:e4b ==="
    echo "Command: claude -p 'hi' --model gemma4:e4b"
    echo ""
    echo "Response:"
    timeout 30 claude -p 'hi' --model gemma4:e4b 2>&1 || echo "Command timed out or failed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 2: Directory review (the problem case)
    ########################################################################
    echo "=== TEST 2: Directory Review with gemma4:e4b (Problem Case) ==="
    echo "Command: claude -p 'please review the current directory' --model gemma4:e4b"
    echo ""
    echo "Response:"
    timeout 30 claude -p 'please review the current directory' --model gemma4:e4b 2>&1 || echo "Command timed out or failed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 3: Same prompts with qwen2.5-coder:14b (for comparison)
    ########################################################################
    echo "=== TEST 3: Simple 'hi' with qwen2.5-coder:14b (Comparison) ==="
    echo "Command: claude -p 'hi' --model qwen2.5-coder:14b"
    echo ""
    echo "Response:"
    timeout 30 claude -p 'hi' --model qwen2.5-coder:14b 2>&1 || echo "Command timed out or failed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    echo "=== TEST 4: Directory Review with qwen2.5-coder:14b (Comparison) ==="
    echo "Command: claude -p 'please review the current directory' --model qwen2.5-coder:14b"
    echo ""
    echo "Response:"
    timeout 30 claude -p 'please review the current directory' --model qwen2.5-coder:14b 2>&1 || echo "Command timed out or failed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 5: Claude with debug mode
    ########################################################################
    echo "=== TEST 5: Debug Mode with gemma4:e4b ==="
    echo "Command: claude -p 'hi' --model gemma4:e4b --debug"
    echo ""
    echo "Response:"
    timeout 30 claude -p 'hi' --model gemma4:e4b --debug 2>&1 || echo "Command timed out or failed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 6: Direct LiteLLM test (bypass Claude Code)
    ########################################################################
    echo "=== TEST 6: Direct LiteLLM with gemma4:e4b (Bypass Claude) ==="
    echo "Testing if LiteLLM itself returns function calls"
    echo ""
    echo "Request:"
    REQUEST='{
      "model": "gemma4:e4b",
      "messages": [
        {"role": "user", "content": "please review the current directory"}
      ],
      "max_tokens": 500
    }'
    echo "$REQUEST" | python3 -m json.tool
    echo ""
    echo "Response:"
    curl -s -X POST http://localhost:4000/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer local" \
      -d "$REQUEST" | python3 -m json.tool 2>&1
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 7: Direct Ollama test (bypass LiteLLM)
    ########################################################################
    echo "=== TEST 7: Direct Ollama with gemma4:e4b (Bypass LiteLLM) ==="
    echo ""
    echo "Response:"
    curl -s http://localhost:11434/api/chat -d '{
      "model": "gemma4:e4b",
      "messages": [
        {"role": "user", "content": "please review the current directory"}
      ],
      "stream": false
    }' | python3 -m json.tool 2>&1
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 8: Check Claude settings
    ########################################################################
    echo "=== TEST 8: Current Claude Settings ==="
    echo "File: ~/.claude/settings.json"
    echo ""
    if [[ -f "$HOME/.claude/settings.json" ]]; then
        cat "$HOME/.claude/settings.json" | python3 -m json.tool 2>&1
    else
        echo "Settings file not found"
    fi
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 9: Check LiteLLM config
    ########################################################################
    echo "=== TEST 9: LiteLLM Configuration ==="
    echo "File: ~/litellm_config.yaml"
    echo ""
    if [[ -f "$HOME/litellm_config.yaml" ]]; then
        cat "$HOME/litellm_config.yaml"
    else
        echo "Config file not found"
    fi
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 10: Interactive mode test
    ########################################################################
    echo "=== TEST 10: Non-print Mode Test ==="
    echo "Testing if interactive mode behaves differently"
    echo ""
    echo "Command: echo 'hi' | claude --model gemma4:e4b"
    echo ""
    echo "Response:"
    timeout 30 bash -c "echo 'hi' | claude --model gemma4:e4b" 2>&1 || echo "Command timed out or failed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # SUMMARY
    ########################################################################
    echo "==================================================================="
    echo "DIAGNOSTIC SUMMARY"
    echo "==================================================================="
    echo ""
    echo "Tests performed:"
    echo "  1. Simple 'hi' with gemma4:e4b"
    echo "  2. Directory review with gemma4:e4b (problem case)"
    echo "  3. Simple 'hi' with qwen2.5-coder:14b (comparison)"
    echo "  4. Directory review with qwen2.5-coder:14b (comparison)"
    echo "  5. Debug mode with gemma4:e4b"
    echo "  6. Direct LiteLLM test (bypass Claude Code)"
    echo "  7. Direct Ollama test (bypass LiteLLM)"
    echo "  8. Current Claude settings"
    echo "  9. LiteLLM configuration"
    echo "  10. Non-print mode test"
    echo ""
    echo "Key things to look for:"
    echo "  - Does response show function calls? (e.g., {\"name\": \"read_file\"})"
    echo "  - Does direct LiteLLM/Ollama work normally?"
    echo "  - Is 'supports_function_calling: false' in LiteLLM config?"
    echo "  - Do different models behave differently?"
    echo ""
    echo "==================================================================="

} | tee "$OUTPUT_FILE"

################################################################################
# AUTO-PUSH TO GITHUB
################################################################################
echo ""
echo -e "${YELLOW}Auto-pushing to GitHub...${NC}"
echo ""

git add "$OUTPUT_FILE"

if git diff --cached --quiet; then
    echo -e "${RED}No changes to commit${NC}"
else
    git commit -m "Empty response diagnostic - ${TIMESTAMP}"
    
    if git push origin main; then
        echo -e "${GREEN}✓ Successfully pushed to GitHub!${NC}"
    else
        echo -e "${RED}✗ Push failed - you may need to run manually:${NC}"
        echo "  git push origin main"
    fi
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Diagnostic Complete & Uploaded!          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Diagnostic saved to: $OUTPUT_FILE"
echo ""
echo -e "${BLUE}Tell Devin:${NC} 'Empty response diagnostic uploaded at ${TIMESTAMP}'"
echo ""
