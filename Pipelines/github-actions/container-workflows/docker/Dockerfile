# Multi-stage Dockerfile with security optimizations
# Build arguments for metadata
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_REVISION
ARG BUILD_NUMBER

# Security: Use specific version tags, not latest
ARG NODE_VERSION=18.18.2
ARG ALPINE_VERSION=3.18
ARG NGINX_VERSION=1.25.2-alpine

##########################################################################
# Stage 1: Dependencies and Build Tools
##########################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS dependencies

# Security: Run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Security: Install security updates and minimal required packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        dumb-init \
        ca-certificates \
        tzdata \
        tini && \
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Security: Copy package files first for better layer caching
COPY package*.json yarn.lock* pnpm-lock.yaml* ./

# Security: Audit dependencies and install only production deps first
RUN if [ -f package-lock.json ]; then \
        npm audit --audit-level high && \
        npm ci --only=production --no-optional && \
        npm cache clean --force; \
    elif [ -f yarn.lock ]; then \
        yarn audit --level high && \
        yarn install --production --frozen-lockfile --no-optional && \
        yarn cache clean; \
    elif [ -f pnpm-lock.yaml ]; then \
        pnpm audit --audit-level high && \
        pnpm install --prod --frozen-lockfile; \
    else \
        echo "No package manager lock file found" && exit 1; \
    fi

##########################################################################
# Stage 2: Build Stage
##########################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS build

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Install build dependencies
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        git \
        python3 \
        make \
        g++ \
        ca-certificates && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Copy package files
COPY package*.json yarn.lock* pnpm-lock.yaml* ./

# Install all dependencies (including dev)
RUN if [ -f package-lock.json ]; then \
        npm ci --include=dev && \
        npm cache clean --force; \
    elif [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile && \
        yarn cache clean; \
    elif [ -f pnpm-lock.yaml ]; then \
        pnpm install --frozen-lockfile; \
    fi

# Copy source code
COPY . .

# Security: Remove sensitive files
RUN rm -rf \
    .git \
    .env* \
    .dockerignore \
    Dockerfile* \
    README.md \
    docker-compose*.yml \
    .github \
    tests \
    docs

# Build application
RUN if [ -f package.json ]; then \
        npm run build && \
        npm prune --production; \
    fi

# Security: Scan for vulnerabilities in final build
RUN if command -v npm >/dev/null 2>&1; then \
        npm audit --audit-level high --production; \
    fi

##########################################################################
# Stage 3: Security Scanning Stage (optional, for CI/CD)
##########################################################################
FROM build AS security-scan

# Install security scanning tools
RUN apk add --no-cache \
        curl \
        jq

# Download and run Trivy scanner
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan filesystem for vulnerabilities
RUN trivy fs --exit-code 1 --severity HIGH,CRITICAL --no-progress /app

##########################################################################
# Stage 4: Runtime Base
##########################################################################
FROM nginx:${NGINX_VERSION} AS runtime-base

# Security: Install security updates
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        dumb-init \
        ca-certificates \
        tzdata \
        tini \
        curl \
        jq && \
    rm -rf /var/cache/apk/*

# Security: Create non-root user for nginx
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S nginx-app -u 1001 -G nginx-app

# Security: Remove default nginx config and content
RUN rm -rf /etc/nginx/conf.d/default.conf \
           /usr/share/nginx/html/* \
           /var/cache/nginx

# Create necessary directories with proper permissions
RUN mkdir -p /app /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    chown -R nginx-app:nginx-app /app /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

##########################################################################
# Stage 5: Final Production Image
##########################################################################
FROM runtime-base AS production

# Build metadata labels (OCI compliance)
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.version="${BUILD_VERSION}" \
      org.opencontainers.image.revision="${BUILD_REVISION}" \
      org.opencontainers.image.title="Secure Multi-stage Application" \
      org.opencontainers.image.description="Production-ready container with security optimizations" \
      org.opencontainers.image.vendor="Your Organization" \
      org.opencontainers.image.authors="DevOps Team <devops@yourorg.com>" \
      org.opencontainers.image.documentation="https://docs.yourorg.com" \
      org.opencontainers.image.source="https://github.com/yourorg/yourapp" \
      maintainer="DevOps Team <devops@yourorg.com>" \
      build.number="${BUILD_NUMBER}"

# Copy production dependencies and built application
COPY --from=dependencies --chown=nginx-app:nginx-app /app/node_modules ./node_modules
COPY --from=build --chown=nginx-app:nginx-app /app/dist /app/build /usr/share/nginx/html/

# Security: Copy application files with proper ownership
COPY --from=build --chown=nginx-app:nginx-app /app/public /usr/share/nginx/html/
COPY --from=build --chown=nginx-app:nginx-app /app/package.json /app/

# Copy optimized nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/security-headers.conf /etc/nginx/conf.d/security-headers.conf
COPY docker/mime.types /etc/nginx/mime.types

# Security: Set proper permissions
RUN chmod 644 /etc/nginx/nginx.conf \
              /etc/nginx/conf.d/security-headers.conf \
              /etc/nginx/mime.types && \
    chmod -R 644 /usr/share/nginx/html/ && \
    find /usr/share/nginx/html/ -type d -exec chmod 755 {} \;

# Health check script
COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Security: Switch to non-root user
USER nginx-app

# Expose port (non-privileged)
EXPOSE 8080

# Security: Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Security: Use tini as PID 1 to handle signals properly
ENTRYPOINT ["/sbin/tini", "--"]

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

##########################################################################
# Stage 6: Development Image (for local development)
##########################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS development

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Install development dependencies
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        git \
        vim \
        curl \
        bash \
        openssh-client \
        ca-certificates && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Copy package files
COPY package*.json yarn.lock* pnpm-lock.yaml* ./

# Install all dependencies
RUN if [ -f package-lock.json ]; then \
        npm ci && \
        npm cache clean --force; \
    elif [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile && \
        yarn cache clean; \
    elif [ -f pnpm-lock.yaml ]; then \
        pnpm install --frozen-lockfile; \
    fi

# Switch to non-root user
USER nextjs

# Development port
EXPOSE 3000

# Development command
CMD ["npm", "run", "dev"]

##########################################################################
# Stage 7: Test Runner Image
##########################################################################
FROM build AS test

# Install test dependencies
RUN apk add --no-cache \
        chromium \
        nss \
        freetype \
        freetype-dev \
        harfbuzz \
        ca-certificates \
        ttf-freefont

# Puppeteer configuration for Alpine
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copy test files
COPY tests/ ./tests/
COPY jest.config.js cypress.config.js playwright.config.ts ./

# Security: Switch to non-root user
USER nextjs

# Run tests
CMD ["npm", "run", "test"]

##########################################################################
# Multi-architecture support notes:
# - This Dockerfile supports linux/amd64 and linux/arm64
# - Build with: docker buildx build --platform linux/amd64,linux/arm64
# - Base images are multi-arch compatible
##########################################################################