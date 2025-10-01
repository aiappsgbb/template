---
mode: 'agent'
model: Auto (copilot)
tools: ['githubRepo', 'codebase']
description: 'Create a new Gradio application for interactive UIs'
---

# Create New Gradio Application

Create a new Gradio application using uv package manager under the src folder for interactive user interfaces and AI demos.

## Directory Structure

Create the following directory structure:

```text
src/
├── <gradio-app>/
│   ├── pyproject.toml
│   ├── README.md
│   ├── .python-version
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── __init__.py
│   ├── app.py
│   ├── components/
│   │   ├── __init__.py
│   │   ├── chat.py
│   │   ├── upload.py
│   │   └── visualization.py
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── config.py
│   │   ├── logging_config.py
│   │   └── ai_client.py
│   ├── assets/
│   │   ├── css/
│   │   │   └── custom.css
│   │   └── images/
│   └── examples/
│       └── sample_data.json
```

## File Requirements

### 1. pyproject.toml

Generate a `pyproject.toml` file with:

- Project metadata (name, version, description, authors)
- Python version requirement (>=3.11)
- Dependencies including: gradio, openai, azure-openai, httpx, python-dotenv, pydantic, pydantic-settings
- Optional AI dependencies: langchain, transformers, torch, numpy, pandas, pillow
- Development dependencies: pytest, pytest-asyncio, black, ruff, mypy
- Build system configuration for uv
- Tool configurations for ruff, black, mypy, and pytest

### 2. .python-version

Create a `.python-version` file specifying Python 3.11.

### 3. app.py

Generate an `app.py` file with:

- Main Gradio application setup
- Multiple interface tabs (Chat, File Upload, Visualization)
- Custom CSS styling integration
- Environment configuration loading
- Error handling and logging using Python's logging module (never use print statements)
- Structured logging with appropriate log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Authentication and security configurations
- Server launch configuration for containerization
- Integration with Azure OpenAI or other AI services

### 4. components/chat.py

Create a chat component module with:

- Chat interface using gr.ChatInterface or custom components
- Message history management
- AI model integration (Azure OpenAI, OpenAI, etc.)
- Streaming response support
- Error handling for API failures
- Conversation context management
- User input validation and sanitization

### 5. components/upload.py

Create a file upload component module with:

- File upload interface with supported formats
- File validation and size limits
- Processing for different file types (text, images, PDFs, etc.)
- Preview capabilities
- Batch processing support
- Secure file handling
- Integration with AI services for file analysis

### 6. components/visualization.py

Create a visualization component module with:

- Data visualization using matplotlib, plotly, or similar
- Interactive charts and graphs
- Real-time data updates
- Export capabilities
- Responsive design elements
- Custom styling options

### 7. utils/config.py

Create a configuration module using pydantic-settings with:

- BaseSettings class for environment configuration
- Gradio server settings (HOST, PORT, DEBUG, SHARE)
- AI service configuration (API keys, endpoints, models)
- File upload settings (max size, allowed types)
- Authentication settings
- Logging configuration
- Proper type hints and defaults
- Environment variable loading

### 8. utils/logging_config.py

Create a logging configuration module with:

- Structured logging setup for Gradio applications
- JSON logging for production environments
- Console and file handlers
- Log rotation configuration
- Integration with Gradio's internal logging
- Custom formatters for different environments
- Performance logging for AI operations

### 9. utils/ai_client.py

Create an AI client module with:

- Azure OpenAI client configuration
- OpenAI API client setup
- Request/response handling
- Rate limiting and retry logic
- Error handling and fallback strategies
- Token usage tracking
- Async support for better performance
- Model switching capabilities

### 10. Dockerfile

Create a multi-stage Dockerfile optimized for Gradio with:

- Multi-stage build for smaller production images
- Python 3.11+ base image
- uv for fast dependency installation
- Non-root user for security
- Proper layer caching
- Health check configuration
- Gradio-specific optimizations
- GPU support (optional)

### 11. .dockerignore

Create a `.dockerignore` file to exclude:

- Development files (.git, .vscode, etc.)
- Python cache and build artifacts
- Virtual environments
- Test files and documentation
- Large model files (if any)
- IDE configuration files
- OS-specific files
- Temporary upload directories

### 12. assets/css/custom.css

Create custom CSS styling with:

- Modern, responsive design
- Dark/light theme support
- Brand colors and typography
- Component spacing and layout
- Mobile-friendly optimizations
- Accessibility improvements
- Custom animations and transitions

### 13. README.md

Create a comprehensive `README.md` for the Gradio app with:

- Project description and use cases
- Prerequisites (Python 3.11+, uv, Docker, AI service accounts)
- Installation instructions using uv
- Development setup
- Configuration guide (API keys, environment variables)
- Running the application (local and Docker)
- Docker build and run instructions
- Deployment options (Azure Container Apps, Hugging Face Spaces)
- API documentation and usage examples
- Customization guide
- Security considerations
- Performance optimization tips

### 14. examples/sample_data.json

Create sample data file with:

- Example inputs for testing
- Demo conversation flows
- Sample file formats
- Configuration examples
- Test scenarios

### 15. Azure Developer CLI Configuration

Update the root `azure.yaml` file to include the new Gradio application as a service:

- Add a new service entry under the `services` section
- Configure the service with:
  - Service name matching the application directory name
  - Language: python
  - Host: containerapp
  - Docker build context pointing to the application directory
  - Environment variables for AI service integration (API keys, endpoints)
  - Port configuration for Gradio server (typically 7860)
- Ensure proper service dependencies if needed
- Configure resource group and location references
- Add ingress configuration for external access
- Configure scaling rules for traffic management
- Add any required environment-specific configurations

## Technical Requirements

- Use modern Python 3.11+ features
- Follow Gradio best practices and latest API
- Implement proper configuration management
- Include type hints throughout
- Production-ready error handling
- Environment-based configuration
- Clean, maintainable code structure
- Docker containerization ready
- Multi-stage builds for optimization
- Security best practices (input validation, sanitization)
- Responsive UI design
- Proper logging configuration using Python's logging module
- Structured logging with JSON format for production environments
- Never use print() statements for application output
- Async support for better performance
- Integration with Azure AI services
- Authentication and authorization support
- File upload security and validation
- Rate limiting and usage tracking
- Accessibility compliance (WCAG guidelines)
- Mobile-responsive design
- Performance monitoring and optimization
- Error boundaries and graceful degradation
- Internationalization support (optional)
- Progressive web app features (optional)