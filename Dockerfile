# YouTube Backend with yt-dlp

FROM node:18-slim

# Install Python and yt-dlp before anything else
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      python3-pip \
      ffmpeg \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Install yt-dlp globally via pip3
RUN pip3 install --no-cache-dir yt-dlp

# Verify yt-dlp is available and works
RUN which yt-dlp && python3 -m yt_dlp --version

WORKDIR /app

# Copy application
COPY youtube-backend/ ./youtube-backend/

# Install Node dependencies
RUN cd youtube-backend && npm ci --prefer-offline

# Verify youtube-dl-exec can find yt-dlp
RUN cd youtube-backend && node -e "require('youtube-dl-exec')('--version', {}, function(err, output) { console.log('yt-dlp ready:', output); if(err) console.error(err); })"

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error()})"

# Start the server
CMD ["node", "youtube-backend/server.js"]
