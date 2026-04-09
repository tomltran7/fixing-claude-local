#!/bin/bash

################################################################################
# JSON Spill Analyzer
# Purpose: Specifically test for "JSON spill" issues where models output
#          the prompt template instead of generating responses
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/diagnostics/output"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ANALYSIS_FILE="${OUTPUT_DIR}/json_spill_analysis_${TIMESTAMP}.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}JSON Spill Analyzer${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

{
    echo "=== JSON Spill Analysis ==="
    echo "Timestamp: $(date)"
    echo ""
    
    ############################################################################
    # Test 1: Direct Ollama - Should work perfectly
    ############################################################################
    echo "=== TEST 1: Direct Ollama (Baseline) ==="
    echo "This should work without any JSON spill issues."
    echo ""
    echo "Request:"
    echo 'Model: qwen2.5-coder:14b'
    echo 'Prompt: "Say hello in one word"'
    echo ""
    echo "Response:"
    
    RESPONSE=$(curl -s --max-time 15 http://localhost:11434/api/chat -d '{
      "model": "qwen2.5-coder:14b",
      "messages": [{"role": "user", "content": "Say hello in one word"}],
      "stream": false
    }' 2>&1)
    
    echo "$RESPONSE"
    echo ""
    
    # Check for JSON spill indicators
    if echo "$RESPONSE" | grep -qi "the user said\|respond with\|here is\|as an assistant"; then
        echo "❌ POTENTIAL JSON SPILL DETECTED in Direct Ollama test!"
        echo "   This is unexpected - Ollama should work perfectly."
    elif echo "$RESPONSE" | grep -q '"message"'; then
        echo "✅ Ollama responding correctly (JSON structure found)"
    else
        echo "⚠️  Unexpected response format"
    fi
    echo ""
    echo "---"
    echo ""
    
    ############################################################################
    # Test 2: LiteLLM OpenAI Format
    ############################################################################
    echo "=== TEST 2: LiteLLM (OpenAI Format) ==="
    echo "Testing LiteLLM's OpenAI-compatible endpoint"
    echo ""
    echo "Request:"
    echo 'Endpoint: http://127.0.0.1:8131/v1/chat/completions'
    echo 'Model: qwen2.5-coder:14b'
    echo 'Prompt: "Say hello in one word"'
    echo ""
    echo "Response:"
    
    RESPONSE=$(curl -s --max-time 15 -X POST http://127.0.0.1:8131/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer sk-local-key" \
      -d '{
        "model": "qwen2.5-coder:14b",
        "messages": [{"role": "user", "content": "Say hello in one word"}],
        "max_tokens": 20,
        "stream": false
      }' 2>&1)
    
    echo "$RESPONSE"
    echo ""
    
    # Check for JSON spill
    if echo "$RESPONSE" | grep -qi "the user said\|respond with\|here is\|as an assistant"; then
        echo "❌ JSON SPILL DETECTED in LiteLLM OpenAI format!"
        echo "   Issue: LiteLLM is not properly translating the format"
    elif echo "$RESPONSE" | grep -q '"choices"'; then
        echo "✅ LiteLLM OpenAI format responding correctly"
    else
        echo "⚠️  Unexpected response format"
    fi
    echo ""
    echo "---"
    echo ""
    
    ############################################################################
    # Test 3: LiteLLM Anthropic Format
    ############################################################################
    echo "=== TEST 3: LiteLLM (Anthropic Format) ==="
    echo "Testing LiteLLM's Anthropic-compatible endpoint"
    echo ""
    echo "Request:"
    echo 'Endpoint: http://127.0.0.1:8131/v1/messages'
    echo 'Model: qwen2.5-coder:14b'
    echo 'Prompt: "Say hello in one word"'
    echo ""
    echo "Response:"
    
    RESPONSE=$(curl -s --max-time 15 -X POST http://127.0.0.1:8131/v1/messages \
      -H "Content-Type: application/json" \
      -H "x-api-key: sk-local-key" \
      -H "anthropic-version: 2023-06-01" \
      -d '{
        "model": "qwen2.5-coder:14b",
        "max_tokens": 20,
        "messages": [{"role": "user", "content": "Say hello in one word"}]
      }' 2>&1)
    
    echo "$RESPONSE"
    echo ""
    
    # Check for JSON spill
    if echo "$RESPONSE" | grep -qi "the user said\|respond with\|here is\|as an assistant"; then
        echo "❌ JSON SPILL DETECTED in LiteLLM Anthropic format!"
        echo "   Issue: Anthropic format translation is failing"
    elif echo "$RESPONSE" | grep -q '"content"'; then
        echo "✅ LiteLLM Anthropic format responding correctly"
    else
        echo "⚠️  Unexpected response format"
    fi
    echo ""
    echo "---"
    echo ""
    
    ############################################################################
    # Test 4: Different model (gemma4:e4b)
    ############################################################################
    echo "=== TEST 4: LiteLLM OpenAI Format (Different Model: gemma4:e4b) ==="
    echo "Testing if issue is model-specific"
    echo ""
    
    RESPONSE=$(curl -s --max-time 15 -X POST http://127.0.0.1:8131/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer sk-local-key" \
      -d '{
        "model": "gemma4:e4b",
        "messages": [{"role": "user", "content": "Say hello in one word"}],
        "max_tokens": 20,
        "stream": false
      }' 2>&1)
    
    echo "$RESPONSE"
    echo ""
    
    if echo "$RESPONSE" | grep -qi "the user said\|respond with\|here is\|as an assistant"; then
        echo "❌ JSON SPILL DETECTED with gemma4:e4b too!"
        echo "   Issue affects multiple models - likely LiteLLM configuration"
    elif echo "$RESPONSE" | grep -q '"choices"'; then
        echo "✅ gemma4:e4b responding correctly"
    else
        echo "⚠️  Unexpected response format"
    fi
    echo ""
    echo "---"
    echo ""
    
    ############################################################################
    # Test 5: Streaming vs Non-streaming
    ############################################################################
    echo "=== TEST 5: Streaming Test ==="
    echo "Testing if streaming affects JSON spill"
    echo ""
    
    echo "Non-streaming response:"
    curl -s --max-time 15 -X POST http://127.0.0.1:8131/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer sk-local-key" \
      -d '{
        "model": "qwen2.5-coder:14b",
        "messages": [{"role": "user", "content": "Say hello"}],
        "max_tokens": 10,
        "stream": false
      }' 2>&1
    echo ""
    echo ""
    
    echo "Streaming response (first few chunks):"
    curl -s --max-time 15 -X POST http://127.0.0.1:8131/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer sk-local-key" \
      -d '{
        "model": "qwen2.5-coder:14b",
        "messages": [{"role": "user", "content": "Say hello"}],
        "max_tokens": 10,
        "stream": true
      }' 2>&1 | head -20
    echo ""
    echo "---"
    echo ""
    
    ############################################################################
    # Summary
    ############################################################################
    echo "=== ANALYSIS SUMMARY ==="
    echo ""
    echo "Run the full diagnostics for complete information:"
    echo "  ./collect_diagnostics.sh"
    echo ""
    echo "Check this analysis at:"
    echo "  ${ANALYSIS_FILE}"
    echo ""
    
} | tee "${ANALYSIS_FILE}"

echo ""
echo -e "${GREEN}Analysis complete!${NC}"
echo -e "${BLUE}Results: ${ANALYSIS_FILE}${NC}"
echo ""
echo "Next steps:"
echo "1. Review the analysis above"
echo "2. Run full diagnostics: ./collect_diagnostics.sh"
echo "3. Push to GitHub for Devin's review"
