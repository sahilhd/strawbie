# Use Python base image with Node.js
FROM python:3.11-slim

# Install Node.js and system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      ffmpeg && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install yt-dlp globally
RUN pip3 install --no-cache-dir yt-dlp

# Verify installations
RUN python3 --version && \
    node --version && \
    npm --version && \
    yt-dlp --version

WORKDIR /app

# Copy backend code
COPY youtube-backend/package*.json ./youtube-backend/
RUN cd youtube-backend && npm ci --prefer-offline

COPY youtube-backend/ ./youtube-backend/

WORKDIR /app/youtube-backend

# Expose port
EXPOSE 3000

# Start server
CMD ["node", "server.js"]
