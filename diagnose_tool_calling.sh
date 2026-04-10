#!/bin/bash

################################################################################
# Diagnose Tool-Calling Issue with gemma4:e4b
# Investigates why model returns function calls instead of text
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/diagnostics/output/tool_calling_diagnostic_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p "$SCRIPT_DIR/diagnostics/output"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Tool-Calling Issue Diagnostic            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

{
    echo "==================================================================="
    echo "TOOL-CALLING DIAGNOSTIC"
    echo "Timestamp: $(date)"
    echo "==================================================================="
    echo ""

    ########################################################################
    # TEST 1: Direct LiteLLM - gemma4:e4b (no tools)
    ########################################################################
    echo "=== TEST 1: Direct LiteLLM with gemma4:e4b (No Tools) ==="
    echo "Testing: curl to LiteLLM without tool definitions"
    echo ""
    
    curl -s -X POST http://localhost:4000/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer local" \
      -d '{
        "model": "gemma4:e4b",
        "messages": [{"role": "user", "content": "hi"}],
        "max_tokens": 50
      }' | python3 -m json.tool 2>&1 || echo "Request failed"
    
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 2: Direct Ollama - gemma4:e4b (bypass LiteLLM)
    ########################################################################
    echo "=== TEST 2: Direct Ollama with gemma4:e4b (Bypass LiteLLM) ==="
    echo "Testing: curl directly to Ollama"
    echo ""
    
    curl -s http://localhost:11434/api/chat -d '{
      "model": "gemma4:e4b",
      "messages": [{"role": "user", "content": "hi"}],
      "stream": false
    }' | python3 -m json.tool 2>&1 || echo "Request failed"
    
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 3: Claude Code with gemma4:e4b
    ########################################################################
    echo "=== TEST 3: Claude Code with gemma4:e4b ==="
    echo "Testing: claude -p command"
    echo ""
    
    echo "Command: claude -p 'hi' --model gemma4:e4b"
    claude -p "hi" --model gemma4:e4b 2>&1 || echo "Claude command failed"
    
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 4: Claude Code with qwen2.5-coder:14b (for comparison)
    ########################################################################
    echo "=== TEST 4: Claude Code with qwen2.5-coder:14b (Comparison) ==="
    echo "Testing: claude with different model"
    echo ""
    
    echo "Command: claude -p 'hi' --model qwen2.5-coder:14b"
    claude -p "hi" --model qwen2.5-coder:14b 2>&1 || echo "Claude command failed"
    
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 5: Check Current Claude Settings
    ########################################################################
    echo "=== TEST 5: Current Claude Settings ==="
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
    # TEST 6: LiteLLM Config Check
    ########################################################################
    echo "=== TEST 6: LiteLLM Configuration ==="
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
    # TEST 7: Check Ollama Model Details
    ########################################################################
    echo "=== TEST 7: Ollama Model Details for gemma4:e4b ==="
    echo "Command: ollama show gemma4:e4b"
    echo ""
    
    ollama show gemma4:e4b 2>&1 || echo "Cannot show model details"
    
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # TEST 8: LiteLLM with explicit "tools: null"
    ########################################################################
    echo "=== TEST 8: LiteLLM with Explicit No Tools ==="
    echo "Testing: Explicitly setting tools to null"
    echo ""
    
    curl -s -X POST http://localhost:4000/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer local" \
      -d '{
        "model": "gemma4:e4b",
        "messages": [{"role": "user", "content": "hi"}],
        "max_tokens": 50,
        "tools": null
      }' | python3 -m json.tool 2>&1 || echo "Request failed"
    
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # SUMMARY
    ########################################################################
    echo "==================================================================="
    echo "DIAGNOSTIC COMPLETE"
    echo "==================================================================="
    echo ""
    echo "This diagnostic tested:"
    echo "  1. Direct LiteLLM (should work normally)"
    echo "  2. Direct Ollama (bypass LiteLLM)"
    echo "  3. Claude Code with gemma4:e4b (shows the issue)"
    echo "  4. Claude Code with qwen2.5-coder:14b (comparison)"
    echo "  5. Current Claude settings"
    echo "  6. LiteLLM configuration"
    echo "  7. Ollama model details"
    echo "  8. LiteLLM with explicit no tools"
    echo ""
    echo "Results saved to: $OUTPUT_FILE"
    echo ""
    echo "==================================================================="

} | tee "$OUTPUT_FILE"

echo ""
echo -e "${GREEN}Diagnostic complete!${NC}"
echo -e "${BLUE}Output saved to:${NC} $OUTPUT_FILE"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the output above"
echo "  2. Push results: ./quick_push.sh"
echo "  3. Report to Devin: 'Tool-calling diagnostic uploaded'"
echo ""
