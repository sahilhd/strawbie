const express = require('express');
const cors = require('cors');
const ytdl = require('ytdl-core');
const fetch = require('node-fetch');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

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
 * Search YouTube using innertube API
 */
async function searchYouTube(query) {
  try {
    console.log(`🔍 Searching YouTube for: ${query}`);
    
    const searchUrl = `https://www.youtube.com/results?search_query=${encodeURIComponent(query)}`;
    const response = await fetch(searchUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      }
    });
    
    const html = await response.text();
    
    // Extract initial data from HTML
    const initialDataMatch = html.match(/var ytInitialData = ({.*?});/);
    if (!initialDataMatch) {
      throw new Error('Could not extract YouTube data');
    }
    
    const initialData = JSON.parse(initialDataMatch[1]);
    
    // Navigate through the response structure
    const videos = initialData?.contents?.twoColumnSearchResultsRenderer?.primaryContents?.sectionListRenderer?.contents?.[0]?.itemSectionRenderer?.contents || [];
    
    for (const video of videos) {
      if (video?.videoRenderer?.videoId) {
        const videoId = video.videoRenderer.videoId;
        const title = video.videoRenderer?.title?.runs?.[0]?.text || 'Unknown';
        
        console.log(`✅ Found: ${title}`);
        
        return {
          videoId,
          title,
          url: `https://www.youtube.com/watch?v=${videoId}`
        };
      }
    }
    
    throw new Error('No video results found');
  } catch (error) {
    console.error(`❌ Search failed: ${error.message}`);
    throw error;
  }
}

/**
 * Extract audio URL from YouTube video
 */
async function extractAudioUrl(youtubeUrl) {
  try {
    console.log(`🎬 Getting info from: ${youtubeUrl}`);
    
    const info = await ytdl.getInfo(youtubeUrl, {
      requestOptions: {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
      }
    });
    
    console.log(`✅ Got video info: ${info.videoDetails.title}`);
    
    // Get audio-only formats
    const audioFormats = ytdl.filterFormats(info.formats, 'audioonly');
    
    if (!audioFormats || audioFormats.length === 0) {
      throw new Error('No audio formats available');
    }
    
    // Get the best audio format
    const audioFormat = audioFormats[0];
    const audioUrl = audioFormat.url;
    
    if (!audioUrl) {
      throw new Error('Could not extract audio URL');
    }
    
    console.log(`✅ Successfully extracted audio URL`);
    
    return {
      audioUrl,
      title: info.videoDetails.title,
      duration: info.videoDetails.lengthSeconds,
      videoId: info.videoDetails.videoId
    };
  } catch (error) {
    console.error(`❌ Extraction failed: ${error.message}`);
    throw error;
  }
}

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
    
    const result = await extractAudioUrl(youtubeUrl);
    
    res.json({
      success: true,
      ...result,
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
    }
    
    // Search or use provided URL/videoId
    if (url) {
      targetUrl = url;
    } else if (videoId) {
      targetUrl = `https://www.youtube.com/watch?v=${videoId}`;
    } else if (query) {
      videoInfo = await searchYouTube(query);
      targetUrl = videoInfo.url;
    }
    
    if (!targetUrl) {
      throw new Error('Could not determine video URL');
    }
    
    // Extract audio
    const result = await extractAudioUrl(targetUrl);
    
    const responseData = {
      success: true,
      ...result,
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

🚀 Using: ytdl-core (Pure JavaScript)
✅ REAL YouTube stream extraction
✅ Search caching (5 min TTL)
✅ Works reliably on Railway
✅ NO PYTHON NEEDED!
🎵 Supports: Any YouTube video

Ready to extract REAL YouTube audio! 🎧
  `);
});
