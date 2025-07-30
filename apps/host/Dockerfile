# This is a Multi_stage Dockerfile
# At first we build the app 
# then At second, we copy the built app to the nginx image

# First stage
FROM node:20-slim AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./
COPY pnpm-workspace.yaml ./

# Copy workspace packages
COPY packages/ ./packages/

# Copy app source
COPY apps/host/ ./apps/host/

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the app
WORKDIR /app/apps/host
RUN pnpm build

# Second stage (where we copy the built app to the nginx image, and nginx configuration)
FROM nginx:1.25-alpine

# Copy built application
COPY --from=builder /app/apps/host/dist /usr/share/nginx/html

# Copy nginx configuration
COPY apps/host/nginx.conf /etc/nginx/conf.d/default.conf

# Remove any other default configs that might conflict
# RUN rm -f /etc/nginx/conf.d/default.conf.bak /etc/nginx/conf.d/default.conf.template 2>/dev/null || true

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 