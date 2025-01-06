FROM node:16-alpine AS client-builder

# Create app directory and set permissions
WORKDIR /usr/src/app/client
RUN chown -R node:node /usr/src/app/client

# Switch to node user
USER node

# Set npm global directory for the node user
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

# Copy package files with correct ownership
COPY --chown=node:node client/package*.json ./

# Install dependencies and webpack CLI globally
RUN npm install && \
    npm install -g webpack@5.75.0 webpack-cli@4.10.0

# Copy client source with correct ownership
COPY --chown=node:node client/ ./

# Build the client application
RUN npm run build

# Start fresh for server stage
FROM node:16-alpine

# Create app directory and set permissions
WORKDIR /usr/src/app/server
RUN chown -R node:node /usr/src/app/server

# Switch to node user
USER node

# Copy package files with correct ownership
COPY --chown=node:node server/package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy server source with correct ownership
COPY --chown=node:node server/ ./

# Create public directory and copy client build
COPY --from=client-builder --chown=node:node /usr/src/app/client/dist ./public

# Expose port
EXPOSE 5000

# Start server
CMD ["npm", "start"]
