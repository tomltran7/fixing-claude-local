#!/bin/bash

################################################################################
# All-in-One: Diagnose Git Pull Issue & Auto-Push
# Runs diagnostic, commits, and pushes automatically
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/diagnostics/output"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/git_pull_issue_${TIMESTAMP}.txt"

mkdir -p "$OUTPUT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║   Git Pull Diagnostic - Auto Push          ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# STEP 1: RUN DIAGNOSTIC
################################################################################
echo -e "${YELLOW}[Step 1/3] Running diagnostic...${NC}"
echo ""

{
    echo "==================================================================="
    echo "GIT PULL ISSUE DIAGNOSTIC (AUTO-PUSH VERSION)"
    echo "Timestamp: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "==================================================================="
    echo ""

    echo "=== CURRENT DIRECTORY ==="
    pwd
    echo ""
    ls -la
    echo ""

    echo "=== GIT REPOSITORY CHECK ==="
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "✓ Inside git repository"
    else
        echo "✗ NOT in a git repository!"
        exit 1
    fi
    echo ""

    echo "=== REMOTE CONFIGURATION ==="
    git remote -v
    echo ""

    echo "=== CURRENT BRANCH & COMMITS ==="
    git branch -vv
    echo ""
    echo "Current HEAD:"
    git log --oneline -1
    echo "Hash: $(git rev-parse HEAD)"
    echo ""

    echo "=== FETCHING FROM REMOTE ==="
    git fetch origin 2>&1
    echo ""

    echo "=== REMOTE vs LOCAL COMMITS ==="
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse origin/main)
    echo "Local:  $LOCAL_COMMIT"
    echo "Remote: $REMOTE_COMMIT"
    echo ""
    if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
        echo "Status: ✓ IN SYNC"
    else
        echo "Status: ✗ OUT OF SYNC"
        echo ""
        echo "Commits behind remote:"
        git log HEAD..origin/main --oneline
    fi
    echo ""

    echo "=== EXPECTED FILES CHECK ==="
    EXPECTED_FILES=(
        "diagnose_tool_calling.sh"
        "fixes/fix_tool_calling.sh"
        "TOOL_CALLING_FIX.md"
        "verify_repo_status.sh"
        "capture_git_pull_issue.sh"
    )
    
    for FILE in "${EXPECTED_FILES[@]}"; do
        if [[ -f "$FILE" ]]; then
            echo "  ✓ $FILE - EXISTS"
        else
            echo "  ✗ $FILE - MISSING"
        fi
    done
    echo ""

    echo "=== GIT STATUS ==="
    git status
    echo ""

    echo "=== ATTEMPT GIT PULL ==="
    git pull origin main 2>&1
    echo ""

    echo "=== POST-PULL FILE CHECK ==="
    for FILE in "${EXPECTED_FILES[@]}"; do
        if [[ -f "$FILE" ]]; then
            echo "  ✓ $FILE"
        else
            echo "  ✗ $FILE - STILL MISSING"
        fi
    done
    echo ""

    echo "=== COMPLETE FILE LISTING ==="
    find . -type f -not -path "./.git/*" -not -path "*/node_modules/*" | sort
    echo ""

    echo "==================================================================="
    echo "END OF DIAGNOSTIC"
    echo "==================================================================="

} > "$OUTPUT_FILE" 2>&1

echo -e "${GREEN}✓ Diagnostic complete${NC}"
echo "Saved to: $OUTPUT_FILE"
echo ""

################################################################################
# STEP 2: COMMIT THE DIAGNOSTIC
################################################################################
echo -e "${YELLOW}[Step 2/3] Committing diagnostic...${NC}"

git add "$OUTPUT_FILE"

if git diff --cached --quiet; then
    echo -e "${RED}✗ No changes to commit (file already committed?)${NC}"
else
    git commit -m "Git pull diagnostic - ${TIMESTAMP}" 2>&1
    echo -e "${GREEN}✓ Committed${NC}"
fi
echo ""

################################################################################
# STEP 3: PUSH TO GITHUB
################################################################################
echo -e "${YELLOW}[Step 3/3] Pushing to GitHub...${NC}"

if git push origin main 2>&1; then
    echo -e "${GREEN}✓ Successfully pushed!${NC}"
else
    echo -e "${RED}✗ Push failed${NC}"
    echo "You may need to configure GitHub authentication"
    exit 1
fi
echo ""

################################################################################
# SUMMARY
################################################################################
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║          Diagnostic Uploaded!              ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "What happened:"
echo "  ✓ Ran comprehensive git diagnostic"
echo "  ✓ Saved to: diagnostics/output/git_pull_issue_${TIMESTAMP}.txt"
echo "  ✓ Committed to git"
echo "  ✓ Pushed to GitHub"
echo ""
echo -e "${BLUE}Next step:${NC}"
echo "  Tell Devin: 'Git pull diagnostic uploaded at ${TIMESTAMP}'"
echo ""
echo "Repository: https://github.com/tomltran7/fixing-claude-local"
echo ""

# Also show a preview of what was captured
echo -e "${YELLOW}Preview of diagnostic:${NC}"
echo "---"
tail -20 "$OUTPUT_FILE"
echo "---"
echo ""
echo "Full diagnostic available in: $OUTPUT_FILE"
