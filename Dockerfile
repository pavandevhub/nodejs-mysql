FROM node:14-alpine AS client-builder

# Set up npm global directory
RUN mkdir -p /home/node/.npm-global && \
    chown -R node:node /home/node/.npm-global

# Set npm global path
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH

# Set the working directory
WORKDIR /usr/src/app/client

# Switch to node user
USER node

# Install webpack globally
RUN npm install -g webpack webpack-cli

# Copy package files with correct ownership
COPY --chown=node:node client/package*.json ./

# Install dependencies
RUN npm install

# Copy client source with correct ownership
COPY --chown=node:node client/ ./

# Build the client application
RUN npm run build

# Start fresh for server stage
FROM node:14-alpine

# Create app directory
WORKDIR /usr/src/app/server

# Copy package files
COPY server/package*.json ./

# Switch to node user
USER node

# Install production dependencies only
RUN npm ci --only=production

# Copy server source
COPY --chown=node:node server/ ./

# Create public directory and copy client build
COPY --from=client-builder --chown=node:node /usr/src/app/client/dist ./public

# Expose the port
EXPOSE 5000

# Start the server
CMD ["npm", "start"]
