const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Sample working music URLs for testing
const SAMPLE_MUSIC = {
  'drake': {
    title: 'Drake - Hotline Bling',
    duration: 280,
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
  },
  'taylor swift': {
    title: 'Taylor Swift - Anti-Hero',
    duration: 200,
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
  },
  'the weeknd': {
    title: 'The Weeknd - Blinding Lights',
    duration: 220,
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
  },
  'ariana grande': {
    title: 'Ariana Grande - Thank U Next',
    duration: 210,
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'
  },
  'billie eilish': {
    title: 'Billie Eilish - Bad Guy',
    duration: 190,
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3'
  },
  'default': {
    title: 'Music Track',
    duration: 300,
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
  }
};

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'YouTube Backend Service is running' });
});

/**
 * Extract audio URL from YouTube video
 */
app.post('/api/extract-audio', (req, res) => {
  try {
    const { videoId, url } = req.body;
    
    if (!videoId && !url) {
      return res.status(400).json({
        error: 'Missing videoId or url parameter'
      });
    }

    console.log(`🎬 Extracting audio from: ${videoId || url}`);
    
    // Return sample track
    const sample = SAMPLE_MUSIC['default'];
    
    res.json({
      success: true,
      audioUrl: sample.audioUrl,
      title: sample.title,
      duration: sample.duration,
      videoId: videoId || 'sample',
      extractedAt: new Date().toISOString(),
      note: 'Sample music URL for testing. For real YouTube, integrate play-dl or yt-dlp.'
    });
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    res.status(500).json({
      error: 'Failed to extract audio',
      message: error.message
    });
  }
});

/**
 * Search YouTube and extract first result
 */
app.post('/api/search-and-extract', (req, res) => {
  try {
    const { query, videoId, url } = req.body;
    
    if (!query && !videoId && !url) {
      return res.status(400).json({
        error: 'Missing query, videoId, or url parameter'
      });
    }

    console.log(`🔍 Processing: query="${query}", videoId="${videoId}"`);
    
    // Find matching sample or return default
    let sample = SAMPLE_MUSIC['default'];
    
    if (query) {
      const queryLower = query.toLowerCase();
      for (const [key, value] of Object.entries(SAMPLE_MUSIC)) {
        if (queryLower.includes(key) || key.includes(queryLower.split(' ')[0])) {
          sample = value;
          break;
        }
      }
    }
    
    const responseData = {
      success: true,
      audioUrl: sample.audioUrl,
      title: sample.title,
      videoId: videoId || query || 'sample',
      duration: sample.duration,
      url: url || `https://www.youtube.com/watch?v=${videoId || 'sample'}`,
      extractedAt: new Date().toISOString(),
      note: 'Sample music URL for testing and demo. To use real YouTube music: redeploy with yt-dlp or play-dl backend.'
    };
    
    res.json(responseData);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    res.status(500).json({
      error: 'Failed to search and extract',
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
╔═══════════════════════════════════════════════════════════════════╗
║       YouTube Music Backend - Testing/Demo Mode                  ║
║       🎵 Sample Music URLs for Development                       ║
╚═══════════════════════════════════════════════════════════════════╝

✅ Server running on port ${PORT}
🎬 Endpoints:
   - GET  /health
   - POST /api/extract-audio
   - POST /api/search-and-extract

📝 Note: This is DEMO MODE with sample music URLs.

🚀 To use REAL YouTube music:
   Option 1: Use play-dl (pure Node.js)
   Option 2: Use yt-dlp via Docker
   Option 3: Use external API service

🎵 Current mode: Testing with sample tracks
   This allows the app to function without YouTube dependencies!

Ready for testing! 🎧
  `);
});
