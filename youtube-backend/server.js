const express = require('express');
const cors = require('cors');
const { exec } = require('youtube-dl-exec');
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
      // Use youtube-dl-exec to get best audio format
      const info = await exec(youtubeUrl, {
        dumpJson: true,
        noWarnings: true,
        quiet: true
      });
      
      console.log(`✅ Got video info: ${info.title}`);
      
      // Extract best audio URL
      const audioUrl = await exec(youtubeUrl, {
        format: 'bestaudio[ext=m4a]/bestaudio',
        getUrl: true,
        noWarnings: true,
        quiet: true
      });
      
      if (!audioUrl) {
        throw new Error('Could not extract audio URL');
      }
      
      console.log(`✅ Successfully extracted audio URL`);
      
      res.json({
        success: true,
        audioUrl: audioUrl.trim(),
        title: info.title,
        duration: info.duration || 0,
        videoId: info.id,
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
    let videoInfo;
    
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
        // Search YouTube using youtube-dl-exec
        const searchUrl = `ytsearch1:${query}`;
        const results = await exec(searchUrl, {
          dumpJson: true,
          noWarnings: true,
          quiet: true
        });
        
        if (!results || !results.id) {
          throw new Error('No YouTube results found');
        }
        
        targetUrl = `https://www.youtube.com/watch?v=${results.id}`;
        videoInfo = results;
        
        console.log(`✅ Found: ${results.title}`);
        
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
      // Get video info if not already fetched
      if (!videoInfo) {
        videoInfo = await exec(targetUrl, {
          dumpJson: true,
          noWarnings: true,
          quiet: true
        });
      }
      
      console.log(`✅ Got video info: ${videoInfo.title}`);
      
      // Extract best audio URL
      const audioUrl = await exec(targetUrl, {
        format: 'bestaudio[ext=m4a]/bestaudio',
        getUrl: true,
        noWarnings: true,
        quiet: true
      });
      
      if (!audioUrl) {
        throw new Error('Could not extract audio URL');
      }
      
      console.log(`✅ Successfully extracted audio URL`);
      
      const responseData = {
        success: true,
        audioUrl: audioUrl.trim(),
        title: videoInfo.title,
        videoId: videoInfo.id,
        duration: videoInfo.duration || 0,
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

🚀 Using: youtube-dl-exec (Node wrapper for yt-dlp)
✅ Real YouTube stream extraction
✅ Search caching for speed (5 min TTL)
✅ Works reliably on Railway
🎵 Supported: Any YouTube video

Ready to extract REAL YouTube audio! 🎧
  `);
});
