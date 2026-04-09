#!/bin/bash

################################################################################
# Test Hidden Input - See How It Works
################################################################################

echo "=== Testing Hidden Input ==="
echo ""
echo "This demonstrates how the token input works."
echo ""

# Test 1: Normal input (you can see it)
echo "--- Test 1: Normal Input (Visible) ---"
read -p "Type 'hello' and press Enter: " TEST1
echo "You typed: $TEST1"
echo ""

# Test 2: Hidden input (you can't see it)
echo "--- Test 2: Hidden Input (Like Passwords) ---"
echo "Now type 'secret' but you won't see it as you type:"
read -s -p "Type 'secret' and press Enter: " TEST2
echo ""
echo "You typed: $TEST2"
echo ""

# Test 3: Paste a token (simulated)
echo "--- Test 3: Token Paste (How the real script works) ---"
echo "Paste anything (like 'ghp_test123') and press Enter:"
read -s -p "Paste token: " TEST3
echo ""
echo "Token received!"
echo "Length: ${#TEST3} characters"
echo "First 4 chars: ${TEST3:0:4}..."
echo "Last 4 chars: ...${TEST3: -4}"
echo ""

echo "=== All Tests Complete ==="
echo ""
echo "The configure_github_token.sh script works the same way as Test 3!"
