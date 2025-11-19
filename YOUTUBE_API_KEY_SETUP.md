# 🔑 YouTube API Key Setup Guide

Complete step-by-step instructions for getting and configuring your YouTube API key.

## Prerequisites

- Google Account
- Access to Google Cloud Console

## Step 1: Create Google Cloud Project

### 1.1 Open Google Cloud Console

Visit: https://console.cloud.google.com/

### 1.2 Create New Project

```
Top left dropdown (currently "Select a project") 
→ Click "NEW PROJECT"
→ Project name: "DAOmates" (or your choice)
→ Click "CREATE"
```

**Wait 30 seconds** for project to be created.

### 1.3 Select Your Project

```
Dropdown → Select "DAOmates" project
You should see the project name in the breadcrumb
```

## Step 2: Enable YouTube Data API v3

### 2.1 Open API Library

```
Left sidebar → "APIs & Services"
→ "Library"
```

### 2.2 Search for YouTube

```
Search box at top → Type "YouTube Data API v3"
→ Click on "YouTube Data API v3" result
```

### 2.3 Enable the API

```
Click "ENABLE" button
→ Wait for API to be enabled (~1-2 seconds)
You should see "Status: ENABLED"
```

## Step 3: Create API Key

### 3.1 Create Credentials

```
Left sidebar → "APIs & Services"
→ "Credentials"
```

### 3.2 Create API Key

```
Click "Create Credentials" button at top
→ Select "API Key"
```

**Your API key will appear in a popup!** ⚠️

### 3.3 Copy Your Key

```
You'll see something like:
AIzaSyD_...[long string]...

Copy the entire key
Save it somewhere safe (notepad, password manager, etc.)
```

### 3.4 Close the Dialog

```
Click "Close" to dismiss the dialog
```

## Step 4: Configure Xcode

### Option A: Environment Variable (Recommended ⭐)

**Pros**: 
- Key not in code
- Easy to switch between dev/prod keys
- Never accidentally commits to git

**Steps**:

1. In Xcode, click on your scheme (top left)

```
Product → Scheme → Edit Scheme
```

2. Select "Run" on the left

3. Go to "Pre-actions" tab

4. Click "+" to add new pre-action

5. In the script box, add:

```bash
export YOUTUBE_API_KEY="YOUR_API_KEY_HERE"
```

Replace `YOUR_API_KEY_HERE` with your actual key.

6. Make sure "Provide build settings from" is set to "DAOmates" (or your target)

7. Click "Close"

### Option B: Info.plist (Alternative)

**Pros**: 
- Key included in app bundle
- Always available

**Cons**: 
- Key visible in source code
- Must add to .gitignore

**Steps**:

1. Open `Info.plist` in Xcode

2. Right-click and select "Add Row"

3. Set key name: `YOUTUBE_API_KEY`

4. Set value: Your API key

5. Result:

```xml
<key>YOUTUBE_API_KEY</key>
<string>AIzaSyD_...</string>
```

**Add to .gitignore**:

```bash
# .gitignore
Info.plist
```

### Option C: Environment File (Advanced)

Create `.env` file:

```
YOUTUBE_API_KEY=AIzaSyD_...
```

Build script reads and exports:

```bash
set -a
source "${PROJECT_DIR}/.env"
set +a
```

Add to .gitignore:

```
.env
```

## Step 5: Verify Setup

### 5.1 Clean Build Folder

```
Xcode → Product → Clean Build Folder (or ⇧⌘K)
```

### 5.2 Run the App

```
Xcode → Product → Run (or ⌘R)
```

### 5.3 Check Console Output

Look for one of:

✅ **Success** (Environment variable):
```
✅ Using YouTube API key for development
```

✅ **Success** (Info.plist):
```
✅ YouTube API key loaded from Info.plist
```

⚠️ **Warning** (Not configured):
```
⚠️ Warning: No YouTube API key found.
📝 To use YouTube music, set YOUTUBE_API_KEY environment variable or Info.plist
```

### 5.4 Test Music Search

1. Run the app
2. Go to chat
3. Type: "play lofi beats"
4. Check console for:

```
🔍 Searching YouTube for: lofi beats
✅ Found 10 YouTube tracks
🎵 Now playing: Best Lofi Mix...
```

## Step 6: Restrict Your API Key (Security)

### 6.1 Open Credentials

