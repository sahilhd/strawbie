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
    
    // Use yt-dlp CLI to extract audio stream URL
    // Format: best[ext=m4a] gets the best audio in m4a format
    // Make sure yt-dlp is installed: pip install yt-dlp
    const command = `yt-dlp -f "bestaudio[ext=m4a]/bestaudio" --get-url --no-warnings "${youtubeUrl}"`;
    
    const { stdout, stderr } = await execAsync(command, { timeout: 30000 });
    
    if (stderr && !stdout) {
      throw new Error(`yt-dlp error: ${stderr}`);
    }
    
    // Extract audio URL from output (last line)
    const audioUrl = stdout.trim().split('\n').pop();
    
    if (!audioUrl || !audioUrl.startsWith('http')) {
      throw new Error('Could not extract valid audio URL from YouTube');
    }
    
    console.log(`✅ Successfully extracted audio URL`);
    
    // Get video info
    const infoCommand = `yt-dlp --dump-json --no-warnings "${youtubeUrl}"`;
    const { stdout: jsonOutput } = await execAsync(infoCommand, { timeout: 30000 });
    
    let videoInfo = { title: 'Unknown', duration: 0 };
    try {
      const info = JSON.parse(jsonOutput);
      videoInfo = {
        title: info.title || 'Unknown',
        duration: info.duration || 0,
        thumbnail: info.thumbnail || null
      };
    } catch (e) {
      console.log('Could not parse video info, using defaults');
    }
    
    res.json({
      success: true,
      audioUrl: audioUrl,
      title: videoInfo.title,
      duration: videoInfo.duration,
      thumbnail: videoInfo.thumbnail,
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
    const { query } = req.body;
    
    if (!query) {
      return res.status(400).json({
        error: 'Missing query parameter'
      });
    }

    console.log(`🔍 Searching YouTube for: ${query}`);
    
    // Search for video
    const searchCommand = `yt-dlp --dump-json --no-warnings "ytsearch1:${query}" 2>/dev/null`;
    const { stdout: searchOutput } = await execAsync(searchCommand, { timeout: 30000 });
    
    const results = JSON.parse(searchOutput);
    if (!results || !results.entries || results.entries.length === 0) {
      throw new Error('No YouTube results found');
    }
    
    const firstResult = results.entries[0];
    const videoUrl = firstResult.url || `https://www.youtube.com/watch?v=${firstResult.id}`;
    
    console.log(`✅ Found: ${firstResult.title}`);
    
    // Extract audio URL from first result
    const audioCommand = `yt-dlp -f "bestaudio[ext=m4a]/bestaudio" --get-url --no-warnings "${videoUrl}"`;
    const { stdout: audioOutput } = await execAsync(audioCommand, { timeout: 30000 });
    
    const audioUrl = audioOutput.trim().split('\n').pop();
    
    if (!audioUrl || !audioUrl.startsWith('http')) {
      throw new Error('Could not extract audio URL');
    }
    
    res.json({
      success: true,
      audioUrl: audioUrl,
      title: firstResult.title,
      videoId: firstResult.id,
      duration: firstResult.duration || 0,
      thumbnail: firstResult.thumbnail || null,
      url: videoUrl,
      extractedAt: new Date().toISOString()
    });
    
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

📝 Setup Instructions:
1. Install yt-dlp: npm install yt-dlp
2. Make sure ffmpeg is installed: brew install ffmpeg
3. Start server: npm start

Ready to extract YouTube audio! 🎧
  `);
});

