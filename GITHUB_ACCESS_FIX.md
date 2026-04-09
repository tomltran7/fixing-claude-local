# GitHub SSH Access - Quick Fix Guide

## Current Status
❌ No SSH keys found on this machine  
❌ Cannot push to GitHub

## 🚀 Quick Fix (Run This)

```bash
cd ~/Downloads/claude-debug-toolkit
./setup_github_ssh.sh
```

This script will:
1. ✅ Check for existing SSH keys
2. ✅ Create new SSH key if needed
3. ✅ Add key to SSH agent
4. ✅ Display your public key
5. ✅ Guide you to add it to GitHub
6. ✅ Test the connection

---

## 📝 Manual Steps (If Script Doesn't Work)

### Step 1: Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Press Enter to accept default location, and optionally set a passphrase.

### Step 2: Start SSH Agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Step 3: Copy Your Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the entire output (starts with `ssh-ed25519`).

### Step 4: Add to GitHub

1. Go to: https://github.com/settings/keys
2. Click "New SSH key"
3. Title: `My Mac - $(date +%Y-%m-%d)`
4. Paste the key from Step 3
5. Click "Add SSH key"

### Step 5: Test Connection

```bash
ssh -T git@github.com
```

Expected output:
```
Hi [your-username]! You've successfully authenticated, but GitHub does not provide shell access.
```

### Step 6: Push to GitHub

```bash
cd ~/Downloads/claude-debug-toolkit
git push -u origin main
```

---

## 🔧 Troubleshooting

### Error: "Could not open a connection to your authentication agent"

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Error: "Bad permissions"

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Error: "Repository not found"

The repository might not exist yet:
1. Go to https://github.com/new
2. Repository name: `fixing-claude-local`
3. Private repository
4. Don't initialize with README
5. Create repository
6. Try push again

### Error: "Permission denied (publickey)"

Your key isn't added to GitHub:
1. Verify key is displayed: `cat ~/.ssh/id_ed25519.pub`
2. Go to https://github.com/settings/keys
3. Check if your key is listed
4. If not, add it again
5. Test: `ssh -T git@github.com`

---

## ✅ After SSH is Working

```bash
cd ~/Downloads/claude-debug-toolkit

# Verify git status
git status

# Push to GitHub
./push_to_github.sh

# Or manually:
git push -u origin main
```

---

## 🆘 Alternative: Use HTTPS Instead

If SSH is too problematic, use HTTPS:

```bash
cd ~/Downloads/claude-debug-toolkit

# Change remote to HTTPS
git remote set-url origin https://github.com/tomltran7/fixing-claude-local.git

# Push (will prompt for username/password or token)
git push -u origin main
```

**Note:** You'll need a GitHub Personal Access Token for HTTPS:
1. Go to https://github.com/settings/tokens
2. Generate new token (classic)
3. Select `repo` scope
4. Use token as password when pushing

---

## 📞 Quick Help

**See SSH keys:** `ls -la ~/.ssh/`  
**View public key:** `cat ~/.ssh/id_ed25519.pub`  
**Test GitHub:** `ssh -T git@github.com`  
**Check git remote:** `git remote -v`  

---

**Run the automated setup:**
```bash
./setup_github_ssh.sh
```
