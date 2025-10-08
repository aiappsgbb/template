---
mode: 'agent'
model: Auto (copilot)
tools: ['githubRepo', 'codebase']
description: 'Create a new Python application using uv package manager'
---

# Create New Python Application

Create a new Python application using uv package manager under the src folder with a simplified structure.

## Directory Structure

Create the following directory structure:

```text
src/
├── <newapp>/
│   ├── pyproject.toml
│   ├── README.md
│   ├── .python-version
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── __init__.py
│   ├── main.py
│   └── utils/
│       ├── __init__.py
│       ├── config.py
│       └── tracing.py
```

## File Requirements

### 1. pyproject.toml

Generate a `pyproject.toml` file with:

- Project metadata (name, version, description, authors)
- Python version requirement (>=3.11)
- Dependencies including: fastapi, uvicorn, pydantic, pydantic-settings, httpx, python-dotenv
- OpenTelemetry dependencies: opentelemetry-api, opentelemetry-sdk, opentelemetry-instrumentation-fastapi, opentelemetry-instrumentation-httpx, azure-monitor-opentelemetry-exporter
- Development dependencies: pytest, pytest-asyncio, black, ruff, mypy
- Build system configuration for uv
- Tool configurations for ruff, black, mypy, and pytest

### 2. .python-version

Create a `.python-version` file specifying Python 3.11.

### 3. main.py

Generate a `main.py` file with:

- A basic FastAPI application
- Health check endpoint for container monitoring
- Configuration loading using utils.config
- OpenTelemetry tracing integration using utils.tracing
- Proper async/await patterns
- Error handling and logging using Python's logging module (never use print statements)
- Structured logging with appropriate log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- CORS middleware configuration
- Uvicorn server configuration for containerization
- Tracing instrumentation for requests and external calls

### 4. Dockerfile

Create a multi-stage Dockerfile optimized for FastAPI with:

- Multi-stage build for smaller production images
- Python 3.11+ base image
- uv for fast dependency installation
- Non-root user for security
- Proper layer caching
- Health check configuration
- Production-ready settings

### 5. .dockerignore

Create a `.dockerignore` file to exclude:

- Development files (.git, .vscode, etc.)
- Python cache and build artifacts
- Virtual environments
- Test files and documentation
- IDE configuration files
- OS-specific files

### 6. utils/config.py

Create a configuration module using pydantic-settings with:

- BaseSettings class for environment configuration
- Common settings like HOST, PORT, DEBUG, LOG_LEVEL
- Azure Monitor configuration (APPLICATION_INSIGHTS_CONNECTION_STRING)
- Database and API configuration placeholders
- OpenTelemetry tracing settings
- Proper type hints and defaults
- Environment variable loading

### 7. utils/tracing.py

Create an OpenTelemetry tracing module with:

- Azure Monitor OpenTelemetry exporter configuration
- FastAPI automatic instrumentation setup
- HTTPx instrumentation for external API calls
- Resource configuration with service name and version
- Trace provider initialization using config settings
- Custom trace decorators for business logic
- Error handling for tracing setup
- Integration with utils.config for configuration management

### 8. README.md

Create a comprehensive `README.md` for the Python app with:

- Project description
- Prerequisites (Python 3.11+, uv, Docker, Azure Application Insights)
- Installation instructions using uv
- Development setup
- Running the application (local and Docker)
- Docker build and run instructions
- Configuration options (including Azure Monitor setup)
- API documentation
- Container deployment guidance
- Monitoring and observability setup
- Azure Application Insights configuration

### 9. Package Structure

Include proper Python package structure with `__init__.py` files in:

- Root application directory
- utils/ directory (with config.py and tracing.py)

### 10. Azure Developer CLI Configuration

Update the root `azure.yaml` file to include the new Python application as a service:

- Add a new service entry under the `services` section
- Configure the service with:
  - Service name matching the application directory name
  - Language: python
  - Host: containerapp
  - Docker configuration with:
    - Registry: `"${AZURE_CONTAINER_REGISTRY_ENDPOINT}"`
    - Remote builds enabled: `remoteBuild: true`
    - Build arguments for cross-platform compatibility
  - Environment variables for Azure Monitor integration
- Ensure proper service dependencies if needed
- Configure resource group and location references
- Add any required environment-specific configurations

Example service configuration:
```yaml
services:
  my-python-app:
    project: "./src/my-python-app"
    language: python
    host: containerapp
    docker:
      registry: "${AZURE_CONTAINER_REGISTRY_ENDPOINT}"
      remoteBuild: true
      buildArgs:
        - "--platform=linux/amd64"
    env:
      - AZURE_OPENAI_ENDPOINT
      - APPLICATION_INSIGHTS_CONNECTION_STRING
```

## Technical Requirements

- Use modern Python 3.11+ features
- Follow FastAPI best practices
- Implement proper configuration management
- Include type hints throughout
- Production-ready error handling
- Environment-based configuration
- Clean, maintainable code structure
- Docker containerization ready
- Multi-stage builds for optimization
- Security best practices (non-root user)
- Health checks for container orchestration
- Proper logging configuration using Python's logging module
- Structured logging with JSON format for production environments
- Never use print() statements for application output
- Azure Monitor integration via OpenTelemetry
- Distributed tracing for microservices
- Observability and monitoring ready
- Performance tracking and metrics