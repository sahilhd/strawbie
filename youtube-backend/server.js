const express = require('express');
const cors = require('cors');
const { exec } = require('child_process');
const { promisify } = require('util');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const execAsync = promisify(exec);

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

    // Build YouTube URL
    const youtubeUrl = url || `https://www.youtube.com/watch?v=${videoId}`;
    
    console.log(`🎬 Extracting audio from: ${youtubeUrl}`);
    
    try {
      // Use yt-dlp to get best audio format
      const command = `yt-dlp -f "bestaudio[ext=m4a]/bestaudio" --get-url --no-warnings "${youtubeUrl}"`;
      
      console.log(`Running: ${command}`);
      const { stdout, stderr } = await execAsync(command, { timeout: 30000 });
      
      if (stderr && !stdout) {
        throw new Error(`yt-dlp error: ${stderr}`);
      }
      
      // Extract audio URL (last line of output)
      const audioUrl = stdout.trim().split('\n').pop();
      
      if (!audioUrl || !audioUrl.startsWith('http')) {
        throw new Error('Could not extract valid audio URL');
      }
      
      console.log(`✅ Successfully extracted audio URL`);
      
      // Get video info
      const infoCommand = `yt-dlp --dump-json --no-warnings "${youtubeUrl}"`;
      let videoInfo = { title: 'Unknown', duration: 0 };
      
      try {
        const { stdout: jsonOutput } = await execAsync(infoCommand, { timeout: 30000 });
        const info = JSON.parse(jsonOutput);
        videoInfo = {
          title: info.title || 'Unknown',
          duration: info.duration || 0,
          videoId: info.id || videoId
        };
      } catch (e) {
        console.log('Could not parse video info, using defaults');
      }
      
      res.json({
        success: true,
        audioUrl: audioUrl,
        title: videoInfo.title,
        duration: videoInfo.duration,
        videoId: videoInfo.videoId,
        extractedAt: new Date().toISOString()
      });
      
    } catch (innerError) {
      console.error(`⚠️ yt-dlp failed: ${innerError.message}`);
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
    
    let targetVideoId = videoId;
    let videoInfo = null;
    
    if (url) {
      // Extract video ID from URL
      const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/);
      targetVideoId = match ? match[1] : null;
      
      if (!targetVideoId) {
        throw new Error('Invalid YouTube URL');
      }
    } else if (!videoId && query) {
      // Search YouTube for the query
      console.log(`🔍 Searching YouTube for: ${query}`);
      
      try {
        // Use yt-dlp to search
        const searchCommand = `yt-dlp --dump-json --no-warnings "ytsearch1:${query}"`;
        
        console.log(`Running search command...`);
        const { stdout: searchOutput } = await execAsync(searchCommand, { timeout: 30000 });
        
        const results = JSON.parse(searchOutput);
        
        if (!results || !results.entries || results.entries.length === 0) {
          throw new Error('No YouTube results found');
        }
        
        const firstResult = results.entries[0];
        targetVideoId = firstResult.id;
        videoInfo = {
          title: firstResult.title || 'Unknown',
          duration: firstResult.duration || 0
        };
        
        console.log(`✅ Found: ${videoInfo.title} (ID: ${targetVideoId})`);
        
      } catch (searchError) {
        console.error(`❌ Search failed: ${searchError.message}`);
        throw searchError;
      }
    }
    
    if (!targetVideoId) {
      throw new Error('Could not determine video ID');
    }
    
    // Now extract audio from the video
    const youtubeUrl = `https://www.youtube.com/watch?v=${targetVideoId}`;
    
    console.log(`🎬 Extracting audio from: ${youtubeUrl}`);
    
    try {
      // Use yt-dlp to get best audio format
      const command = `yt-dlp -f "bestaudio[ext=m4a]/bestaudio" --get-url --no-warnings "${youtubeUrl}"`;
      
      const { stdout, stderr } = await execAsync(command, { timeout: 30000 });
      
      if (stderr && !stdout) {
        throw new Error(`yt-dlp error: ${stderr}`);
      }
      
      // Extract audio URL (last line of output)
      const audioUrl = stdout.trim().split('\n').pop();
      
      if (!audioUrl || !audioUrl.startsWith('http')) {
        throw new Error('Could not extract valid audio URL');
      }
      
      console.log(`✅ Successfully extracted audio URL`);
      
      // If we don't have video info yet, get it now
      if (!videoInfo) {
        const infoCommand = `yt-dlp --dump-json --no-warnings "${youtubeUrl}"`;
        try {
          const { stdout: jsonOutput } = await execAsync(infoCommand, { timeout: 30000 });
          const info = JSON.parse(jsonOutput);
          videoInfo = {
            title: info.title || 'Unknown',
            duration: info.duration || 0
          };
        } catch (e) {
          console.log('Could not parse video info, using defaults');
          videoInfo = { title: 'Unknown', duration: 0 };
        }
      }
      
      res.json({
        success: true,
        audioUrl: audioUrl,
        title: videoInfo.title,
        videoId: targetVideoId,
        duration: videoInfo.duration,
        url: youtubeUrl,
        extractedAt: new Date().toISOString()
      });
      
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

🔧 Using: yt-dlp command-line tool
✅ Real YouTube audio extraction
✅ Search and extract in one call
🎵 Supported: Any YouTube video

Ready to extract real YouTube audio! 🎧
  `);
});
