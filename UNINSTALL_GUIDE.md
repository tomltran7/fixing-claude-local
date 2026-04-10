# Uninstall Claude Code CLI

## 🚀 Quick Uninstall (Automated)

```bash
./uninstall_claude_code.sh
```

This script will:
- ✅ Detect installation method
- ✅ Uninstall Claude Code
- ✅ Optionally remove configuration
- ✅ Optionally remove LiteLLM
- ✅ Backup configs before deletion

---

## 📋 Manual Uninstall (Quick)

### **Check how Claude was installed:**

```bash
which claude
```

### **Uninstall based on method:**

#### **If installed via Homebrew:**
```bash
brew uninstall claude
```

#### **If installed via npm:**
```bash
npm uninstall -g claude
```

#### **If manual installation:**
```bash
# Remove the binary
sudo rm $(which claude)
```

### **Remove configuration (optional):**
```bash
# Backup first
cp -r ~/.claude ~/claude_backup

# Remove
rm -rf ~/.claude
rm -rf ~/.config/claude
```

### **Remove LiteLLM (optional):**
```bash
pip3 uninstall litellm
rm ~/litellm_config.yaml
```

---

## 🔍 What Gets Removed

### **Claude Code Binary:**
- Location: `/usr/local/bin/claude` or `/opt/homebrew/bin/claude`
- Or: Wherever `which claude` points to

### **Configuration Files:**
- `~/.claude/` - Settings, session history
- `~/.config/claude/` - Additional config
- Typically ~few MB

### **LiteLLM (if you remove it):**
- Python package
- `~/litellm_config.yaml`

### **What Stays:**
- ✅ Ollama (still useful for other tools)
- ✅ Your local models
- ✅ This debugging toolkit

---

## ⚠️ Before Uninstalling

**If you just want to fix the gemma4:e4b issue**, you don't need to uninstall!

**Instead, just switch models:**
```bash
./fixes/fix_switch_model.sh
```

This switches to `qwen2.5-coder:14b` which works correctly.

---

## 🎯 Alternatives to Claude Code

If you're uninstalling because of issues, consider these alternatives:

### **1. Devin CLI** (What I am!)
```bash
# Visit: https://cli.devin.ai
```
- ✅ Free tier available
- ✅ Terminal-based
- ✅ Supports local models via MCP

### **2. Aider**
```bash
pip install aider-chat
```
- ✅ Free and open source
- ✅ Works with local models
- ✅ Git integration

### **3. Continue.dev**
```bash
# VS Code extension
# Visit: https://continue.dev
```
- ✅ IDE integration
- ✅ Supports local models
- ✅ Free

---

## 🔄 Reinstall Later

If you want to try Claude Code again:

1. Visit: https://claude.ai/download
2. Download for your platform
3. Install
4. Configure with local models using this toolkit

---

## 💡 Why Uninstall?

**Common reasons:**
- ❌ gemma4:e4b model issues (structural output)
- ❌ Prefer other tools
- ❌ Don't want to pay for Claude API
- ❌ Switching to different workflow

**Solution without uninstalling:**
- Just use `qwen2.5-coder:14b` instead
- Or use Ollama directly
- Keep for occasional use

---

## 📋 Uninstall Checklist

- [ ] Backup important conversations/sessions
- [ ] Run `./uninstall_claude_code.sh` or manual commands
- [ ] Verify removal: `which claude` (should return nothing)
- [ ] Decide on LiteLLM (keep if using other tools)
- [ ] Keep Ollama (useful for many AI tools)

---

**To uninstall, just run:** `./uninstall_claude_code.sh` 🗑️
