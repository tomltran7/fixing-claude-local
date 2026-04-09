#!/bin/bash

################################################################################
# Claude Local Diagnostics Collector
# Purpose: Collect comprehensive system diagnostics for debugging Claude CLI
#          + LiteLLM + Ollama integration
# Output: Structured diagnostic files in diagnostics/output/
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/diagnostics/output"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RUN_DIR="${OUTPUT_DIR}/run_${TIMESTAMP}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Claude Local Diagnostics v1.0${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Create output directory
mkdir -p "${RUN_DIR}"
echo -e "${GREEN}Output directory: ${RUN_DIR}${NC}"
echo ""

################################################################################
# 1. SYSTEM INFORMATION
################################################################################
echo -e "${YELLOW}[1/8] Collecting System Information...${NC}"
{
    echo "=== System Information ==="
    echo "Timestamp: $(date)"
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -a)"
    echo "Shell: $SHELL"
    echo "User: $USER"
    echo ""
    
    echo "=== Memory ==="
    if command -v free &> /dev/null; then
        free -h
    elif command -v vm_stat &> /dev/null; then
        vm_stat
    fi
    echo ""
    
    echo "=== Disk Space ==="
    df -h | head -10
    echo ""
} > "${RUN_DIR}/01_system_info.txt" 2>&1

################################################################################
# 2. INSTALLED TOOLS
################################################################################
echo -e "${YELLOW}[2/8] Checking Installed Tools...${NC}"
{
    echo "=== Claude CLI ==="
    if command -v claude &> /dev/null; then
        echo "✅ Claude CLI found"
        echo "Location: $(which claude)"
        echo "Type: $(file $(which claude) 2>&1)"
        echo ""
        echo "--- Version ---"
        claude --version 2>&1 || claude version 2>&1 || echo "No version command available"
        echo ""
        echo "--- Help Output ---"
        claude --help 2>&1 | head -50
    else
        echo "❌ Claude CLI not found in PATH"
    fi
    echo ""
    
    echo "=== Ollama ==="
    if command -v ollama &> /dev/null; then
        echo "✅ Ollama found"
        echo "Location: $(which ollama)"
        ollama --version 2>&1
    else
        echo "❌ Ollama not found in PATH"
    fi
    echo ""
    
    echo "=== LiteLLM ==="
    if command -v litellm &> /dev/null; then
        echo "✅ LiteLLM found"
        echo "Location: $(which litellm)"
        litellm --version 2>&1 || echo "Version command not available"
    else
        echo "❌ LiteLLM not found in PATH"
    fi
    echo ""
    
    echo "=== Python ==="
    if command -v python3 &> /dev/null; then
        python3 --version
        echo "Location: $(which python3)"
    fi
    echo ""
    
    echo "=== Node.js ==="
    if command -v node &> /dev/null; then
        node --version
        echo "Location: $(which node)"
    fi
    echo ""
} > "${RUN_DIR}/02_installed_tools.txt" 2>&1

################################################################################
# 3. CONFIGURATION FILES
################################################################################
echo -e "${YELLOW}[3/8] Reading Configuration Files...${NC}"
{
    echo "=== Claude Settings Files ==="
    for loc in ~/.claude/settings.json ~/.config/claude/settings.json ~/.claude/config.json; do
        if [ -f "$loc" ]; then
            echo "✅ Found: $loc"
            echo "Size: $(wc -c < "$loc") bytes"
            echo "Permissions: $(ls -l "$loc" | awk '{print $1}')"
            echo ""
            echo "--- Content ---"
            cat "$loc"
            echo ""
            echo "--- JSON Validation ---"
            if command -v python3 &> /dev/null; then
                python3 -c "import json; json.load(open('$loc'))" 2>&1 && echo "Valid JSON ✅" || echo "Invalid JSON ❌"
            fi
            echo ""
        else
            echo "❌ Not found: $loc"
        fi
        echo "---"
    done
    
    echo ""
    echo "=== LiteLLM Config Files ==="
    for loc in ./litellm_config.yaml ./config.yaml ~/litellm_config.yaml; do
        if [ -f "$loc" ]; then
            echo "✅ Found: $loc"
            echo "--- Content ---"
            cat "$loc"
            echo ""
        else
            echo "❌ Not found: $loc"
        fi
        echo "---"
    done
} > "${RUN_DIR}/03_config_files.txt" 2>&1

################################################################################
# 4. ENVIRONMENT VARIABLES
################################################################################
echo -e "${YELLOW}[4/8] Collecting Environment Variables...${NC}"
{
    echo "=== Anthropic/Claude Environment Variables ==="
    env | grep -i anthropic || echo "No ANTHROPIC_* variables set"
    echo ""
    env | grep -i claude || echo "No CLAUDE_* variables set"
    echo ""
    
    echo "=== LiteLLM Environment Variables ==="
    env | grep -i litellm || echo "No LITELLM_* variables set"
    echo ""
    
    echo "=== All Environment Variables (for reference) ==="
    env | sort
} > "${RUN_DIR}/04_environment_vars.txt" 2>&1

################################################################################
# 5. OLLAMA STATUS
################################################################################
echo -e "${YELLOW}[5/8] Checking Ollama Status...${NC}"
{
    echo "=== Ollama Service Status ==="
    if pgrep -x ollama > /dev/null; then
        echo "✅ Ollama process is running"
        echo "PIDs: $(pgrep -x ollama | tr '\n' ' ')"
    else
        echo "❌ Ollama process not found"
    fi
    echo ""
    
    echo "=== Ollama API Test ==="
    if curl -s --max-time 5 http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✅ Ollama API responding on port 11434"
        echo ""
        echo "--- Available Models ---"
        curl -s http://localhost:11434/api/tags | python3 -m json.tool 2>&1 || curl -s http://localhost:11434/api/tags
    else
        echo "❌ Ollama API not responding on port 11434"
    fi
    echo ""
    
    echo "=== Ollama Model List ==="
    if command -v ollama &> /dev/null; then
        ollama list 2>&1
    else
        echo "Ollama command not available"
    fi
} > "${RUN_DIR}/05_ollama_status.txt" 2>&1

