# Stage 1: Build the application
FROM oven/bun:1.0.2 AS builder
RUN addgroup --system bunu && adduser --system --group bunu
USER bunu
WORKDIR /app
COPY --chown=bunu:bunu package.json bun.lockb ./
RUN bun install
COPY --chown=bunu:bunu . .
RUN bun run build

# Stage 2: Development image with source files & node_modules
FROM oven/bun:1.0.2 AS dev
RUN addgroup --system bunu && adduser --system --group bunu
USER bunu
WORKDIR /app
# Copy all node_modules and source code for hot-reload or any other tasks
COPY --from=builder --chown=bunu:bunu /app/node_modules ./node_modules
COPY --chown=bunu:bunu . .
# Expose default port for development
EXPOSE 3000
CMD ["bun", "run", "dev"]

# Stage 3: Install production dependencies
FROM oven/bun:1.0.2 AS production-deps
RUN addgroup --system bunu && adduser --system --group bunu
USER bunu
WORKDIR /app
COPY --chown=bunu:bunu package.json bun.lockb ./
RUN bun install -p

# Stage 4: Production image
FROM oven/bun:1.0.2 AS production
RUN addgroup --system bunu && adduser --system --group bunu
USER bunu
WORKDIR /app
# Copy only runtime dependencies and built sources from builder stage
COPY --from=production-deps --chown=bunu:bunu /app/node_modules ./node_modules
COPY --from=builder --chown=bunu:bunu /app/dist ./dist
# Expose default port for production
EXPOSE 3000
CMD ["bun", "run", "dist/main.js"]