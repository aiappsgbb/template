# GitHub Copilot Instructions

This repository contains prompt files to help with common development tasks using GitHub Copilot.

## Available Prompts

### Application Creation
- **Python App**: `@workspace /newPythonApp` - Create a new Python application with uv package manager under src/
- **Node.js/TypeScript App**: `@workspace /newNodeApp` - Create a new Node.js/TypeScript application under src/
- **Gradio App**: `@workspace /newGradioApp` - Create a new Gradio application for interactive UIs and AI demos under src/
- **Setup Infrastructure**: `@workspace /setupInfra` - Configure main.bicep with all relevant Azure modules
- **Add AZD Service**: `@workspace /addAzdService` - Add a new service configuration to azure.yaml
- **Create README**: `@workspace /newReadme` - Generate a comprehensive README with standard IP structure

## Usage

Type the prompt command in any chat or inline chat session with GitHub Copilot to execute the corresponding task.

Examples:
```
@workspace /newPythonApp
@workspace /newNodeApp
@workspace /newGradioApp
@workspace /setupInfra
@workspace /addAzdService
@workspace /newReadme
```

## Prompt Files Location

All prompt files are located in `.github/prompts/` directory:
- `newPythonApp.prompt.md` - Python application creation
- `newNodeApp.prompt.md` - Node.js/TypeScript application creation  
- `newGradioApp.prompt.md` - Gradio application creation for interactive UIs
- `setupInfra.prompt.md` - Infrastructure setup with Bicep
- `addAzdService.prompt.md` - Azure Developer CLI service configuration
- `newReadme.prompt.md` - README file generation

## Customization

Each prompt file can be customized to match your specific project requirements and coding standards. The prompts are designed to work with the existing repository structure and Azure infrastructure templates.

## Development Standards

When using these prompts, ensure adherence to the following standards:

- **Logging**: Always use proper logging modules (Python's `logging`, Node.js `winston`) - never use `print()` or `console.log()` in production code
- **Error Handling**: Implement structured error handling with appropriate logging levels
- **Code Quality**: Follow linting, formatting, and type checking standards
- **Security**: Implement security best practices and credential management
- **Azure Integration**: Always update `azure.yaml` when creating new applications to ensure proper deployment configuration