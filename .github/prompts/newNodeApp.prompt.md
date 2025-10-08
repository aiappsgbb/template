---
mode: 'agent'
model: Auto (copilot)
tools: ['githubRepo', 'codebase']
description: 'Create a new Node.js/TypeScript application'
---
Create a new Node.js/TypeScript application under the src folder with the following structure:

1. Create the following directory structure:
   ```
   src/
   ├── node-app/
   │   ├── package.json
   │   ├── tsconfig.json
   │   ├── .nvmrc
   │   ├── README.md
   │   ├── src/
   │   │   ├── index.ts
   │   │   ├── app.ts
   │   │   ├── routes/
   │   │   │   └── health.ts
   │   │   └── middleware/
   │   │       └── errorHandler.ts
   │   ├── tests/
   │   │   └── app.test.ts
   │   └── dist/ (build output)
   ```

2. Generate a `package.json` file with:
   - Project metadata (name, version, description, author)
   - Node.js engine requirement (>=18.0.0)
   - Scripts for build, start, dev, test, lint
   - Dependencies: express, cors, helmet, dotenv, winston (for structured logging)
   - DevDependencies: typescript, @types/node, @types/express, ts-node, nodemon, jest, @types/jest, eslint, prettier

3. Create a `tsconfig.json` with:
   - Modern TypeScript configuration
   - Strict type checking enabled
   - ES2022 target
   - Node.js module resolution
   - Source maps enabled
   - Output directory set to dist/

4. Generate a `.nvmrc` file specifying Node.js 18

5. Create an `index.ts` file with:
   - Express server setup
   - Middleware configuration (cors, helmet, json parsing)
   - Route registration
   - Error handling middleware
   - Graceful shutdown handling
   - Environment configuration

6. Generate route files with:
   - Health check endpoint
   - Proper TypeScript types
   - Request/response handling
   - Error handling

7. Create a comprehensive `README.md` for the Node.js app with:
   - Project description
   - Prerequisites (Node.js 18+, npm/yarn)
   - Installation instructions
   - Development setup
   - Running the application
   - Testing instructions
   - API documentation
   - Build and deployment

8. Generate test files with Jest examples

9. Include proper ESLint and Prettier configuration

10. Update Azure Developer CLI Configuration

Update the root `azure.yaml` file to include the new Node.js application as a service:

- Add a new service entry under the `services` section
- Configure the service with:
  - Service name matching the application directory name
  - Language: js
  - Host: containerapp
  - Docker configuration with:
    - Registry: `"${AZURE_CONTAINER_REGISTRY_ENDPOINT}"`
    - Remote builds enabled: `remoteBuild: true`
    - Build arguments for cross-platform compatibility
  - Environment variables for application configuration
- Ensure proper service dependencies if needed
- Configure resource group and location references
- Add any required environment-specific configurations

Example service configuration:
```yaml
services:
  my-node-app:
    project: "./src/my-node-app"
    language: js
    host: containerapp
    docker:
      registry: "${AZURE_CONTAINER_REGISTRY_ENDPOINT}"
      remoteBuild: true
      buildArgs:
        - "--platform=linux/amd64"
    env:
      - NODE_ENV
      - APPLICATION_INSIGHTS_CONNECTION_STRING
```

The application should be production-ready with proper TypeScript configuration, error handling, structured logging using Winston (never use console.log in production), and testing setup.