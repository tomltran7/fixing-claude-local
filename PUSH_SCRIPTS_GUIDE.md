# 🚀 Push Scripts - Choose Your Workflow

Three automated push scripts are available. Choose based on your needs:

---

## 📊 Quick Comparison

| Script | Speed | Safety | Use When |
|--------|-------|--------|----------|
| **`run_and_push.sh`** | ⭐⭐ Slow | ⭐⭐⭐ Safe | First time / Full workflow |
| **`auto_push.sh`** | ⭐⭐⭐ Fast | ⭐⭐⭐ Safe | After diagnostics, want confirmation |
| **`quick_push.sh`** | ⭐⭐⭐⭐⭐ Instant | ⭐⭐ Medium | Quick re-push, know what you're doing |

---

## 🎯 Script Details

### 1. `run_and_push.sh` - Complete Workflow

**Does:**
1. ✅ Runs full diagnostics
2. ✅ Runs JSON spill analysis
3. ✅ Auto-commits
4. ✅ Auto-pushes

**Command:**
```bash
./run_and_push.sh
```

**Best for:**
- ✅ First time running diagnostics
- ✅ Want everything automated
- ✅ Don't want to remember multiple commands

**Output:**
```
[Step 1/2] Running diagnostics...
  → Collects all system info
  → Tests all endpoints
  → Analyzes JSON spill
[Step 2/2] Pushing to GitHub...
  → Commits with timestamp
  → Pushes to main
✅ All Done!
```

---

### 2. `auto_push.sh` - Push with Confirmation

**Does:**
1. ✅ Shows what will be pushed
2. ⚠️  Asks for confirmation
3. ✅ Commits with detailed message
4. ✅ Pushes to GitHub

**Command:**
```bash
./auto_push.sh
```

**Best for:**
- ✅ Already ran diagnostics separately
- ✅ Want to review before pushing
- ✅ Safety-conscious workflow

**Output:**
```
Files to be added:
  ✓ run_20260409_173045 (8 files, 45K)
  ✓ json_spill_analysis_20260409_173045.txt (12K)

Continue? (y/n) █

[1/3] Adding files...
[2/3] Committing...
[3/3] Pushing...
✅ Successfully pushed!
```

---

### 3. `quick_push.sh` - Instant Push (No Prompts)

**Does:**
1. ✅ Adds diagnostics
2. ✅ Commits (auto message)
3. ✅ Pushes instantly
4. ❌ No confirmations

**Command:**
```bash
./quick_push.sh
```

**Best for:**
- ✅ Re-pushing after fixes
- ✅ Quick iterations
- ✅ You know exactly what's being pushed

**Output:**
```
Quick Push to GitHub...
✅ Pushed! https://github.com/tomltran7/fixing-claude-local
```

---

## 📋 Common Workflows

### **Workflow 1: First Time (Recommended)**

```bash
# One command does everything
./run_and_push.sh
```

---

### **Workflow 2: Separate Steps (More Control)**

```bash
# Step 1: Run diagnostics
./quick_start.sh

# Step 2: Review output
cd diagnostics/output/latest
ls -la
cat 08_claude_tests.txt

# Step 3: Push with confirmation
./auto_push.sh
```

---

### **Workflow 3: Quick Iteration**

```bash
# Run diagnostics
./collect_diagnostics.sh

# Quick push (no prompts)
./quick_push.sh
```

---

### **Workflow 4: After Applying Fixes**

```bash
# Test if fixes worked
./collect_diagnostics.sh

# Quick push results
./quick_push.sh

# Tell Devin: "Pushed verification diagnostics"
```

---

## ⚙️ Manual Alternative (If Scripts Don't Work)

```bash
# Add diagnostics (force add despite .gitignore)
git add -f diagnostics/output/run_*/

# Add JSON spill analyses
git add -f diagnostics/output/json_spill_analysis_*.txt

# Commit with timestamp
git commit -m "Diagnostics run $(date +%Y%m%d_%H%M%S)"

# Push
git push origin main
```

---

## 🔧 Troubleshooting

### **"No diagnostics found"**
Run diagnostics first:
```bash
./quick_start.sh
# OR
./collect_diagnostics.sh
```

### **"No changes to commit"**
Diagnostics already pushed. Run new diagnostics:
```bash
./collect_diagnostics.sh
./quick_push.sh
```

### **"Push failed"**
Check GitHub credentials:
```bash
git remote -v
git pull  # Sync first
./quick_push.sh  # Try again
```

---

## 📊 What Gets Pushed

All scripts push the same files:

```
diagnostics/output/
├── run_TIMESTAMP/           # All diagnostic files
│   ├── 01_system_info.txt
│   ├── 02_installed_tools.txt
│   ├── 03_config_files.txt
│   ├── 04_environment_vars.txt
│   ├── 05_ollama_status.txt
│   ├── 06_litellm_status.txt
│   ├── 07_api_tests.txt
│   └── 08_claude_tests.txt
│
└── json_spill_analysis_TIMESTAMP.txt
```

**Note:** Analysis files from Devin are automatically included if they exist.

---

## 💡 Recommendations

### **First Time User:**
```bash
./run_and_push.sh  # Does everything, can't go wrong
```

### **Experienced User:**
```bash
./quick_push.sh  # Fast, no prompts
```

### **Safety-Conscious:**
```bash
./auto_push.sh  # Shows what's being pushed, asks confirmation
```

---

## 🎯 Summary

**Fastest:** `./run_and_push.sh` (one command, done)  
**Safest:** `./auto_push.sh` (review before push)  
**Quickest:** `./quick_push.sh` (instant, no prompts)

**Can't decide?** Use `./run_and_push.sh` - it's foolproof! 🚀
