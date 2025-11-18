# 🚀 Final Fix for Railway: Set Service Root Directory

The issue is that Railway is analyzing the entire DAOmates directory (with Swift files, Xcode project, etc.) instead of just the `youtube-backend` folder.

**Solution: Tell Railway to use `youtube-backend` as the service root directory.**

---

## ✅ What I've Created

Configuration files to help Railway:

1. ✅ `nixpacks.toml` - Tells Nixpacks builder to use youtube-backend
2. ✅ `.railwayrc` - Alternative Railway configuration format
3. ✅ `youtube-backend/.railwayrc` - Backend-specific config
4. ✅ Already have: `Procfile`, `railway.json`, `start.sh`

---

## 🔧 THE FIX: In Railway Dashboard

This is the most reliable method:

### Step 1: Go to Your Service

1. Open https://railway.app
2. Click **DAOmates** project
3. Click the **youtube-backend service** (or create one if missing)

### Step 2: Configure the Service

1. Go to **Settings** tab
2. Scroll down to **Root Directory** (or **Service Root Directory**)
3. Enter: `youtube-backend`
4. Click **Save**

### Step 3: Set Environment Variables

1. Click **Variables** tab
2. Add these:
   ```
   PORT = 3000
   NODE_ENV = production
   ```
3. Click **Save**

### Step 4: Redeploy

1. Click **Deployments** tab
2. Find the failed deployment
3. Click the **X** to delete it (or just redeploy)
4. Click **Deploy** → **Redeploy**
5. Or wait for auto-redeploy after pushing

### Step 5: Watch Logs

Click **Logs** tab and watch for:

```
✅ using build driver railpack-v0.12.0
✅ Detected language: Node
✅ Detected Node.js
✅ npm install
✅ npm run build (if applicable)
✅ Listening on port 3000
✅ YouTube Backend Service is running
```

---

## ✅ If Step 2-4 Above Don't Work

Try this alternative approach in Railway Settings:

1. Go to **Settings**
2. Find **Build Command** (or create it)
   - Set to: `npm install`
3. Find **Start Command** (or create it)
   - Set to: `node server.js`
4. Find **Root Directory** or **Service Root Directory**
   - Set to: `youtube-backend`
5. Click **Redeploy**

---

## 📝 Full Manual Configuration

If Railway UI doesn't show these options, create environment variables:

| Variable | Value |
|----------|-------|
| `PORT` | `3000` |
| `NODE_ENV` | `production` |
| `RAILWAY_SERVICE_ROOT` | `youtube-backend` |

---

## 🧪 Test After Deploy

Once the build succeeds:

### Get Your Railway URL

Railway shows it in the Deployments tab, like:
```
https://youtube-backend-production-xxxx.railway.app
```

### Test the Health Endpoint

```bash
curl https://your-railway-url.railway.app/health
```

Expected response:
```json
{"status":"ok","message":"YouTube Backend Service is running"}
```

### Test Music Search

```bash
curl -X POST https://your-railway-url.railway.app/api/search-and-extract \
  -H "Content-Type: application/json" \
  -d '{"query": "lofi music"}'
```

Expected response (with audioUrl):
```json
{
  "success": true,
  "audioUrl": "https://r4---...stream.url...",
  "title": "Lofi Hip Hop...",
  "duration": 3600
}
```

---

## 📋 Troubleshooting

| Issue | Solution |
|-------|----------|
| Still says "Script start.sh not found" | Delete and recreate the service in Railway |
| "Detected language: Static" | Make sure Root Directory is `youtube-backend` |
| "npm: command not found" | Node wasn't detected - check Root Directory setting |
| Build times out | Increase timeout or check for network issues |

---

## 🆘 Nuclear Option: Delete & Recreate Service

If nothing works:

1. Go to Railway project
2. Click the **youtube-backend** service
3. Go to **Settings** → **Danger Zone**
4. Click **Delete Service**
5. Click **+ New** → **Empty Service**
6. Name it: `youtube-backend`
7. Go to **Deploy**
8. Connect to your GitHub repo
9. Select **youtube-backend** folder specifically
10. Click **Deploy**

---

## 📚 Railway Documentation

- Setting Root Directory: https://docs.railway.app/reference/configure-deployment
- Nixpacks Config: https://docs.railway.app/reference/environment-variables
- Build & Deploy: https://docs.railway.app/guides/deployments

---

## ✅ Checklist

- [ ] Committed all config files (Procfile, railway.json, nixpacks.toml, etc.)
- [ ] Pushed to GitHub
- [ ] Went to Railway → Settings
- [ ] Set **Root Directory** to `youtube-backend`
- [ ] Set environment variables (PORT, NODE_ENV)
- [ ] Clicked **Redeploy**
- [ ] Watched logs for success
- [ ] Got the Railway URL
- [ ] Tested /health endpoint
- [ ] Ready to update iOS app!

---

**Once deployment succeeds, you'll have your backend URL ready to integrate into the iOS app!** 🎉

