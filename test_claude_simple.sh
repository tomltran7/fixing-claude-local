#!/bin/bash

################################################################################
# Simple Claude Test - No Timeout (macOS compatible)
# Captures actual Claude Code output
################################################################################

OUTPUT_FILE="diagnostics/output/claude_test_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p diagnostics/output

echo "==================================================================="
echo "SIMPLE CLAUDE CODE TEST"
echo "Testing: claude -p with gemma4:e4b"
echo "==================================================================="
echo ""

{
    echo "=== TEST 1: Simple 'hi' with gemma4:e4b ==="
    echo "Command: claude -p 'hi' --model gemma4:e4b"
    echo ""
    echo "Response:"
    claude -p 'hi' --model gemma4:e4b 2>&1
    echo ""
    echo "---"
    echo ""
    
    echo "=== TEST 2: Directory review with gemma4:e4b ==="
    echo "Command: claude -p 'please review the current directory' --model gemma4:e4b"
    echo ""
    echo "Response:"
    claude -p 'please review the current directory' --model gemma4:e4b 2>&1
    echo ""
    echo "---"
    echo ""
    
    echo "=== TEST 3: With --debug flag ==="
    echo "Command: claude -p 'hi' --model gemma4:e4b --debug"
    echo ""
    echo "Response:"
    claude -p 'hi' --model gemma4:e4b --debug 2>&1
    echo ""
    echo "---"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo ""
echo "Output saved to: $OUTPUT_FILE"
echo ""
echo "Pushing to GitHub..."
git add -f "$OUTPUT_FILE"
git commit -m "Claude Code test output - $(date +%Y%m%d_%H%M%S)"
git push origin main

echo ""
echo "Done! Tell Devin: 'Claude test output uploaded'"
