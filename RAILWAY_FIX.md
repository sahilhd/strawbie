# 🚀 Fix Railway Build Error - "Error creating build plan with Railpack"

This error happens when Railway doesn't know how to build your Node.js project. Here's the fix:

---

## ✅ What I've Already Done

I've created 2 config files to help Railway understand your project:

### 1. **Procfile** - Tells Railway how to start your app
```
web: node server.js
```

### 2. **railway.json** - Railway-specific configuration
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "nixpacks"
  },
  "deploy": {
    "startCommand": "node server.js",
    "restartPolicyMaxRetries": 5
  }
}
```

### 3. **Updated package.json** - Node version specified
```json
"engines": {
  "node": "18.x"
}
```

---

## 🔧 Step-by-Step to Deploy

### 1. **Commit the New Files**

```bash
cd /Users/sahilhanda/Desktop/projects/Daomate/DAOmates
git add youtube-backend/Procfile
git add youtube-backend/railway.json
git commit -m "Add Railway configuration files for deployment"
git push origin main
```

### 2. **In Railway Dashboard**

1. Go to **https://railway.app**
2. Go to your **DAOmates** project
3. Click **Settings** → **Environment**
4. Make sure these variables are set:
   ```
   PORT = 3000
   NODE_ENV = production
   ```

5. Click **Deploy** → **Redeploy** (or wait for auto-deploy after push)

### 3. **Check Logs**

While Railway builds:

1. Click **Logs** tab
2. Watch for messages like:
   ```
   Installing dependencies...
   ✅ npm install successful
   
   Building application...
   ✅ Build successful
   
   Starting application...
   ▶️ Application started on port 3000
   ```

---

## 🆘 If You Still Get Build Error

### Option A: Delete & Redeploy

1. In Railway, go to **Settings** → **Danger Zone**
2. Click **Delete Service**
3. Confirm deletion
4. Click **+ New** → **Deploy from GitHub**
5. Select your repo again
6. Deploy

### Option B: Check Node Version

Railway might not support your Node version. Update:

```bash
cd youtube-backend
# Change this line in package.json:
# "node": "18.x"
# to:
# "node": "16.x" or "20.x"

git add package.json
git commit -m "Update Node version for Railway compatibility"
git push origin main
```

### Option C: Manual Start Command

In Railway dashboard:

1. Go to **Settings** → **Environment**
2. Add a new variable: `START_CMD = node server.js`
3. Go to **Deploy** → **Redeploy**

---

## ✅ Verify Deployment

Once deployed successfully:

### Test Health Endpoint
```bash
curl https://your-railway-url.railway.app/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "YouTube Backend Service is running"
}
```

### Test Music Search
```bash
curl -X POST https://your-railway-url.railway.app/api/search-and-extract \
  -H "Content-Type: application/json" \
  -d '{"query": "lofi music"}'
```

Expected response:
```json
{
  "success": true,
  "audioUrl": "https://r4---...",
  "title": "Lofi Hip Hop...",
  "duration": 3600
}
```

---

## 🔍 Common Build Issues & Fixes

| Error | Fix |
|-------|-----|
| `yt-dlp command not found` | Railway doesn't have system deps. See below. |
| `Cannot find module 'express'` | npm install failed. Check package.json. |
| `Port already in use` | Change PORT in Railway environment variables. |
| `Timeout during build` | Procfile missing. Add it (already done). |

---

## 🛠️ System Dependencies (If Needed)

If `yt-dlp` command doesn't work on Railway, you need to add a build configuration.

### Create `nixpacks.toml` in youtube-backend/:

```toml
[build]
# Install system packages
cmds = ["apt-get update && apt-get install -y python3 python3-pip && pip install yt-dlp"]

# Or simpler - use buildpacks
```

Or update `package.json` postinstall:

```json
"scripts": {
  "postinstall": "python3 -m pip install yt-dlp || true",
  "start": "node server.js",
  "dev": "nodemon server.js"
}
```

---

## 📋 Checklist

- [ ] Procfile created in youtube-backend/
- [ ] railway.json created in youtube-backend/
- [ ] package.json has `"node": "18.x"`
- [ ] Files committed and pushed to GitHub
- [ ] Railway dashboard shows latest commit
- [ ] Environment variables set (PORT, NODE_ENV)
- [ ] Deploy/Redeploy started
- [ ] Logs show successful build
- [ ] Health check responds with 200

---

## 🚀 Next Steps After Successful Deploy

1. ✅ Copy your Railway URL (e.g., `https://your-app.railway.app`)
2. ✅ Update iOS app with backend URL
3. ✅ Test music playback
4. ✅ Celebrate! 🎉

---

## 📞 Need More Help?

Railway Docs: https://docs.railway.app/guides/nodejs
Contact Railway Support: https://railway.app/support

---

**Everything is set up! Try deploying again now.** 🚀

