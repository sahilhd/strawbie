# YouTube Backend with yt-dlp

FROM node:18-slim

# Set shell for proper error handling
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      python3-pip \
      ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Install yt-dlp
RUN pip3 install --no-cache-dir yt-dlp && \
    which yt-dlp && \
    python3 -m yt_dlp --version

WORKDIR /app

# Copy application
COPY youtube-backend/ ./youtube-backend/

# Install Node dependencies
RUN cd youtube-backend && npm ci --prefer-offline

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error()})"

# Start the server
CMD ["node", "youtube-backend/server.js"]
