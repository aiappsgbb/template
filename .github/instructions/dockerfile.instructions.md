---
applyTo: "**/Dockerfile"
---

# Dockerfile Standards for Azure Container Apps

## Base Images
- Use Azure Linux base images: `mcr.microsoft.com/azurelinux/base/python:3.12` (Python) or `mcr.microsoft.com/azurelinux/base/nodejs:22` (Node.js)
- Use the `containerization` skill for detailed patterns

## Required Patterns
- **Multi-stage builds**: Separate build and runtime stages for smaller images
- **Non-root user**: Create and use a non-root user in the runtime stage
- **Port 80**: Expose and use port 80 for Azure Container Apps
- **Health checks**: Include HEALTHCHECK instruction
- **`.dockerignore`**: Always create alongside the Dockerfile

## Python Example Pattern
```dockerfile
FROM mcr.microsoft.com/azurelinux/base/python:3.12 AS build
WORKDIR /app
COPY pyproject.toml .
RUN pip install uv && uv pip install --system -r pyproject.toml

FROM mcr.microsoft.com/azurelinux/base/python:3.12
WORKDIR /app
RUN useradd -r -s /bin/false appuser
COPY --from=build /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY . .
USER appuser
EXPOSE 80
HEALTHCHECK CMD curl -f http://localhost:80/health || exit 1
CMD ["gunicorn", "app.main:app", "-b", "0.0.0.0:80"]
```

## Azure Container Apps Requirements
- `remoteBuild: true` in azure.yaml for ACR builds (preferred over local Docker)
- Container image managed by azd via `SERVICE_<NAME>_IMAGE_NAME` parameter
