# GitHub Copilot Instructions

This repository contains prompt files to help with common development tasks using GitHub Copilot.

## Available Prompts

### Application Creation
- **Python App**: `@workspace /newPythonApp` - Create a new Python application with uv package manager under src/
- **Node.js/TypeScript App**: `@workspace /newNodeApp` - Create a new Node.js/TypeScript application under src/
- **Setup Infrastructure**: `@workspace /setupInfra` - Configure main.bicep with all relevant Azure modules
- **Create README**: `@workspace /newReadme` - Generate a comprehensive README with standard IP structure

## Usage

Type the prompt command in any chat or inline chat session with GitHub Copilot to execute the corresponding task.

Examples:
```
@workspace /newPythonApp
@workspace /newNodeApp
@workspace /setupInfra  
@workspace /newReadme
```

## Prompt Files Location

All prompt files are located in `.github/copilot/` directory:
- `newPythonApp.md` - Python application creation
- `newNodeApp.md` - Node.js/TypeScript application creation  
- `setupInfra.md` - Infrastructure setup with Bicep
- `newReadme.md` - README file generation

## Customization

Each prompt file can be customized to match your specific project requirements and coding standards. The prompts are designed to work with the existing repository structure and Azure infrastructure templates.