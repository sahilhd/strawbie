const express = require('express');
const cors = require('cors');
const playdl = require('play-dl');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Cache for search results to speed up repeated queries
const searchCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'YouTube Backend Service is running' });
});

/**
 * Extract audio stream URL from YouTube video
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
    
    try {
      // Get video info using play-dl
      const videoInfo = await playdl.video_info(youtubeUrl);
      
      if (!videoInfo) {
        throw new Error('Could not fetch video information');
      }
      
      console.log(`✅ Got video info: ${videoInfo.video_details.title}`);
      
      // Get stream
      const stream = await playdl.stream(youtubeUrl, { quality: 1, type: 'audio' });
      if (!stream || !stream.url) {
        throw new Error('Could not extract audio URL');
      }
      
      console.log(`✅ Successfully extracted audio URL`);
      
      res.json({
        success: true,
        audioUrl: stream.url,
        title: videoInfo.video_details.title,
        duration: videoInfo.video_details.duration,
        videoId: videoInfo.video_details.video_id,
        extractedAt: new Date().toISOString()
      });
      
    } catch (innerError) {
      console.error(`⚠️ Extraction failed: ${innerError.message}`);
      throw innerError;
    }
    
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
    
    // Accept either query (search), videoId, or url
    if (!query && !videoId && !url) {
      return res.status(400).json({
        error: 'Missing query, videoId, or url parameter'
      });
    }

    console.log(`🔍 Processing: query="${query}", videoId="${videoId}"`);
    
    let targetUrl;
    
    if (url) {
      targetUrl = url;
    } else if (videoId) {
      targetUrl = `https://www.youtube.com/watch?v=${videoId}`;
    } else if (query) {
      // Check cache first
      const cacheKey = `search:${query.toLowerCase()}`;
      const cached = searchCache.get(cacheKey);
      
      if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        console.log(`✅ Using cached search result for: ${query}`);
        return res.json(cached.data);
      }
      
      console.log(`🔍 Searching YouTube for: ${query}`);
      
      try {
        // Search YouTube
        const videos = await playdl.search(query, { limit: 1, type: 'video' });
        
        if (!videos || videos.length === 0) {
          throw new Error('No YouTube results found');
        }
        
        const video = videos[0];
        targetUrl = video.url;
        
        console.log(`✅ Found: ${video.title}`);
        
      } catch (searchError) {
        console.error(`❌ Search failed: ${searchError.message}`);
        throw searchError;
      }
    }
    
    if (!targetUrl) {
      throw new Error('Could not determine video URL');
    }
    
    // Now extract audio from the video
    console.log(`🎬 Extracting audio from search result...`);
    
    try {
      // Get video info
      const videoInfo = await playdl.video_info(targetUrl);
      
      if (!videoInfo) {
        throw new Error('Could not fetch video information');
      }
      
      console.log(`✅ Got video info: ${videoInfo.video_details.title}`);
      
      // Get stream
      const stream = await playdl.stream(targetUrl, { quality: 1, type: 'audio' });
      if (!stream || !stream.url) {
        throw new Error('Could not extract audio URL');
      }
      
      console.log(`✅ Successfully extracted audio URL`);
      
      const responseData = {
        success: true,
        audioUrl: stream.url,
        title: videoInfo.video_details.title,
        videoId: videoInfo.video_details.video_id,
        duration: videoInfo.video_details.duration || 0,
        url: targetUrl,
        extractedAt: new Date().toISOString()
      };
      
      // Cache the result
      if (query) {
        searchCache.set(`search:${query.toLowerCase()}`, {
          data: responseData,
          timestamp: Date.now()
        });
      }
      
      res.json(responseData);
      
    } catch (extractError) {
      console.error(`❌ Extract failed: ${extractError.message}`);
      throw extractError;
    }
    
  } catch (error) {
    console.error('❌ Error searching/extracting:', error.message);
    res.status(500).json({
      error: 'Failed to search and extract from YouTube',
      message: error.message
    });
  }
});

// Error handling middleware
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
║   🎵 Audio Stream Extraction Service      ║
╚═══════════════════════════════════════════╝

✅ Server running on port ${PORT}
🎬 Endpoints:
   - GET  /health
   - POST /api/extract-audio
   - POST /api/search-and-extract

🚀 Using: play-dl (Node.js-based)
✅ Real YouTube stream extraction
✅ Search caching for speed (5 min TTL)
✅ No system dependencies needed
✅ Lightning fast builds & deployment
🎵 Supported: Any YouTube video

Ready to extract real YouTube audio! 🎧
  `);
});