################################################################################
# 6. LITELLM STATUS
################################################################################
echo -e "${YELLOW}[6/8] Checking LiteLLM Status...${NC}"
{
    echo "=== LiteLLM Process Status ==="
    if pgrep -f litellm > /dev/null; then
        echo "✅ LiteLLM process is running"
        echo "PIDs: $(pgrep -f litellm | tr '\n' ' ')"
    else
        echo "❌ LiteLLM process not found"
    fi
    echo ""
    
    echo "=== LiteLLM Port 8131 Test ==="
    if curl -s --max-time 5 http://127.0.0.1:8131/health > /dev/null 2>&1; then
        echo "✅ LiteLLM responding on port 8131"
        echo ""
        echo "--- Health Check ---"
        curl -s http://127.0.0.1:8131/health
        echo ""
    else
        echo "❌ LiteLLM not responding on port 8131"
    fi
    echo ""
    
    echo "=== LiteLLM Models Endpoint ==="
    if curl -s --max-time 5 http://127.0.0.1:8131/v1/models > /dev/null 2>&1; then
        curl -s http://127.0.0.1:8131/v1/models | python3 -m json.tool 2>&1
    else
        echo "Models endpoint not available"
    fi
} > "${RUN_DIR}/06_litellm_status.txt" 2>&1

################################################################################
# 7. API ENDPOINT TESTS
################################################################################
echo -e "${YELLOW}[7/8] Testing API Endpoints...${NC}"
{
    echo "=== Direct Ollama Test (qwen2.5-coder:14b) ==="
    curl -s --max-time 10 http://localhost:11434/api/chat -d '{
      "model": "qwen2.5-coder:14b",
      "messages": [{"role": "user", "content": "Say hi in one word"}],
      "stream": false
    }' 2>&1
    echo ""
    echo ""
    
    echo "=== Direct Ollama Test (gemma4:e4b) ==="
    curl -s --max-time 10 http://localhost:11434/api/chat -d '{
      "model": "gemma4:e4b",
      "messages": [{"role": "user", "content": "Say hi in one word"}],
      "stream": false
    }' 2>&1
    echo ""
    echo ""
    
    echo "=== LiteLLM OpenAI Format Test ==="
    curl -s --max-time 10 -X POST http://127.0.0.1:8131/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer sk-local-key" \
      -d '{
        "model": "qwen2.5-coder:14b",
        "messages": [{"role": "user", "content": "Say hi in one word"}],
        "max_tokens": 10
      }' 2>&1
    echo ""
    echo ""
    
    echo "=== LiteLLM Anthropic Format Test ==="
    curl -s --max-time 10 -X POST http://127.0.0.1:8131/v1/messages \
      -H "Content-Type: application/json" \
      -H "x-api-key: sk-local-key" \
      -H "anthropic-version: 2023-06-01" \
      -d '{
        "model": "qwen2.5-coder:14b",
        "max_tokens": 10,
        "messages": [{"role": "user", "content": "Say hi in one word"}]
      }' 2>&1
    echo ""
} > "${RUN_DIR}/07_api_tests.txt" 2>&1

################################################################################
# 8. CLAUDE CLI TESTS
################################################################################
echo -e "${YELLOW}[8/8] Testing Claude CLI...${NC}"
{
    if command -v claude &> /dev/null; then
        echo "=== Claude CLI Test (with current settings) ==="
        claude "Say hi in one word" 2>&1 || echo "Claude CLI test failed"
        echo ""
        echo ""
        
        echo "=== Claude CLI Test (with explicit env vars) ==="
        ANTHROPIC_BASE_URL="http://127.0.0.1:8131" \
        ANTHROPIC_API_KEY="sk-local-key" \
        ANTHROPIC_MODEL="qwen2.5-coder:14b" \
        claude "Say hi in one word" 2>&1 || echo "Claude CLI test with env vars failed"
        echo ""
    else
        echo "Claude CLI not available - skipping tests"
    fi
} > "${RUN_DIR}/08_claude_tests.txt" 2>&1

################################################################################
# SUMMARY
################################################################################
echo ""
echo -e "${GREEN}✅ Diagnostics collection complete!${NC}"
echo ""
echo -e "${BLUE}Results saved to: ${RUN_DIR}${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the output files in: ${RUN_DIR}"
echo "2. Commit and push to GitHub:"
echo "   cd ${SCRIPT_DIR}"
echo "   git add diagnostics/output/"
echo "   git commit -m 'Add diagnostics run ${TIMESTAMP}'"
echo "   git push"
echo ""
echo "3. Share the run directory with Devin for analysis"
echo ""

# Create summary file
{
    echo "=== Diagnostic Run Summary ==="
    echo "Timestamp: $(date)"
    echo "Run Directory: ${RUN_DIR}"
    echo ""
    echo "Files created:"
    ls -lh "${RUN_DIR}/"
} > "${RUN_DIR}/00_summary.txt"

# Create latest symlink for easy access
ln -sf "${RUN_DIR}" "${OUTPUT_DIR}/latest"

echo -e "${GREEN}You can also check the latest run at: ${OUTPUT_DIR}/latest${NC}"
