# Claude Local Debugging Toolkit

Systematic debugging toolkit for Claude CLI + LiteLLM + Ollama integration issues.

## 🎯 Purpose

This toolkit helps diagnose "JSON spill" errors and configuration issues when running Claude CLI with local LLM models via LiteLLM and Ollama.

## 📋 Prerequisites

- Git installed
- GitHub access (SSH key or Personal Access Token)
- Claude CLI installed
- Ollama installed
- LiteLLM installed (optional, for testing)

## 🚀 Quick Start

### Step 1: Clone Repository (on your personal machine)

**Option A: SSH (if you have SSH key configured)**
```bash
git clone git@github.com:tomltran7/fixing-claude-local.git
cd fixing-claude-local
chmod +x *.sh
```

**Option B: HTTPS (if using Personal Access Token)**
```bash
git clone https://github.com/tomltran7/fixing-claude-local.git
cd fixing-claude-local
chmod +x *.sh
# Configure your GitHub token securely:
./configure_github_token.sh
```

> 🔒 **Security Note:** Never hardcode tokens! Use `./configure_github_token.sh` to store tokens securely.

### Step 2: Run Full Workflow (Recommended)

**Option A: One Command (Easiest)**
```bash
./run_and_push.sh
```
This does everything: diagnostics → commit → push to GitHub

**Option B: Separate Steps (More Control)**
```bash
# 2a. Run diagnostics
./quick_start.sh

# 2b. Review results
cd diagnostics/output/latest && ls -la

# 2c. Push to GitHub (with confirmation)
./auto_push.sh
```

**Option C: Manual**
```bash
./collect_diagnostics.sh
git add -f diagnostics/output/run_*/
git commit -m "Diagnostics run $(date +%Y%m%d_%H%M%S)"
git push origin main
```

> 💡 **See [PUSH_SCRIPTS_GUIDE.md](PUSH_SCRIPTS_GUIDE.md) for detailed comparison of all push scripts**

### Step 3: Share with Devin

Inform Devin that diagnostics are available. Devin will:
1. Read the diagnostic files
2. Analyze the issues
3. Create new scripts with fixes
4. Commit them back to the repository

### Step 4: Pull Updates & Run Fixes

```bash
git pull
# Run any new scripts Devin provides
./fixes/fix_[issue_name].sh  # Scripts will be created based on findings
```

## 📁 Directory Structure

```
fixing-claude-local/
├── README.md                          # This file
├── PUSH_SCRIPTS_GUIDE.md              # Guide for push scripts
│
├── Scripts (Workflow Automation)
├── collect_diagnostics.sh             # Core diagnostic collection
├── analyze_json_spill.sh              # JSON spill detection tests
├── quick_start.sh                     # Run both diagnostics + analysis
├── run_and_push.sh                    # Full workflow: diagnose → push (one command)
├── auto_push.sh                       # Push to GitHub with confirmation
└── quick_push.sh                      # Instant push (no prompts)
│
├── diagnostics/
│   ├── output/                        # Diagnostic outputs (gitignored except .gitkeep)
│   │   ├── latest -> run_YYYYMMDD_HHMMSS/  # Symlink to latest run
│   │   ├── run_YYYYMMDD_HHMMSS/       # Timestamped diagnostic runs
│   │   │   ├── 01_system_info.txt
│   │   │   ├── 02_installed_tools.txt
│   │   │   ├── 03_config_files.txt
│   │   │   ├── 04_environment_vars.txt
│   │   │   ├── 05_ollama_status.txt
│   │   │   ├── 06_litellm_status.txt
│   │   │   ├── 07_api_tests.txt
│   │   │   └── 08_claude_tests.txt
│   │   └── json_spill_analysis_YYYYMMDD_HHMMSS.txt
│   └── analysis/                      # Devin's analysis (committed)
│       └── findings_YYYYMMDD.md
│
├── fixes/                             # Fix scripts created by Devin
│   └── [auto-generated scripts]
│
└── configs/                           # Sample/corrected configs
    └── [auto-generated configs]
```

## 📊 What Gets Collected

1. **System Information**: OS, memory, disk space
2. **Installed Tools**: Claude CLI, Ollama, LiteLLM versions and locations
3. **Configuration Files**: All Claude and LiteLLM config files
4. **Environment Variables**: All relevant env vars
5. **Ollama Status**: Running processes, available models
6. **LiteLLM Status**: Running processes, health checks
7. **API Tests**: Direct tests of Ollama and LiteLLM endpoints
8. **Claude CLI Tests**: Actual Claude CLI execution with various configs

## 🔒 Security Note

**Diagnostic outputs contain:**
- Environment variables (API keys if set)
- Configuration files (may contain sensitive data)
- System information

**The `.gitignore` is configured to exclude `diagnostics/output/` by default.**

When sharing diagnostics:
1. Review files in `diagnostics/output/latest/` first
2. Redact any sensitive information if needed
3. Manually add specific runs: `git add -f diagnostics/output/run_SPECIFIC/`

## 🐛 Common Issues Addressed

- ✅ "JSON spill" errors (model outputs prompt templates)
- ✅ Claude CLI not reading settings.json
- ✅ LiteLLM format translation issues
- ✅ Model name mismatches
- ✅ Port configuration problems
- ✅ Environment variable conflicts

## 🔄 Iterative Debugging Workflow

```
┌─────────────────────────────────────┐
│ 1. Run collect_diagnostics.sh      │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 2. Push results to GitHub           │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 3. Devin analyzes & creates fixes   │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 4. Pull updates & run fix scripts   │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ 5. Re-run diagnostics to verify     │
└─────────────────────────────────────┘
```

## 📝 Manual Testing

If you want to test endpoints manually:

```bash
# Test Ollama directly
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5-coder:14b",
  "messages": [{"role": "user", "content": "hi"}],
  "stream": false
}'

# Test LiteLLM
curl -X POST http://127.0.0.1:8131/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-local-key" \
  -d '{"model":"qwen2.5-coder:14b","messages":[{"role":"user","content":"hi"}]}'

# Test Claude CLI with env vars
ANTHROPIC_BASE_URL="http://127.0.0.1:8131" \
ANTHROPIC_API_KEY="sk-local-key" \
claude "Say hi"
```

## 🆘 Getting Help

If diagnostics collection fails:
1. Check the error message
2. Ensure all tools are installed
3. Run with bash explicitly: `bash collect_diagnostics.sh`
4. Check file permissions: `chmod +x collect_diagnostics.sh`

## 📄 License

MIT - Feel free to modify and adapt for your needs.

## 👤 Contributors

- Initial setup: Automated debugging system
- Maintained by: tomltran7

---

**Last Updated**: 2026-04-09
