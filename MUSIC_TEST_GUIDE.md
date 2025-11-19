# 🎵 Strawbie Music Testing Guide

## Quick Test Checklist

### 1. **Build and Run** ✅
```bash
1. Open DAOmates.xcodeproj in Xcode
2. Select your iPhone or Simulator
3. Build and run (⌘R)
4. Complete onboarding if needed
5. Enter chat screen
```

### 2. **Test Music Commands** 🎵

#### Test 1: Play a Popular Song
```
Say: "play The Weeknd Blinding Lights"

Expected:
✅ Strawbie responds: "ok playing it 🎵" or similar
✅ Music widget appears at bottom
✅ Track title shows: "Blinding Lights"
✅ Artist shows: "The Weeknd"
✅ Music starts playing
✅ Play/pause button works
```

#### Test 2: Play Another Artist
```
Say: "play Taylor Swift"

Expected:
✅ Searches for Taylor Swift on YouTube
✅ Plays first result
✅ Music widget updates with new track
✅ Can hear the music
```

#### Test 3: Playback Controls
```
1. Say: "play Drake"
2. Tap pause button (⏸️)
3. Tap play button (▶️)
4. Tap next button (▶️▶️)

Expected:
✅ Pause stops music
✅ Play resumes music
✅ Next skips to next track (if available)
```

#### Test 4: Multiple Songs
```
1. Say: "play Billie Eilish bad guy"
2. Wait for it to play
3. Say: "play Ariana Grande"
4. Check widget updates

Expected:
✅ First song plays
✅ Second command stops first song
✅ Second song starts
✅ Widget shows new track info
```

---

## 🔍 What to Watch For

### ✅ Good Signs:
```
Console logs show:
🔍 🎵 Searching REAL YouTube music for: [query]
🎥 Calling REAL YouTube backend
📊 Backend response status: 200
✅ ✅ ✅ REAL YouTube audio URL received!
🎵 Title: [song name]
🎵 Audio URL: https://rr...googlevideo.com/...
▶️ Playing after status ready
```

### ❌ Warning Signs:
```
If you see:
⚠️ Falling back to sample tracks
❌ Backend API error
❌ YouTube search failed

→ Backend might be sleeping (first request takes longer)
→ Wait 10-15 seconds and try again
→ Railway free tier spins down after inactivity
```

---

## 🎤 Music Commands to Test

### Play Commands:
```
✅ "play The Weeknd"
✅ "play Drake Hotline Bling"
✅ "put on Taylor Swift"
✅ "listen to Billie Eilish"
✅ "play some hip hop"
✅ "play Ariana Grande thank u next"
```

### Control Commands:
```
✅ "pause music"
✅ "next song"
✅ "skip"
✅ "previous"
```

---

## 🐛 Troubleshooting

### Problem: No Music Plays
**Solution:**
1. Check your device volume (must be > 0%)
2. Check mute switch on iPhone
3. Check Xcode console for errors
4. Verify internet connection
5. Test backend manually (see below)

### Problem: Falls Back to Sample Tracks
**Solution:**
1. Backend might be cold-starting (wait 10-15 seconds)
2. Check Railway is running:
   ```bash
   curl https://strawbie-production.up.railway.app/health
   ```
3. Should return: `{"status":"healthy","yt_dlp":"installed"}`

### Problem: Widget Doesn't Show
**Solution:**
1. Check `showMusicPlayer` variable in ABGChatView
2. Verify MusicIntent is detected in logs
3. Look for: `🎵 Play intent detected!`

### Problem: Can't Hear Audio
**Solution:**
1. Check audio session logs:
   ```
   ✅ Audio session configured for music playback
   🔊 Category: playback
   🔊 Volume: [should be > 0]
   ```
2. Check player status:
   ```
   🔊 Player rate: 1.0  (good)
   🔊 Player rate: 0.0  (bad - not playing)
   ```
3. Verify audio URL is valid:
   ```
   🎵 Audio URL: https://rr5---sn...googlevideo.com/...
   ```

---

## 🧪 Manual Backend Test

