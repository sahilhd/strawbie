# Multi-stage build for YouTube backend

FROM python:3.11-slim AS builder
# Install yt-dlp in a layer
RUN pip install --no-cache-dir yt-dlp

# Runtime stage
FROM node:18-slim

# Copy yt-dlp from builder (Python already included in runtime)
COPY --from=builder /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp
COPY --from=builder /usr/local/lib/python*/dist-packages /usr/local/lib/python3.11/dist-packages

# Install Python runtime
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy app files
COPY youtube-backend/ ./youtube-backend/

# Install Node dependencies
RUN cd youtube-backend && npm ci --prefer-offline

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error()})"

# Start server
CMD ["node", "youtube-backend/server.js"]

