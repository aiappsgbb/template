---
agent: 'agent'
model:
  - Claude Opus 4.6 (copilot)
  - Claude Sonnet 4 (copilot)
tools: ['githubRepo', 'search/codebase', 'edit', 'changes', 'runCommands']
description: 'Create a new README file with standard IP structure'
---
# Comprehensive README.md Generation for IP Project

> **Research context**: Optionally reference a plan from `.github/scratchpad/research-plan-*.md` and collection from `.github/scratchpad/research-collection-*.md`. 
- Review research collection findings for documentation structure, code samples, and configuration
- Use consolidated environment variables from collection template
- Reference code snippets from findings for documentation
- Validate against research gaps identified in collection phase

---

1. Generate a README.md file with the following sections:

2. **Header Section**:
   - Project title with badge/logo placeholder
   - Brief one-line description
   - Status badges (build, license, version)
   - Table of contents

3. **Overview Section**:
   - Business problem statement
   - Solution overview
   - Key benefits and value proposition
   - Target audience

4. **Technical Overview**:
   - Architecture diagram placeholder
   - Technology stack
   - Key components and services
   - System requirements
   - Data flow description

5. **Features Section**:
   - Core capabilities
   - Advanced features
   - Planned features/roadmap

6. **Getting Started**:
   - Prerequisites (tools, accounts, versions)
   - Installation instructions
   - Initial setup and configuration
   - Quick start guide
   - First-time user walkthrough

7. **Usage**:
   - Common use cases
   - Code examples
   - API documentation links
   - Configuration options

8. **Development**:
   - Development environment setup
   - Coding standards
   - Testing guidelines
   - Contribution guidelines
   - Local development workflow

9. **Deployment**:
   - Azure deployment instructions
   - Environment configuration
   - CI/CD pipeline information
   - Production considerations

10. **Monitoring and Troubleshooting**:
    - Monitoring setup
    - Common issues and solutions
    - Debugging guides
    - Performance optimization

11. **Security**:
    - Security considerations
    - Authentication and authorization
    - Data protection measures
    - Compliance information

12. **Footer Sections**:
    - Contributing guidelines
    - License information
    - Support and contact information
    - Acknowledgments

Use placeholder content that can be easily customized for specific projects. Include proper markdown formatting with headings, lists, code blocks, and links.