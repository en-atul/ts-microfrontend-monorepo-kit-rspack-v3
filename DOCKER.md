# Docker Setup for Microfrontend Monorepo

This document explains how to use Docker to run the microfrontend applications in a production-like
environment locally.

## Overview

The Docker setup includes:

- **Host App**: Served on port 3000
- **Remote App**: Served on port 3001
- **Nginx**: Reverse proxy with proper CORS and access control
- **Docker Compose**: Orchestration for easy management

## Prerequisites

- Docker Desktop installed and running
- Docker Compose (usually included with Docker Desktop)

## Quick Start

### 1. Build and Start Services

```bash
# Build all images and start services
pnpm docker:prod

# Or step by step:
pnpm docker:build
pnpm docker:up
```

### 2. Access Applications

- **Host App**: http://localhost:3000
- **Remote App**: http://localhost:3001

### 3. Check Status

```bash
# View running containers
docker-compose ps

# View logs
pnpm docker:logs

# Check health endpoints
curl http://localhost:3000/health
curl http://localhost:3001/health
```

## Available Scripts

| Script                | Description                                |
| --------------------- | ------------------------------------------ |
| `pnpm docker:build`   | Build all Docker images                    |
| `pnpm docker:up`      | Start services in background               |
| `pnpm docker:down`    | Stop and remove containers                 |
| `pnpm docker:logs`    | View logs from all services                |
| `pnpm docker:restart` | Restart all services                       |
| `pnpm docker:clean`   | Clean up containers, volumes, and images   |
| `pnpm docker:prod`    | Build and start services (production mode) |

## Architecture

### Container Structure

```
┌─────────────────┐    ┌─────────────────┐
│   Host App      │    │  Remote App     │
│   (Port 3000)   │    │  (Port 3001)    │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Nginx     │ │    │ │   Nginx     │ │
│ │   + React   │ │    │ │   + React   │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
```

### Network Configuration

- **Host App**: `http://host-app:80` (internal), `http://localhost:3000` (external)
- **Remote App**: `http://remote-app:80` (internal), `http://localhost:3001` (external)
- **Network**: `microfrontend-network` (172.20.0.0/16)

## Nginx Configuration

### Security Features

- **CORS Headers**: Properly configured for microfrontend federation
- **Access Control**: Referer-based validation for `remoteEntry.js`
- **Security Headers**: XSS protection, content type sniffing prevention
- **Gzip Compression**: Enabled for better performance

### Remote Entry Access Control

The nginx configuration includes referer validation for `remoteEntry.js` files:

- **Host App**: Allows access from `http://localhost:3001` and `http://remote-app`
- **Remote App**: Allows access from `http://localhost:3000` and `http://host-app`

### Caching Strategy

- **Static Assets**: 1 year cache with immutable flag
- **HTML Files**: No cache (always fresh)
- **Remote Entry**: No cache (always fresh for federation)

## Development vs Production

### Development Mode

```bash
# Run with hot reload
pnpm start:host
pnpm start:remote
```

### Production Mode (Docker)

```bash
# Run with nginx and production optimizations
pnpm docker:prod
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**

   ```bash
   # Check what's using the port
   lsof -i :3000
   lsof -i :3001

   # Stop conflicting services
   pnpm docker:down
   ```

2. **Build Failures**

   ```bash
   # Clean and rebuild
   pnpm docker:clean
   pnpm docker:build
   ```

3. **CORS Issues**

   - Check nginx logs: `docker-compose logs host-app`
   - Verify referer headers in browser dev tools
   - Ensure proper CORS configuration in nginx.conf

4. **Module Federation Issues**
   - Check that `remoteEntry.js` is accessible
   - Verify network connectivity between containers
   - Check browser console for federation errors

### Debugging

```bash
# Access container shell
docker-compose exec host-app sh
docker-compose exec remote-app sh

# View nginx logs
docker-compose exec host-app tail -f /var/log/nginx/error.log

# Check nginx configuration
docker-compose exec host-app nginx -t
```

## Performance Optimization

### Build Optimizations

- Multi-stage Docker builds
- Layer caching for dependencies
- Production builds with minification
- Gzip compression enabled

### Runtime Optimizations

- Nginx reverse proxy
- Static asset caching
- Health checks for container monitoring
- Resource limits (can be added to docker-compose.yml)

## Environment Variables

You can customize the setup by adding environment variables:

```yaml
# In docker-compose.yml
environment:
  - NODE_ENV=production
  - CUSTOM_VAR=value
```

## Monitoring

### Health Checks

Both containers include health checks:

- Endpoint: `/health`
- Interval: 30 seconds
- Timeout: 10 seconds
- Retries: 3

### Logs

```bash
# View all logs
pnpm docker:logs

# View specific service logs
docker-compose logs host-app
docker-compose logs remote-app

# Follow logs in real-time
docker-compose logs -f host-app
```

## Cleanup

```bash
# Stop and remove containers
pnpm docker:down

# Clean everything (containers, volumes, images)
pnpm docker:clean

# Remove specific images
docker rmi micro-frontend-monorepo-host-app
docker rmi micro-frontend-monorepo-remote-app
```