```
Google Cloud Console → APIs & Services → Credentials
```

### 6.2 Find Your API Key

```
Under "API keys" section
Click on your API key
```

### 6.3 Configure Restrictions

**Application restrictions**:
```
Select "iOS apps"
Add your bundle ID: com.yourdomain.daomates
```

**API restrictions**:
```
Select "YouTube Data API v3"
Click "Restrict Key"
```

### 6.4 Save

```
Click "Save" at bottom
```

## Troubleshooting

### API Key Not Being Found

**Problem**: Console shows warning about missing key

**Solutions**:
1. Verify environment variable is set exactly as shown
2. Clean build folder: ⇧⌘K
3. Restart Xcode completely
4. Check Info.plist if using that method
5. Rebuild project: ⌘B

### "YouTube API error"

**Problem**: Search returns error

**Possible causes**:
- API key incorrect
- API not enabled
- Quota exceeded
- Network issue

**Solutions**:
1. Verify API key is correct
2. Verify YouTube Data API v3 is enabled in Cloud Console
3. Check quota in Cloud Console
4. Check internet connection
5. Try a different search query

### "Invalid URL"

**Problem**: Can't build YouTube API URL

**Likely cause**: API key contains special characters

**Solution**: Copy API key again, verify no extra spaces

### Quota Exceeded

**Problem**: "YouTube API returned an error"

**Why**: Used all 10,000 daily quota units

**Solutions**:
1. Wait until next day (quota resets at midnight Pacific)
2. Implement search result caching
3. Implement debouncing on searches
4. Reduce search result count (currently 10)
5. Consider YouTube Premium tier

## Quota Management

### Daily Quota: 10,000 units

```
Search: ~100 units
Get video details: ~1 unit
```

### Example Usage

```
100 searches/day = 10,000 units
This is plenty for development!
```

### Monitor Quota

```
Google Cloud Console
→ APIs & Services → Dashboard
→ YouTube Data API v3
→ Quota tab
```

### Implement Caching to Save Quota

```swift
// Example: Cache search results
var searchCache: [String: [MusicTrack]] = [:]

func searchAndCache(query: String) async {
    // Check cache first
    if let cached = searchCache[query] {
        return cached
    }
    
    // If not cached, search YouTube
    let results = try await YouTubeService.shared.searchMusic(query: query)
    
    // Store in cache
    searchCache[query] = results
    
    return results
}
```

## Production vs Development

### Development

```
Environment Variable Method:
- Easy to switch keys
- Secure (not in code)
- Recommended ⭐

Google Cloud Console:
- API Key restrictions: None needed
- Quotas: Generous
- Cost: Free
```

### Production

```
Info.plist or Secure Storage:
- Key in bundle
- Must protect

Google Cloud Console:
- API Key restrictions: iOS bundle ID only
- Quotas: Monitor closely
- Cost: May have associated costs
```

## Best Practices

### ✅ DO

- Use environment variables in development
- Restrict API key by application type
- Add bundle ID whitelist in production
- Monitor quota usage
- Implement caching
- Store key securely

### ❌ DON'T

- Commit API key to git
- Use unrestricted API key in production
- Share API key with anyone
- Leave debug logs with key visible
- Hard-code key in source files

## Next Steps

1. ✅ Create Google Cloud project
2. ✅ Enable YouTube Data API v3
3. ✅ Create API key
4. ✅ Configure Xcode
5. ✅ Test music search
6. ✅ Restrict API key

**You're ready to use YouTube music!** 🎵

---

## Quick Reference

| Step | Time | What to Do |
|------|------|-----------|
| 1. Create project | 1 min | New Project → "DAOmates" |
| 2. Enable API | 2 min | Search "YouTube Data API v3" → Enable |
| 3. Create key | 1 min | Create Credentials → API Key |
| 4. Configure Xcode | 2 min | Scheme → Pre-actions → export key |
| 5. Test | 1 min | Run app → Type "play lofi beats" |
| 6. Secure | 2 min | Restrict key to iOS app |
| **TOTAL** | **9 min** | **From signup to testing** |

## Support

Having issues?
- Check console logs in Xcode
- See YOUTUBE_IMPLEMENTATION_GUIDE.md
- Check YOUTUBE_QUICK_START.md
- Verify key in Google Cloud Console

Happy music streaming! 🎶✨

