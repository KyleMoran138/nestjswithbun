# Stage 1: Build the application
FROM oven/bun:1.0.2 AS builder

# Use a non-root user to run our application
USER bunu

WORKDIR /app

# Copy package.json and package-lock.json first for efficient caching
COPY --chown=bunu:bunu package.json bun.lockb ./

# Install all dependencies, including 'devDependencies'
RUN bun install

# Copy source code to image
COPY --chown=bunu:bunu . .

# Build the application
RUN npm run build

# Stage 2: Development image with source files & node_modules
FROM oven/bun:1.0.2 AS dev

WORKDIR /app

# Use a non-root user
USER bunu

# Copy all node_modules and source code for hot-reload or any other tasks
COPY --from=builder --chown=bunu:bunu /app/node_modules ./node_modules
COPY --chown=bunu:bunu . .

# Expose default port for development
EXPOSE 3000

CMD ["npm", "run", "start:dev"]

# Stage 3: Production image
FROM oven/bun:1.0.2 AS production

WORKDIR /app

# Use a non-root user
USER bunu

# Copy only runtime dependencies and built sources from builder stage
COPY --from=builder --chown=bunu:bunu /app/node_modules ./node_modules
COPY --from=builder --chown=bunu:bunu /app/dist ./dist

# Expose default port for production
EXPOSE 3000

CMD ["node", "dist/main"]