---
name: containerization
description: Docker multi-stage build patterns for Azure Container Apps. Use when creating Dockerfiles, .dockerignore files, configuring container builds for azd, or troubleshooting container deployment. Triggers on Dockerfile, Docker, container, multi-stage build, Azure Linux, Container Apps, remoteBuild, .dockerignore.
---

# Containerization for Azure Container Apps

Patterns for Dockerfiles that work with Azure Developer CLI (`azd`) and Azure Container Apps.

## Build Strategy

**Prefer remote builds** (`remoteBuild: true` in azure.yaml) over local Docker builds:
- No local Docker Desktop dependency
- Builds happen in Azure Container Registry (ACR)
- Works in CI/CD without Docker-in-Docker

```yaml
# azure.yaml
services:
  api:
    host: containerapp
    docker:
      remoteBuild: true  # ← Recommended
```

## Python Dockerfile

```dockerfile
# ── Build stage ───────────────────────────────────────────────
FROM mcr.microsoft.com/azurelinux/base/python:3.12 AS build

WORKDIR /app
COPY pyproject.toml uv.lock* ./

RUN pip install --no-cache-dir uv && \
    uv pip install --system --no-cache -r pyproject.toml

COPY . .

# ── Runtime stage ─────────────────────────────────────────────
FROM mcr.microsoft.com/azurelinux/base/python:3.12

WORKDIR /app

# Non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup -s /bin/false appuser

# Copy installed packages and application code
COPY --from=build /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /app .

# Security: run as non-root
USER appuser

# Azure Container Apps expects port 80
EXPOSE 80

# Health check for Container Apps orchestration
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

CMD ["gunicorn", "app.main:app", "--bind", "0.0.0.0:80", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker"]
```

## Node.js/TypeScript Dockerfile

```dockerfile
# ── Build stage ───────────────────────────────────────────────
FROM mcr.microsoft.com/azurelinux/base/nodejs:22 AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# ── Runtime stage ─────────────────────────────────────────────
FROM mcr.microsoft.com/azurelinux/base/nodejs:22

WORKDIR /app

RUN groupadd -r appgroup && useradd -r -g appgroup -s /bin/false appuser

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./

USER appuser
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

ENV PORT=80 NODE_ENV=production
CMD ["node", "dist/index.js"]
```

## .NET Dockerfile

```dockerfile
# ── Build stage ───────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src
COPY *.csproj ./
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# ── Runtime stage ─────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:9.0

WORKDIR /app

RUN groupadd -r appgroup && useradd -r -g appgroup -s /bin/false appuser

COPY --from=build /app/publish .

USER appuser
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

ENV ASPNETCORE_URLS=http://+:80
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

## .dockerignore Template

Always create alongside the Dockerfile:

```
**/.git
**/.gitignore
**/.vscode
**/.env
**/__pycache__
**/.pytest_cache
**/node_modules
**/dist
**/bin
**/obj
**/*.pyc
**/venv
**/.venv
**/tests
**/*.md
**/Dockerfile*
**/.dockerignore
```

## Key Requirements

| Requirement | Reason |
|-------------|--------|
| Multi-stage build | Smaller runtime image, no build tools in production |
| Azure Linux base images | Optimized for Azure, smaller than Debian/Ubuntu |
| Non-root user | Security best practice, Container Apps requirement |
| Port 80 | Azure Container Apps default ingress port |
| HEALTHCHECK | Container orchestration liveness detection |
| No secrets in image | Use environment variables injected at runtime |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Build fails in ACR | Check `.dockerignore` isn't excluding needed files |
| Container won't start | Verify `EXPOSE 80` and app listens on port 80 |
| Health check fails | Ensure `/health` endpoint exists and returns 200 |
| Permission denied | Verify file ownership in COPY steps |
| Large image size | Ensure multi-stage build properly separates build/runtime |
