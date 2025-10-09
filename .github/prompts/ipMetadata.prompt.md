---
mode: 'agent'
model: Auto (copilot)
tools: ['githubRepo', 'search/codebase']
description: 'Create or update IP metadata file with standard structure'
---

Create or update the .github/ip-metadata.json file with standardized intellectual property metadata.

## Task
Generate a comprehensive .github/ip-metadata.json file that follows the schema defined in .github/ip-metadata.schema.json.

## Requirements

### 1. Required Fields
- **name**: Project name (1-100 characters)
- **description**: Brief project description (10-500 characters) 
- **maturity**: Choose from "Gold", "Silver", or "Bronze"
- **region**: Choose from "AMER", "EMEA", or "ASIA"
- **industry**: Select from the 9 industry verticals:
  - Financial Services
  - Retail
  - Energy
  - Healthcare
  - Manufacturing
  - Government
  - Education
  - Media & Entertainment
  - Technology
- **owner**: Microsoft alias of the IP owner
- **pattern**: Array of GBB specialization patterns:
  - AI/ML
  - Data & Analytics
  - Application Innovation
  - Infrastructure
  - Security
  - IoT
  - Mixed Reality
  - Sustainability
  - Digital Transformation
  - Cloud Native
  - Integration
  - Business Intelligence
  - DevOps
- **services**: Array of Azure services used in the project

### 2. Optional Fields
- **tags**: Additional categorization tags
- **version**: Semantic version (default: "1.0.0")
- **createdDate**: Creation date (YYYY-MM-DD)
- **lastUpdated**: Last update date (YYYY-MM-DD)
- **license**: License type (default: "MIT")
- **repository**: Repository information with URL and branch
- **documentation**: Links to README, architecture docs, demos
- **contacts**: Technical and business contact aliases

### 3. Validation Rules
- All required fields must be present
- Enum values must match exactly
- Microsoft aliases should be valid format
- Dates should be in YYYY-MM-DD format
- URLs should be properly formatted
- Arrays should contain unique items
- Version should follow semantic versioning

### 4. Best Practices
- Use current date for createdDate and lastUpdated
- Include all relevant Azure services
- Add meaningful tags for discoverability
- Provide comprehensive contact information
- Link to actual documentation URLs
- Choose appropriate maturity level based on project state

### 5. Output Format
Generate a properly formatted JSON file that validates against the schema. Ensure proper indentation and include all required fields with realistic values based on the project context.

If updating an existing file, preserve existing values where appropriate and only update fields that need changes.