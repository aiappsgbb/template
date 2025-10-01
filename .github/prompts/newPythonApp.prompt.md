---
mode: 'agent'
model: Auto (copilot)
tools: ['githubRepo', 'codebase']
description: 'Create a new Python application using uv package manager'
---
Create a new Python application using uv package manager under the src folder with the following structure:

1. Create the following directory structure:
   ```
   src/
   ├── python-app/
   │   ├── pyproject.toml
   │   ├── README.md
   │   ├── .python-version
   │   ├── src/
   │   │   └── app/
   │   │       ├── __init__.py
   │   │       └── main.py
   │   └── tests/
   │       ├── __init__.py
   │       └── test_main.py
   ```

2. Generate a `pyproject.toml` file with:
   - Project metadata (name, version, description, authors)
   - Python version requirement (>=3.11)
   - Dependencies including: fastapi, uvicorn, pydantic, httpx, python-dotenv
   - Development dependencies: pytest, pytest-asyncio, black, ruff, mypy
   - Build system configuration for uv
   - Tool configurations for ruff, black, mypy, and pytest

3. Create a `.python-version` file specifying Python 3.11

4. Generate a `main.py` file with:
   - A basic FastAPI application
   - Health check endpoint
   - Environment variable loading
   - Proper async/await patterns
   - Error handling

5. Create a comprehensive `README.md` for the Python app with:
   - Project description
   - Prerequisites (Python 3.11+, uv)
   - Installation instructions using uv
   - Development setup
   - Running the application
   - Testing instructions
   - API documentation

6. Generate basic test files with pytest examples

7. Include proper Python package structure with `__init__.py` files

The application should be production-ready with proper configuration, error handling, and testing setup.