### Quick Backend Check:
```bash
# Test backend is running
curl https://strawbie-production.up.railway.app/health

# Test music extraction
curl -X POST https://strawbie-production.up.railway.app/api/search-and-extract \
  -H "Content-Type: application/json" \
  -d '{"query": "Drake Hotline Bling"}' | jq

# Should return real audio URL
```

Expected Response:
```json
{
  "success": true,
  "title": "Drake - Hotline Bling",
  "videoId": "uxpDa-c-4Mc",
  "duration": 267,
  "audioUrl": "https://rr5---sn-8pxuuxa-q5qe.googlevideo.com/...",
  "thumbnail": "https://i.ytimg.com/vi/uxpDa-c-4Mc/maxresdefault.jpg"
}
```

---

## 📊 Success Checklist

After testing, verify:
- [ ] Music plays when commanded
- [ ] Widget appears and shows track info
- [ ] Play/pause button works
- [ ] Next/previous buttons work
- [ ] Multiple songs can be played in sequence
- [ ] Volume is audible
- [ ] Track info is accurate
- [ ] Strawbie gives appropriate responses
- [ ] No crashes or errors

---

## 🎉 Expected User Experience

**Perfect Flow:**
```
User: "play The Weeknd Blinding Lights"
  ↓
Strawbie: "ok playing it 🎵"
  ↓
[Music Widget Appears]
🎵 Blinding Lights
   The Weeknd
   [◀️ ⏸️ ▶️]
  ↓
🎵 Music plays from YouTube
  ↓
User taps pause → Music stops
User taps play → Music resumes
User taps next → Next track plays
```

---

## 📝 Test Log Template

Copy this and fill it out:

```
Date: ___________
Device: ___________ (iPhone X, Simulator, etc.)
iOS Version: _____

Test 1: Play The Weeknd
Result: ☐ Pass ☐ Fail
Notes: ___________

Test 2: Play Taylor Swift
Result: ☐ Pass ☐ Fail
Notes: ___________

Test 3: Pause/Resume
Result: ☐ Pass ☐ Fail
Notes: ___________

Test 4: Next Track
Result: ☐ Pass ☐ Fail
Notes: ___________

Test 5: Multiple Songs
Result: ☐ Pass ☐ Fail
Notes: ___________

Backend Test: ☐ Pass ☐ Fail
Backend URL: ___________
Response Time: ___ seconds

Overall Result: ☐ PASS ☐ FAIL
```

---

## 🆘 Emergency Fallback

If backend fails completely, app will:
1. ✅ Show error message
2. ✅ Fall back to sample tracks
3. ✅ Continue working (not crash)
4. ✅ Retry on next request

Sample tracks still work as backup!

---

## 🎯 What Success Looks Like

### Console Output (Good):
```
🔍 🎵 Searching REAL YouTube music for: The Weeknd Blinding Lights
🎥 Calling REAL YouTube backend
📊 Backend response status: 200
📥 Raw backend response: {"success":true,"title":"The Weeknd..."}
✅ ✅ ✅ REAL YouTube audio URL received!
🎵 Title: The Weeknd - Blinding Lights (Official Audio)
🎵 Video ID: 4NRXx6U8ABQ
🎵 Duration: 200.0s
🎵 Audio URL: https://rr5---sn-8pxuuxa-q5qe.googlevideo.com/...
🎵 Created MusicTrack: Blinding Lights by The Weeknd
🎵 Attempting to play: Blinding Lights
✅ URL is valid
✅ Player item ready to play!
▶️ Playing after status ready
```

### App UI (Good):
```
Chat:
━━━━━━━━━━━━━━━━━━━━━
User: play The Weeknd
Strawbie: ok playing it 🎵
━━━━━━━━━━━━━━━━━━━━━

Bottom of screen:
╔══════════════════════════╗
║ 🎵  Blinding Lights      ║
║     The Weeknd           ║
║ [◀️]  [⏸️]  [▶️]        ║
╚══════════════════════════╝
```

---

**Ready to test?** 🚀  
**Just say: "play The Weeknd Blinding Lights"** 🎵

---

Made with 💜 by Strawbie Team

