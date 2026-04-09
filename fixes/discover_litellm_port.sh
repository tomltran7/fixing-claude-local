#!/bin/bash

################################################################################
# LiteLLM Port Discovery Script
# Finds which port LiteLLM is actually running on
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== LiteLLM Port Discovery ===${NC}"
echo ""

################################################################################
# Find LiteLLM Process
################################################################################
echo -e "${YELLOW}Step 1: Finding LiteLLM Process${NC}"

LITELLM_PIDS=$(pgrep -f litellm || echo "")

if [[ -z "$LITELLM_PIDS" ]]; then
    echo -e "${RED}❌ LiteLLM process not running${NC}"
    echo ""
    echo "To start LiteLLM:"
    echo "  litellm --config ~/litellm_config.yaml --port 4000"
    exit 1
fi

echo -e "${GREEN}✓ LiteLLM running (PID: $LITELLM_PIDS)${NC}"
echo ""

################################################################################
# Check Listening Ports
################################################################################
echo -e "${YELLOW}Step 2: Checking Listening Ports${NC}"

for PID in $LITELLM_PIDS; do
    echo "Checking PID $PID..."
    
    # Method 1: lsof
    if command -v lsof &>/dev/null; then
        PORTS=$(lsof -nP -p $PID 2>/dev/null | grep LISTEN | awk '{print $9}' | cut -d: -f2 | sort -u)
        
        if [[ -n "$PORTS" ]]; then
            echo -e "${GREEN}Found listening ports:${NC}"
            for PORT in $PORTS; do
                echo "  - Port $PORT"
            done
        fi
    fi
done

echo ""

################################################################################
# Test Common Ports
################################################################################
echo -e "${YELLOW}Step 3: Testing Common Ports${NC}"

PORTS_TO_TEST="4000 8000 8080 8131 3000 5000"

for PORT in $PORTS_TO_TEST; do
    echo -n "Port $PORT: "
    
    # Test /health endpoint
    if curl -s -f -m 2 "http://localhost:$PORT/health" &>/dev/null; then
        echo -e "${GREEN}✓ Responding (health check)${NC}"
        LITELLM_PORT=$PORT
        continue
    fi
    
    # Test /v1/models endpoint
    if curl -s -f -m 2 "http://localhost:$PORT/v1/models" &>/dev/null; then
        echo -e "${GREEN}✓ Responding (models endpoint)${NC}"
        LITELLM_PORT=$PORT
        continue
    fi
    
    # Test connection
    if nc -z -w 1 localhost $PORT 2>/dev/null; then
        echo -e "${YELLOW}? Port open (unknown endpoint)${NC}"
    else
        echo -e "${RED}✗ Not responding${NC}"
    fi
done

echo ""

################################################################################
# Test Specific Endpoints on Found Port
################################################################################
if [[ -n "$LITELLM_PORT" ]]; then
    echo -e "${GREEN}=== LiteLLM Port Found: $LITELLM_PORT ===${NC}"
    echo ""
    
    echo -e "${YELLOW}Testing Endpoints:${NC}"
    
    # Test /models
    echo -n "GET /v1/models: "
    if MODELS=$(curl -s "http://localhost:$LITELLM_PORT/v1/models" 2>/dev/null); then
        echo -e "${GREEN}✓${NC}"
        echo "$MODELS" | head -20
    else
        echo -e "${RED}✗${NC}"
    fi
    
    echo ""
    
    # Test /health
    echo -n "GET /health: "
    if HEALTH=$(curl -s "http://localhost:$LITELLM_PORT/health" 2>/dev/null); then
        echo -e "${GREEN}✓${NC}"
        echo "$HEALTH"
    else
        echo -e "${RED}✗${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Recommendation:${NC}"
    echo "Update Claude settings.json:"
    echo "  ANTHROPIC_BASE_URL: \"http://localhost:$LITELLM_PORT\""
    
else
    echo -e "${RED}=== LiteLLM Port Not Found ===${NC}"
    echo ""
    echo "LiteLLM is running but not responding on any standard port."
    echo ""
    echo "Possible issues:"
    echo "  1. LiteLLM started without --port flag"
    echo "  2. Firewall blocking connections"
    echo "  3. LiteLLM crashed but process still exists"
    echo ""
    echo "Recommended action:"
    echo "  1. Kill LiteLLM: kill $LITELLM_PIDS"
    echo "  2. Start properly: litellm --config ~/litellm_config.yaml --port 4000"
fi

echo ""
echo -e "${BLUE}=== Discovery Complete ===${NC}"
