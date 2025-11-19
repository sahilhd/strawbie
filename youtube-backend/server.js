const express = require('express');
const cors = require('cors');
const { Innertube, UniversalCache } = require('youtubei.js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Cache for search results
const searchCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

// YouTube client (will be initialized on first use)
let yt = null;

// Initialize YouTube client
async function initYouTube() {
  if (yt) return yt;
  
  console.log('🎬 Initializing YouTube client...');
  yt = await Innertube.create({
    cache: new UniversalCache(false),
    cookie: process.env.YOUTUBE_COOKIE || undefined
  });
  console.log('✅ YouTube client initialized');
  
  return yt;
}

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'YouTube Backend Service is running' });
});

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

    const youtubeClient = await initYouTube();
    
    // Extract videoId from URL if needed
    let vid = videoId;
    if (url && !videoId) {
      const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/);
      vid = match ? match[1] : null;
    }
    
    if (!vid) {
      return res.status(400).json({ error: 'Invalid URL or videoId' });
    }
    
    console.log(`🎬 Extracting audio from: ${vid}`);
    
    // Get video info
    const video = await youtubeClient.getVideo(vid);
    const info = video.basic_info;
    
    console.log(`✅ Got video info: ${info.title}`);
    
    // Get format with audio
    const chosenFormat = video.chooseFormat({
      quality: 'lowest',  // Get lowest quality for fastest load
      type: 'audio'       // Audio only
    });
    
    if (!chosenFormat || !chosenFormat.url) {
      throw new Error('Could not extract audio URL');
    }
    
    console.log(`✅ Successfully extracted audio URL`);
    
    res.json({
      success: true,
      audioUrl: chosenFormat.url,
      title: info.title,
      duration: info.duration,
      videoId: vid,
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

    const youtubeClient = await initYouTube();
    
    let targetVideoId;
    
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
      
      const search_results = await youtubeClient.search(query);
      const firstVideo = search_results.contents?.[0];
      
      if (!firstVideo || !firstVideo.id) {
        throw new Error('No YouTube results found');
      }
      
      targetVideoId = firstVideo.id;
      console.log(`✅ Found: ${firstVideo.title?.simpleText || firstVideo.title?.text || 'Unknown'}`);
      
    } else if (videoId) {
      targetVideoId = videoId;
    } else if (url) {
      const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/);
      targetVideoId = match ? match[1] : null;
      
      if (!targetVideoId) {
        throw new Error('Invalid YouTube URL');
      }
    }
    
    if (!targetVideoId) {
      throw new Error('Could not determine video ID');
    }
    
    // Extract audio
    console.log(`🎬 Extracting audio...`);
    
    const video = await youtubeClient.getVideo(targetVideoId);
    const info = video.basic_info;
    
    const chosenFormat = video.chooseFormat({
      quality: 'lowest',
      type: 'audio'
    });
    
    if (!chosenFormat || !chosenFormat.url) {
      throw new Error('Could not extract audio URL');
    }
    
    console.log(`✅ Successfully extracted audio URL`);
    
    const responseData = {
      success: true,
      audioUrl: chosenFormat.url,
      title: info.title,
      duration: info.duration,
      videoId: targetVideoId,
      url: `https://www.youtube.com/watch?v=${targetVideoId}`,
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

🚀 Using: YouTubei.js (Modern Innertube API)
✅ REAL YouTube stream extraction
✅ Search caching (5 min TTL)
✅ Works reliably on Railway
✅ Pure JavaScript - No Python!
✅ Handles YouTube's modern security
🎵 Supports: Any YouTube video

Ready to extract REAL YouTube audio! 🎧
  `);
});
