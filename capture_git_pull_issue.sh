#!/bin/bash

################################################################################
# Capture Git Pull Issue Diagnostic
# Saves all relevant information for Devin to review
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/diagnostics/output"
OUTPUT_FILE="$OUTPUT_DIR/git_pull_issue_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p "$OUTPUT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Git Pull Issue Diagnostic                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Capturing diagnostic information..."
echo "Output will be saved to: $OUTPUT_FILE"
echo ""

{
    echo "==================================================================="
    echo "GIT PULL ISSUE DIAGNOSTIC"
    echo "Timestamp: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "==================================================================="
    echo ""

    ########################################################################
    # 1. CURRENT DIRECTORY
    ########################################################################
    echo "=== 1. CURRENT DIRECTORY ==="
    pwd
    echo ""
    echo "Directory contents:"
    ls -la
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 2. GIT REPOSITORY CHECK
    ########################################################################
    echo "=== 2. GIT REPOSITORY CHECK ==="
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "✓ Inside git repository"
        echo "Git directory: $(git rev-parse --git-dir)"
    else
        echo "✗ NOT in a git repository!"
    fi
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 3. REMOTE CONFIGURATION
    ########################################################################
    echo "=== 3. REMOTE CONFIGURATION ==="
    git remote -v 2>&1 || echo "No remotes configured"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 4. CURRENT BRANCH & COMMITS
    ########################################################################
    echo "=== 4. CURRENT BRANCH & COMMITS ==="
    echo "Branch info:"
    git branch -vv 2>&1 || echo "Cannot get branch info"
    echo ""
    
    echo "Current HEAD commit:"
    git log --oneline -1 2>&1 || echo "Cannot get commit"
    echo "Full commit hash: $(git rev-parse HEAD 2>&1)"
    echo ""
    
    echo "Last 10 commits (local):"
    git log --oneline -10 2>&1 || echo "Cannot get log"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 5. FETCH FROM REMOTE
    ########################################################################
    echo "=== 5. FETCHING FROM REMOTE ==="
    git fetch origin 2>&1
    echo "Fetch completed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 6. REMOTE BRANCH STATUS
    ########################################################################
    echo "=== 6. REMOTE BRANCH STATUS ==="
    echo "Remote HEAD commit (origin/main):"
    git log origin/main --oneline -1 2>&1 || echo "Cannot get remote commit"
    echo "Full commit hash: $(git rev-parse origin/main 2>&1)"
    echo ""
    
    echo "Last 10 commits (origin/main):"
    git log origin/main --oneline -10 2>&1 || echo "Cannot get remote log"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 7. COMMIT COMPARISON
    ########################################################################
    echo "=== 7. COMMIT COMPARISON ==="
    LOCAL_COMMIT=$(git rev-parse HEAD 2>&1)
    REMOTE_COMMIT=$(git rev-parse origin/main 2>&1)
    
    echo "Local HEAD:  $LOCAL_COMMIT"
    echo "Remote HEAD: $REMOTE_COMMIT"
    echo ""
    
    if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
        echo "Status: ✓ Local and remote ARE IN SYNC"
    else
        echo "Status: ✗ Local and remote DIFFER"
        echo ""
        echo "Commits in remote but not local:"
        git log HEAD..origin/main --oneline 2>&1 || echo "None or error"
        echo ""
        echo "Commits in local but not remote:"
        git log origin/main..HEAD --oneline 2>&1 || echo "None or error"
    fi
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 8. GIT STATUS
    ########################################################################
    echo "=== 8. GIT STATUS ==="
    git status 2>&1
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 9. CHECK FOR NEW FILES
    ########################################################################
    echo "=== 9. CHECK FOR NEW FILES (Expected from Recent Push) ==="
    
    EXPECTED_FILES=(
        "diagnose_tool_calling.sh"
        "fixes/fix_tool_calling.sh"
        "TOOL_CALLING_FIX.md"
        "verify_repo_status.sh"
    )
    
    for FILE in "${EXPECTED_FILES[@]}"; do
        if [[ -f "$FILE" ]]; then
            echo "  ✓ $FILE - EXISTS"
            ls -lh "$FILE"
        else
            echo "  ✗ $FILE - MISSING"
        fi
    done
    echo ""
    
    echo "Checking if files exist in Git history:"
    for FILE in "${EXPECTED_FILES[@]}"; do
        if git ls-tree HEAD "$FILE" >/dev/null 2>&1; then
            echo "  ✓ $FILE - IN GIT HISTORY"
        else
            echo "  ✗ $FILE - NOT IN GIT HISTORY"
        fi
    done
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 10. ATTEMPT GIT PULL
    ########################################################################
    echo "=== 10. ATTEMPT GIT PULL ==="
    echo "Running: git pull origin main"
    echo ""
    git pull origin main 2>&1
    echo ""
    echo "Pull completed"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 11. POST-PULL FILE CHECK
    ########################################################################
    echo "=== 11. POST-PULL FILE CHECK ==="
    for FILE in "${EXPECTED_FILES[@]}"; do
        if [[ -f "$FILE" ]]; then
            echo "  ✓ $FILE - EXISTS (after pull)"
        else
            echo "  ✗ $FILE - STILL MISSING (after pull)"
        fi
    done
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 12. GIT LOG AFTER PULL
    ########################################################################
    echo "=== 12. GIT LOG AFTER PULL ==="
    echo "Current HEAD after pull:"
    git log --oneline -1 2>&1
    echo ""
    echo "Last 10 commits after pull:"
    git log --oneline -10 2>&1
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 13. DIRECTORY LISTING
    ########################################################################
    echo "=== 13. COMPLETE DIRECTORY LISTING ==="
    echo "All files in repository:"
    find . -type f -not -path "./.git/*" | sort
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 14. GIT CONFIGURATION
    ########################################################################
    echo "=== 14. GIT CONFIGURATION ==="
    echo "Git version:"
    git --version
    echo ""
    echo "User config:"
    git config user.name 2>&1 || echo "Not set"
    git config user.email 2>&1 || echo "Not set"
    echo ""
    echo "Relevant git config:"
    git config --list | grep -E "(remote|branch|pull)" || echo "None"
    echo ""
    echo "-------------------------------------------------------------------"
    echo ""

    ########################################################################
    # 15. NETWORK/CONNECTIVITY
    ########################################################################
    echo "=== 15. NETWORK CONNECTIVITY ==="
    echo "Testing GitHub connectivity:"
    curl -I https://github.com 2>&1 | head -5 || echo "Cannot reach GitHub"
    echo ""
    echo "Testing repository URL:"
    REPO_URL=$(git config --get remote.origin.url)
    echo "Repository URL: $REPO_URL"
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
    echo "Directory: $(pwd)"
    echo "Local commit: $LOCAL_COMMIT"
    echo "Remote commit: $REMOTE_COMMIT"
    echo "In sync: $(if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then echo 'YES'; else echo 'NO'; fi)"
    echo ""
    echo "Missing files:"
    for FILE in "${EXPECTED_FILES[@]}"; do
        if [[ ! -f "$FILE" ]]; then
            echo "  - $FILE"
        fi
    done
    echo ""
    echo "==================================================================="
    echo "END OF DIAGNOSTIC"
    echo "==================================================================="

} | tee "$OUTPUT_FILE"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Diagnostic Complete!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Output saved to:${NC} $OUTPUT_FILE"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the output above"
echo "  2. Push to GitHub:"
echo "     git add diagnostics/output/"
echo "     git commit -m 'Git pull issue diagnostic'"
echo "     git push origin main"
echo ""
echo "  3. Or use quick push:"
echo "     ./quick_push.sh"
echo ""
echo "  4. Tell Devin: 'Git pull diagnostic uploaded'"
echo ""
