const express = require('express');
const cors = require('cors');
const { execSync, spawn } = require('child_process');
const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Setup YouTube cookies if provided (to bypass bot detection)
const COOKIES_PATH = '/tmp/youtube_cookies.txt';
if (process.env.YOUTUBE_COOKIES) {
  try {
    fs.writeFileSync(COOKIES_PATH, process.env.YOUTUBE_COOKIES);
    console.log('✅ YouTube cookies configured (bot detection bypass enabled)');
  } catch (error) {
    console.error('⚠️ Failed to write cookies file:', error.message);
  }
} else {
  console.log('⚠️ No YouTube cookies configured - may encounter bot detection');
}

// Cache for search results
const searchCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'YouTube Backend Service is running' });
});

/**
 * Run yt-dlp command with optional cookies
 */
function runYtDlp(args) {
  try {
    // Try multiple paths for yt-dlp
    let cmd = 'yt-dlp';
    try {
      execSync('which yt-dlp', { encoding: 'utf-8' });
    } catch {
      // Try common paths
      const paths = ['/usr/local/bin/yt-dlp', '/usr/bin/yt-dlp', 'python3 -m yt_dlp'];
      for (const path of paths) {
        try {
          execSync(`${path} --version`, { encoding: 'utf-8', stdio: 'pipe' });
          cmd = path;
          break;
        } catch {}
      }
    }
    
    // Add cookies if available (to bypass bot detection)
    let cookiesArg = '';
    if (fs.existsSync(COOKIES_PATH)) {
      cookiesArg = `--cookies ${COOKIES_PATH}`;
      console.log('🍪 Using YouTube cookies to bypass bot detection');
    }
    
    const fullCmd = `${cmd} ${cookiesArg} ${args}`;
    const result = execSync(fullCmd, {
      encoding: 'utf-8',
      maxBuffer: 1024 * 1024 * 10,
      timeout: 30000
    });
    return result.trim();
  } catch (error) {
    console.error(`yt-dlp error: ${error.message}`);
    throw new Error(`YouTube extraction failed: ${error.message}`);
  }
}

/**
 * Extract audio URL from YouTube video
 * 
 * POST /api/extract-audio
 * Body: { videoId: "..." } or { url: "..." }
 * Returns: { audioUrl: "...", title: "...", duration: ... }
 */
