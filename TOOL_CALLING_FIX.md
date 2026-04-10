# 🔧 Tool-Calling Issue Fix

## ❓ **The Problem**

When using `gemma4:e4b` model, instead of getting text responses, you get:
```json
{
  "name": "say_hello",
  "args": {}
}
```

This is a **function/tool calling** response instead of a regular chat response.

---

## 🎯 **Quick Fix**

### **On Your Personal Machine:**

```bash
cd ~/Downloads/fixing-claude-local

# Option 1: Run the automated fix (RECOMMENDED)
./fixes/fix_tool_calling.sh

# Then test
claude -p "hi" --model gemma4:e4b
```

**Expected:** `Hello` or similar text  
**NOT:** `"name": "say_hello"`

---

## 🔍 **Diagnosis Script**

If you want to diagnose the issue first:

```bash
./diagnose_tool_calling.sh
```

**This tests:**
1. ✅ Direct LiteLLM (without tools)
2. ✅ Direct Ollama (bypass LiteLLM)
3. ✅ Claude Code with gemma4:e4b (shows the issue)
4. ✅ Claude Code with qwen2.5-coder:14b (comparison)
5. ✅ Current configurations
6. ✅ Model details
7. ✅ Explicit no-tools test

**Output saved to:** `diagnostics/output/tool_calling_diagnostic_*.txt`

---

## 🔧 **What the Fix Does**

### **Updates LiteLLM Configuration:**

**Before:**
```yaml
- model_name: gemma4:e4b
  litellm_params:
    model: ollama/gemma4:e4b
    # No function calling control
```

**After:**
```yaml
- model_name: gemma4:e4b
  litellm_params:
    model: ollama/gemma4:e4b
    supports_function_calling: false  # ← DISABLE TOOLS!
```

**Also adds:**
```yaml
litellm_settings:
  drop_params: true  # Strip tool definitions from requests
```

---

## 🎯 **Why This Happens**

### **The Chain:**
1. Claude Code → sends request with **tool definitions** (even for simple prompts)
2. LiteLLM → forwards tools to Ollama
3. Ollama/gemma4:e4b → sees tools, thinks it should call functions
4. Response → function call instead of text

### **The Fix:**
1. LiteLLM config → `supports_function_calling: false`
2. LiteLLM → **strips tool definitions** before sending to Ollama
3. Ollama → sees clean prompt, responds with text
4. Response → **normal text!** ✅

---

## 📊 **Testing the Fix**

### **After running `./fixes/fix_tool_calling.sh`:**

```bash
# Test 1: Simple prompt
claude -p "hi" --model gemma4:e4b
# Expected: "Hello" or similar

# Test 2: Question
claude -p "What is 2+2?" --model gemma4:e4b
# Expected: "4" or explanation

# Test 3: Code request
claude -p "Write hello world in Python" --model gemma4:e4b
# Expected: Python code, not function call
```

---

## 🆚 **Comparison: With vs Without Fix**

### **WITHOUT FIX:**
```bash
$ claude -p "hi" --model gemma4:e4b
{
  "name": "say_hello",
  "args": {}
}
```
❌ Function call instead of text

### **WITH FIX:**
```bash
$ claude -p "hi" --model gemma4:e4b
Hello! How can I help you today?
```
✅ Normal text response!

---

## 🔄 **Full Workflow**

### **Complete Diagnosis & Fix:**

```bash
cd ~/Downloads/fixing-claude-local

# Step 1: Diagnose (optional but recommended)
./diagnose_tool_calling.sh

# Step 2: Apply fix
./fixes/fix_tool_calling.sh

# Step 3: Test
claude -p "hi" --model gemma4:e4b

# Step 4: Push diagnostics
./quick_push.sh
```

---

## 📋 **What Models Are Affected?**

The fix applies to **all models** in your config:
- ✅ `gemma4:e4b` (the problematic one)
- ✅ `gemma4:26b`
- ✅ `qwen2.5-coder:14b`
- ✅ All Claude model names (`claude-opus-4`, etc.)

**This ensures:**
- No unwanted function calling
- Clean text responses
- Works with Claude Code's tool system when actually needed

---

## 🔍 **Manual Fix (If Scripts Don't Work)**

### **Edit `~/litellm_config.yaml`:**

Add `supports_function_calling: false` to each model:

```yaml
model_list:
  - model_name: gemma4:e4b
    litellm_params:
      model: ollama/gemma4:e4b
      api_base: http://localhost:11434
      stream: true
      supports_function_calling: false  # ← ADD THIS
```

### **Restart LiteLLM:**

```bash
pkill -f litellm
litellm --config ~/litellm_config.yaml --port 4000
```

---

## 🆘 **Troubleshooting**

### **Still getting function calls?**

Check if Claude Code is forcing tools:

```bash
# Test direct to LiteLLM (bypass Claude)
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer local" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma4:e4b",
    "messages": [{"role": "user", "content": "hi"}]
  }'
```

**If this gives normal text:** Claude Code needs additional config  
**If this gives function call:** LiteLLM config not applied

---

### **LiteLLM won't start?**

```bash
# Check port 4000 is free
lsof -i :4000

# If occupied, kill it
lsof -ti :4000 | xargs kill

# Try starting again
./fixes/fix_tool_calling.sh
```

---

## 📚 **Additional Information**

### **Why gemma4 Models Do This:**

Some Gemma models are trained with function-calling capabilities. When they receive a message with tool definitions, they interpret it as a function-calling scenario.

### **The Solution:**

Tell LiteLLM to:
1. Mark models as `supports_function_calling: false`
2. Strip tool definitions before forwarding to Ollama
3. Force text-only responses

---

## ✅ **Success Criteria**

After applying the fix, you should see:

```bash
$ claude -p "hi" --model gemma4:e4b
Hello!
```

**NOT:**
```bash
$ claude -p "hi" --model gemma4:e4b
{"name": "say_hello", "args": {}}
```

---

## 🎯 **Summary**

**Problem:** Models returning function calls instead of text  
**Cause:** Tool definitions being passed to models  
**Solution:** Disable function calling in LiteLLM config  
**Fix Script:** `./fixes/fix_tool_calling.sh`  
**Test:** `claude -p "hi" --model gemma4:e4b`

---

**Ready to fix? Run `./fixes/fix_tool_calling.sh`!** 🚀
