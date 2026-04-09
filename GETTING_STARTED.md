# Getting Started with Claude Local Debugging

## 📦 What's in the Toolkit

This repository contains a systematic debugging toolkit for diagnosing issues with Claude CLI + LiteLLM + Ollama integration.

### Scripts Provided

1. **`quick_start.sh`** - Run this first! Sets up everything and runs initial diagnostics
2. **`collect_diagnostics.sh`** - Comprehensive system diagnostics collector
3. **`analyze_json_spill.sh`** - Specific analyzer for "JSON spill" issues

### Directory Structure

```
fixing-claude-local/
├── quick_start.sh              # Run this first
├── collect_diagnostics.sh      # Main diagnostic script
├── analyze_json_spill.sh       # JSON spill analyzer
├── README.md                   # Full documentation
├── GETTING_STARTED.md          # This file
│
├── diagnostics/
│   ├── output/                 # Your diagnostic runs (not committed)
│   │   └── latest/             # Symlink to most recent run
│   └── analysis/               # Devin's analysis (committed)
│
├── fixes/                      # Fix scripts (created by Devin)
└── configs/                    # Sample configs (created by Devin)
```

---

## 🚀 First Time Setup

### On Your Personal Machine (where you have the issue)

```bash
# 1. Clone the repository
git clone git@github.com:tomltran7/fixing-claude-local.git
cd fixing-claude-local

# 2. Run quick start (does everything)
./quick_start.sh
```

That's it! The quick start script will:
- Make all scripts executable
- Initialize git if needed
- Run full diagnostics
- Run JSON spill analysis
- Show you next steps

---

## 🔄 Iterative Debugging Workflow

### Step 1: Collect Diagnostics (You)

```bash
./collect_diagnostics.sh
```

This creates a timestamped directory with all diagnostic information.

### Step 2: Share with Devin (You)

```bash
# Add ONLY the specific diagnostic run you want to share
git add -f diagnostics/output/run_YYYYMMDD_HHMMSS/
git commit -m "Add diagnostics: $(date)"
git push
```

**Note:** By default, `diagnostics/output/` is gitignored for security. Use `-f` to force-add specific runs.

### Step 3: Devin Analyzes (Automatic)

Devin will:
1. Pull the latest changes
2. Read diagnostic files
3. Identify issues
4. Create fix scripts in `fixes/`
5. Create corrected configs in `configs/`
6. Write analysis in `diagnostics/analysis/`
7. Commit and push back to the repo

### Step 4: Apply Fixes (You)

```bash
# Pull Devin's updates
git pull

# Review the analysis
cat diagnostics/analysis/findings_*.md

# Run fix scripts
./fixes/fix_[issue_name].sh

# If configs were created, review and apply them
cp configs/litellm_config.yaml ~/your-location/

# Re-run diagnostics to verify
./collect_diagnostics.sh
```

### Step 5: Verify & Iterate (You)

If issues persist:
```bash
# Share new diagnostic run
git add -f diagnostics/output/run_YYYYMMDD_HHMMSS/
git commit -m "Diagnostics after fix attempt"
git push

# Wait for Devin's next iteration
git pull
./fixes/[new_fix].sh
```

---

## 🎯 What Gets Diagnosed

### System Level
- OS and environment information
- Installed tools and versions
- Available resources (RAM, disk)

### Configuration
- Claude CLI settings files
- LiteLLM configuration
- Environment variables

### Services
- Ollama status and available models
- LiteLLM proxy status
- Port availability and connectivity

### API Testing
- Direct Ollama API calls
- LiteLLM OpenAI format endpoint
- LiteLLM Anthropic format endpoint
- Claude CLI execution

### JSON Spill Analysis
- Baseline Ollama test
- LiteLLM format translation
- Model-specific issues
- Streaming vs non-streaming
- Response format validation

---

## 🔍 Understanding the Output

### Diagnostic Files

Each diagnostic run creates 8 files:

1. **`00_summary.txt`** - Overview of the diagnostic run
2. **`01_system_info.txt`** - System specs and resources
3. **`02_installed_tools.txt`** - Tool versions and locations
4. **`03_config_files.txt`** - All configuration files
5. **`04_environment_vars.txt`** - Environment variables
6. **`05_ollama_status.txt`** - Ollama service and models
7. **`06_litellm_status.txt`** - LiteLLM proxy status
8. **`07_api_tests.txt`** - API endpoint test results
9. **`08_claude_tests.txt`** - Claude CLI test results

### JSON Spill Analysis

The JSON spill analyzer creates a detailed analysis showing:
- Which endpoints work correctly
- Where JSON spill occurs
- Whether it's model-specific
- Format translation issues

---

## 🛠️ Manual Testing

If you want to test specific things manually:

### Test Ollama Directly
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5-coder:14b",
  "messages": [{"role": "user", "content": "Say hi"}],
  "stream": false
}'
```

### Test LiteLLM
```bash
curl -X POST http://127.0.0.1:8131/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-local-key" \
  -d '{"model":"qwen2.5-coder:14b","messages":[{"role":"user","content":"hi"}]}'
```

### Test Claude CLI
```bash
ANTHROPIC_BASE_URL="http://127.0.0.1:8131" \
ANTHROPIC_API_KEY="sk-local-key" \
claude "Say hi"
```

---

## 🔒 Security Considerations

**Diagnostic files may contain:**
- API keys from environment variables
- Configuration file contents
- System information

**Best practices:**
1. Review files before committing
2. Use `.gitignore` (already configured)
3. Only share specific runs with `-f` flag
4. Redact sensitive info if needed

---

## ❓ Troubleshooting

### Scripts Won't Run
```bash
chmod +x *.sh
./quick_start.sh
```

### No Diagnostic Output
- Check if services are running (Ollama, LiteLLM)
- Verify network connectivity
- Check file permissions

### Git Push Fails
```bash
# Check remote
git remote -v

# If not set, add it
git remote add origin git@github.com:tomltran7/fixing-claude-local.git

# Try pushing again
git push -u origin main
```

---

## 📞 Next Steps

1. **Run diagnostics**: `./quick_start.sh`
2. **Review output**: Check `diagnostics/output/latest/`
3. **Share results**: Commit and push specific diagnostic run
4. **Wait for analysis**: Devin will analyze and create fixes
5. **Apply fixes**: Pull updates and run fix scripts
6. **Verify**: Re-run diagnostics to confirm resolution

---

## 💡 Tips

- Run diagnostics **before** and **after** changes to track progress
- Keep LiteLLM running in debug mode to see real-time logs
- Check Ollama is serving models: `ollama list`
- Test endpoints individually to isolate issues
- Review analysis files to understand root causes

---

**Happy debugging!** 🚀
