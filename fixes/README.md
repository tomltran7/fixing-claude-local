# 🔧 Fix Scripts - LiteLLM Configuration Issue

These scripts automatically fix the LiteLLM configuration issues identified in the diagnostics.

---

## 🎯 Quick Fix (Recommended)

**Run the complete fix script:**

```bash
cd ~/Downloads/fixing-claude-local
./fixes/fix_litellm_complete.sh
```

**What it does:**
1. ✅ Stops existing LiteLLM process
2. ✅ Generates proper `litellm_config.yaml`
3. ✅ Updates Claude Code `settings.json`
4. ✅ Starts LiteLLM with correct configuration
5. ✅ Verifies everything is working

**Time:** 2-3 minutes

---

## 📋 Individual Fix Scripts

### 1. `discover_litellm_port.sh` - Find LiteLLM Port

**Purpose:** Discovers which port LiteLLM is actually running on

**Usage:**
```bash
./fixes/discover_litellm_port.sh
```

**Output:**
```
=== LiteLLM Port Found: 4000 ===

Testing Endpoints:
GET /v1/models: ✓
GET /health: ✓

Recommendation:
Update Claude settings.json:
  ANTHROPIC_BASE_URL: "http://localhost:4000"
```

**When to use:**
- LiteLLM is running but you don't know the port
- Debugging connection issues

---

### 2. `generate_litellm_config.sh` - Create Configuration

**Purpose:** Generates a proper `litellm_config.yaml` with model mappings

**Usage:**
```bash
./fixes/generate_litellm_config.sh
```

**Creates:** `~/litellm_config.yaml`

**Model Mappings:**
```yaml
claude-opus-4   → gemma4:26b
claude-sonnet-4 → gemma4:e4b
claude-haiku-4  → qwen2.5-coder:14b
```

**When to use:**
- Creating LiteLLM config for the first time
- Resetting to known-good configuration
- Adding new model mappings

---

### 3. `fix_litellm_complete.sh` - Complete Fix ⭐

**Purpose:** Automated end-to-end fix for all LiteLLM issues

**Usage:**
```bash
./fixes/fix_litellm_complete.sh
```

**Steps Performed:**
1. **Stop existing LiteLLM** (kills running processes)
2. **Generate config** (creates `~/litellm_config.yaml`)
3. **Update Claude settings** (modifies `~/.claude/settings.json`)
4. **Start LiteLLM** (launches on port 4000 with proper config)
5. **Verify** (tests Ollama, LiteLLM, and full chain)

**Requirements:**
- `jq` (optional, for automatic settings update)
- `screen` or `nohup` (for background process)

**When to use:**
- First time setup
- After diagnostics show LiteLLM issues
- Quick reset to working state

---

## 🔍 Diagnostic Flow

### **Before Running Fixes:**

```bash
# Run diagnostics to identify issues
cd ~/Downloads/fixing-claude-local
./quick_start.sh
./quick_push.sh
```

**Expected Issues:**
- ❌ LiteLLM not responding on expected port
- ❌ Missing `litellm_config.yaml`
- ❌ Claude settings pointing to wrong port/model

---

### **Apply Fixes:**

```bash
# Run complete fix
./fixes/fix_litellm_complete.sh
```

---

### **Verify Fixes:**

```bash
# Test Claude Code
claude -p "Say hello in one word"

# Run diagnostics again
./quick_start.sh

# Push verification results
./quick_push.sh
```

**Expected Results:**
- ✅ LiteLLM responding on port 4000
- ✅ Configuration file present
- ✅ Claude Code working with local models
- ✅ No JSON spill errors

---

## 📊 Fix Details

### **Configuration File Created**

**Location:** `~/litellm_config.yaml`

**Content:**
```yaml
model_list:
  # Claude API model names → Ollama models
  - model_name: claude-opus-4
    litellm_params:
      model: ollama/gemma4:26b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: claude-sonnet-4
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      
  - model_name: claude-haiku-4
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434
      stream: true

general_settings:
  master_key: "local"
  
litellm_settings:
  drop_params: true
  num_retries: 3
  request_timeout: 600
```

---

### **Claude Settings Updated**

**Location:** `~/.claude/settings.json`

**Changes:**
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:4000",  // ← Updated
    "ANTHROPIC_API_KEY": "local",                   // ← Updated
  },
  "model": "claude-opus-4"                          // ← Updated
}
```

---

### **LiteLLM Startup Command**

```bash
litellm \
  --config ~/litellm_config.yaml \
  --port 4000 \
  --detailed_debug
```

**Runs in background using:**
- `screen` (preferred) - View logs: `screen -r litellm`
- `nohup` (fallback) - View logs: `tail -f ~/litellm.log`

---

## 🆘 Troubleshooting

### **Fix script fails to start LiteLLM**

**Check if port 4000 is already in use:**
```bash
lsof -i :4000
```

**If occupied:**
```bash
# Kill the process using port 4000
lsof -ti :4000 | xargs kill

# Or use a different port
litellm --config ~/litellm_config.yaml --port 8131
# Update Claude settings.json to use 8131
```

---

### **Claude still gets JSON spill errors**

**Test LiteLLM directly:**
```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer local" \
  -d '{
    "model": "claude-opus-4",
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

**Expected:** Valid OpenAI-format JSON response  
**If not:** Check LiteLLM logs for errors

---

### **Permission denied errors**

**Make scripts executable:**
```bash
chmod +x fixes/*.sh
```

---

### **jq command not found**

**Install jq:**
```bash
brew install jq
```

**Or manually update `~/.claude/settings.json`**

---

## 📋 Verification Checklist

After running fixes, verify:

- [ ] **LiteLLM running:** `pgrep -f litellm`
- [ ] **Port 4000 open:** `curl http://localhost:4000/health`
- [ ] **Config exists:** `ls -l ~/litellm_config.yaml`
- [ ] **Ollama working:** `curl http://localhost:11434/api/tags`
- [ ] **LiteLLM responds:** `curl -H "Authorization: Bearer local" http://localhost:4000/v1/models`
- [ ] **Claude works:** `claude -p "test"`
- [ ] **No JSON spill:** Response is actual content, not prompts

---

## 🎯 Summary

### **One-Command Fix:**
```bash
./fixes/fix_litellm_complete.sh
```

### **Manual Fix:**
```bash
# 1. Generate config
./fixes/generate_litellm_config.sh

# 2. Start LiteLLM
litellm --config ~/litellm_config.yaml --port 4000

# 3. Update Claude settings
# Edit ~/.claude/settings.json:
#   ANTHROPIC_BASE_URL: http://localhost:4000
#   ANTHROPIC_API_KEY: local
#   model: claude-opus-4
```

### **Verify:**
```bash
claude -p "Say hello"
```

---

**Ready to fix your LiteLLM setup! 🚀**