app.post('/api/extract-audio', async (req, res) => {
  try {
    const { videoId, url } = req.body;
    
    if (!videoId && !url) {
      return res.status(400).json({
        error: 'Missing videoId or url parameter'
      });
    }

    const youtubeUrl = url || `https://www.youtube.com/watch?v=${videoId}`;
    
    console.log(`🎬 Extracting audio from: ${youtubeUrl}`);
    
    // Get video info
    const infoJson = runYtDlp(`--dump-json --no-warnings "${youtubeUrl}"`);
    const info = JSON.parse(infoJson);
    
    console.log(`✅ Got video info: ${info.title}`);
    
    // Get audio URL
    const audioUrl = runYtDlp(`--format bestaudio --get-url --no-warnings "${youtubeUrl}"`);
    
    if (!audioUrl) {
      throw new Error('Could not extract audio URL');
    }
    
    console.log(`✅ Successfully extracted audio URL`);
    
    res.json({
      success: true,
      audioUrl: audioUrl,
      title: info.title,
      duration: info.duration || 0,
      videoId: info.id,
      extractedAt: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('❌ Error extracting audio:', error.message);
    res.status(500).json({
      error: 'Failed to extract audio from YouTube',
      message: error.message
    });
  }
});

/**
 * Search YouTube and extract first result
 * 
 * POST /api/search-and-extract
 * Body: { query: "..." }
 * Returns: { audioUrl: "...", title: "...", videoId: "..." }
 */
app.post('/api/search-and-extract', async (req, res) => {
  try {
    const { query, videoId, url } = req.body;
    
    if (!query && !videoId && !url) {
      return res.status(400).json({
        error: 'Missing query, videoId, or url parameter'
      });
    }

    let targetUrl;
    let videoInfo;
    
    // Check cache if searching
    if (query) {
      const cacheKey = `search:${query.toLowerCase()}`;
      const cached = searchCache.get(cacheKey);
      
      if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        console.log(`✅ Using cached search result for: ${query}`);
        return res.json(cached.data);
      }
      
      // Search YouTube
      console.log(`🔍 Searching YouTube for: ${query}`);
      
      const searchUrl = `ytsearch1:${query}`;
      const resultsJson = runYtDlp(`--dump-json --no-warnings "${searchUrl}"`);
      const results = JSON.parse(resultsJson);
      
      if (!results || !results.id) {
        throw new Error('No YouTube results found');
      }
      
      targetUrl = `https://www.youtube.com/watch?v=${results.id}`;
      videoInfo = results;
      
      console.log(`✅ Found: ${results.title}`);
      
    } else if (videoId) {
      targetUrl = `https://www.youtube.com/watch?v=${videoId}`;
    } else if (url) {
      targetUrl = url;
    }
    
    if (!targetUrl) {
      throw new Error('Could not determine video URL');
    }
    
    // Extract audio
    console.log(`🎬 Extracting audio...`);
    
    if (!videoInfo) {
      const infoJson = runYtDlp(`--dump-json --no-warnings "${targetUrl}"`);
      videoInfo = JSON.parse(infoJson);
    }
    
    console.log(`✅ Got video info: ${videoInfo.title}`);
    
    const audioUrl = runYtDlp(`--format bestaudio --get-url --no-warnings "${targetUrl}"`);
    
    if (!audioUrl) {
      throw new Error('Could not extract audio URL');
    }
    
    console.log(`✅ Successfully extracted audio URL`);
    
    const responseData = {
      success: true,
      audioUrl: audioUrl,
      title: videoInfo.title,
      videoId: videoInfo.id,
      duration: videoInfo.duration || 0,
      url: targetUrl,
      extractedAt: new Date().toISOString()
    };
    
    // Cache the result
    if (query) {
      const cacheKey = `search:${query.toLowerCase()}`;
      searchCache.set(cacheKey, {
        data: responseData,
        timestamp: Date.now()
      });
    }
    
    res.json(responseData);
    
  } catch (error) {
    console.error('❌ Error searching/extracting:', error.message);
    res.status(500).json({
      error: 'Failed to search and extract from YouTube',
      message: error.message
    });
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════╗
║   YouTube Music Backend Server            ║
║   🎵 REAL Audio Stream Extraction         ║
╚═══════════════════════════════════════════╝

✅ Server running on port ${PORT}
🎬 Endpoints:
   - GET  /health
   - POST /api/extract-audio
   - POST /api/search-and-extract
   - GET  /api/stream/:videoId

🚀 Using: yt-dlp (via Docker with Python)
✅ REAL YouTube stream extraction
✅ Audio streaming proxy (no AVPlayer issues!)
✅ Search caching (5 min TTL)
✅ Works reliably on Railway
🎵 Supports: Any YouTube video

Ready to extract REAL YouTube audio! 🎧
  `);
});

/**
 * Stream audio directly from YouTube through backend proxy
 * This bypasses AVPlayer restrictions on YouTube URLs
 * 
 * GET /api/stream/:videoId
 * Returns: Audio stream (audio/webm or audio/mp4)
 */
app.get('/api/stream/:videoId', async (req, res) => {
  const { videoId } = req.params;
  
  if (!videoId) {
    return res.status(400).json({ error: 'Missing videoId parameter' });
  }

  try {
    const youtubeUrl = `https://www.youtube.com/watch?v=${videoId}`;
    console.log(`🎵 Streaming audio for: ${videoId}`);

    // Get audio URL using yt-dlp
    const audioUrlOutput = runYtDlp(`-f bestaudio --get-url --no-warnings "${youtubeUrl}"`);
    const audioUrl = audioUrlOutput.trim();

    if (!audioUrl || !audioUrl.startsWith('http')) {
      throw new Error('Failed to get audio URL');
    }

    console.log(`✅ Got audio URL, proxying stream...`);

    // Set appropriate headers
    res.setHeader('Content-Type', 'audio/webm');
    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Cache-Control', 'public, max-age=3600');

    // Proxy the audio stream from YouTube to client
    const protocol = audioUrl.startsWith('https') ? https : http;
    
    const proxyRequest = protocol.get(audioUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referer': 'https://www.youtube.com/'
      }
    }, (proxyRes) => {
      // Forward headers from YouTube
      res.setHeader('Content-Length', proxyRes.headers['content-length'] || '0');
      res.setHeader('Content-Type', proxyRes.headers['content-type'] || 'audio/webm');

      // Pipe YouTube audio stream to client
      proxyRes.pipe(res);

      proxyRes.on('error', (err) => {
        console.error(`❌ Proxy stream error: ${err.message}`);
        if (!res.headersSent) {
          res.status(500).json({ error: 'Stream error' });
        }
      });
    });

    proxyRequest.on('error', (err) => {
      console.error(`❌ Proxy request error: ${err.message}`);
      if (!res.headersSent) {
        res.status(500).json({ error: 'Failed to proxy audio stream' });
      }
    });

    // Handle client disconnect
    req.on('close', () => {
      console.log('🔌 Client disconnected, ending proxy');
      proxyRequest.destroy();
    });

  } catch (error) {
    console.error(`❌ Stream error: ${error.message}`);
    if (!res.headersSent) {
      res.status(500).json({
        error: 'Failed to stream audio',
        details: error.message
      });
    }
  }
});
