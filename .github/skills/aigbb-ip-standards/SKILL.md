---
name: aigbb-ip-standards
description: "IP metadata and compliance standards for Azure Developer CLI templates. Defines the ip-metadata.json schema, repository structure requirements, compliance validation checklists, and maturity-level criteria. Use when creating ip-metadata.json, running IP compliance checks, validating repository readiness, checking maturity levels, or preparing templates for publication. Triggers on ip-metadata, IP compliance, maturity level, Gold Silver Bronze, repository structure, ip-metadata.json, compliance check, template validation, publication readiness."
---

# IP Standards & Compliance

Standards for Azure Developer CLI template metadata, repository structure, and publication readiness. Every template repository MUST include `.github/ip-metadata.json` validated against `.github/ip-metadata.schema.json`.

> **Community skills**: For additional compliance skills, see the [microsoft/skills](https://github.com/microsoft/skills) community repository.

---

## 1. IP Metadata Schema

### Required Fields

| Field | Type | Constraints | Example |
|-------|------|-------------|---------|
| `name` | string | 1–100 chars | `"Contoso Chat Assistant"` |
| `description` | string | 10–500 chars | `"Multi-turn chat assistant with RAG"` |
| `maturity` | enum | `Gold` / `Silver` / `Bronze` | `"Silver"` |
| `region` | enum | `AMER` / `EMEA` / `ASIA` | `"AMER"` |
| `industry` | enum | See industry list below | `"Financial Services"` |
| `owner` | string | Microsoft alias pattern `^[a-zA-Z0-9._-]+$` | `"johndoe"` |
| `pattern` | string[] | ≥1, unique, from pattern enum | `["AI/ML", "Cloud Native"]` |
| `services` | string[] | ≥1, unique Azure service names | `["Azure OpenAI", "Azure Container Apps"]` |

### Optional Fields

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `tags` | string[] | — | Additional categorization; unique, 1–50 chars each |
| `version` | string | `"1.0.0"` | Semantic versioning `^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?$` |
| `createdDate` | string | — | `YYYY-MM-DD` format |
| `lastUpdated` | string | — | `YYYY-MM-DD` format |
| `license` | string | `"MIT"` | `MIT`, `Apache-2.0`, `GPL-3.0`, `BSD-3-Clause`, `Proprietary` |
| `repository` | object | — | `{ "url": "https://...", "branch": "main" }` |
| `documentation` | object | — | `{ "readme": "...", "architecture": "...", "demo": "..." }` |
| `contacts` | object | — | `{ "technical": ["alias"], "business": ["alias"] }` |

### Industry Enum

`Cross`, `Financial Services`, `Retail`, `Energy`, `Healthcare`, `Manufacturing`, `Government`, `Education`, `Media & Entertainment`, `Technology`

### Pattern Enum

`AI/ML`, `Data & Analytics`, `Application Innovation`, `Infrastructure`, `Security`, `IoT`, `Mixed Reality`, `Sustainability`, `Digital Transformation`, `Cloud Native`, `Integration`, `Business Intelligence`, `DevOps`, `OCR`, `Document Intelligence`, `Voice`

### Minimal Valid Example

```json
{
  "name": "Contoso Chat Assistant",
  "description": "Multi-turn chat assistant using Azure OpenAI and AI Search with RAG pattern",
  "maturity": "Silver",
  "region": "AMER",
  "industry": "Technology",
  "owner": "johndoe",
  "pattern": ["AI/ML", "Cloud Native"],
  "services": [
    "Azure OpenAI",
    "Azure AI Search",
    "Azure Container Apps",
    "Azure Key Vault",
    "Azure Monitor"
  ],
  "version": "1.0.0",
  "createdDate": "2025-01-15",
  "lastUpdated": "2025-01-15",
  "license": "MIT",
  "tags": ["chat", "rag", "openai"]
}
```

### Full Example with Optional Fields

```json
{
  "name": "Contoso Chat Assistant",
  "description": "Multi-turn chat assistant using Azure OpenAI and AI Search with RAG pattern for enterprise knowledge bases",
  "maturity": "Gold",
  "region": "AMER",
  "industry": "Financial Services",
  "owner": "johndoe",
  "pattern": ["AI/ML", "Application Innovation", "Cloud Native"],
  "services": [
    "Azure OpenAI",
    "Azure AI Search",
    "Azure Container Apps",
    "Azure Cosmos DB",
    "Azure Key Vault",
    "Azure Monitor",
    "Azure Storage",
    "AI Foundry"
  ],
  "version": "2.1.0",
  "createdDate": "2024-06-01",
  "lastUpdated": "2025-01-15",
  "license": "MIT",
  "tags": ["chat", "rag", "openai", "financial-services", "enterprise"],
  "repository": {
    "url": "https://github.com/contoso/chat-assistant",
    "branch": "main"
  },
  "documentation": {
    "readme": "https://github.com/contoso/chat-assistant#readme",
    "architecture": "https://github.com/contoso/chat-assistant/blob/main/docs/ARCHITECTURE.md",
    "demo": "https://aka.ms/contoso-chat-demo"
  },
  "contacts": {
    "technical": ["johndoe", "janedoe"],
    "business": ["pmsmith"]
  }
}
```

---

## 2. Maturity Levels

### Gold

- `azd up` succeeds end-to-end with zero manual steps
- Comprehensive README with prerequisites, quickstart, architecture diagram
- Full Bicep infrastructure with managed identity (zero API keys)
- Health check endpoints on all services
- OpenTelemetry + Application Insights integration
- CI/CD workflows in `.github/workflows/`
- Unit and integration tests present
- IP metadata complete with all optional fields
- Architecture documentation in `docs/ARCHITECTURE.md`

### Silver

- `azd up` succeeds with minimal configuration (environment variables only)
- README with prerequisites and deployment instructions
- Bicep infrastructure with managed identity
- Health check endpoints
- Structured logging (no `print()` / `console.log()`)
- IP metadata complete with all required fields
- At least one test file present

### Bronze

- `azd up` completes with documented manual steps
- README with basic usage instructions
- Working Bicep infrastructure
- IP metadata with all required fields
- Basic error handling

---

## 3. Repository Structure Requirements

### Required Files & Directories

```
├── README.md                        # Comprehensive project documentation
├── LICENSE                          # License file (MIT default)
├── azure.yaml                       # azd configuration
├── .gitignore                       # Appropriate exclusions
├── infra/
│   ├── main.bicep                   # Primary Bicep template
│   └── main.parameters.json         # Parameter definitions
├── src/                             # Application source code
│   └── <service>/                   # One folder per azure.yaml service
└── .github/
    ├── ip-metadata.json             # IP metadata (REQUIRED)
    └── ip-metadata.schema.json      # JSON Schema for validation
```

### Recommended Files & Directories

```
├── docs/
│   └── ARCHITECTURE.md              # Architecture documentation
├── assets/                          # Images, diagrams
├── tests/                           # Test suites
├── infra/
│   ├── abbreviations.json           # Resource naming abbreviations
│   └── core/                        # Reusable Bicep modules
├── .github/
│   ├── copilot-instructions.md      # Copilot customization
│   ├── workflows/                   # CI/CD pipelines
│   ├── prompts/                     # Copilot prompts
│   ├── skills/                      # Copilot skills
│   └── agents/                      # Copilot agents
```

---

## 4. Compliance Checklist

Use this checklist when validating a repository for publication readiness.

### IP Metadata (CRITICAL)

- [ ] `.github/ip-metadata.json` exists
- [ ] Validates against `.github/ip-metadata.schema.json`
- [ ] All 8 required fields present and valid
- [ ] Enum values match schema definitions exactly
- [ ] `owner` alias follows `^[a-zA-Z0-9._-]+$` pattern
- [ ] Dates in `YYYY-MM-DD` format
- [ ] `services` array lists all Azure services actually used
- [ ] `maturity` level matches actual repository quality (see §2)

### Repository Structure

- [ ] `README.md` — comprehensive with prerequisites, quickstart, architecture
- [ ] `LICENSE` — present and correct
- [ ] `azure.yaml` — valid YAML, all services declared
- [ ] `infra/main.bicep` — syntactically valid (`az bicep build`)
- [ ] `infra/main.parameters.json` — all parameters defined
- [ ] `src/` — application code organized by service
- [ ] `.gitignore` — Python/Node/.NET ignores as appropriate
- [ ] No secrets or credentials in repository

### Azure Developer CLI

- [ ] `azd init` succeeds (if new project)
- [ ] `azd provision --preview` shows expected resources
- [ ] `azd up` completes successfully
- [ ] All services deploy and respond to health checks
- [ ] `remoteBuild: true` set for container services in `azure.yaml`

### Security

- [ ] Zero API keys — managed identity only (see `aigbb-azure-security` skill)
- [ ] `ChainedTokenCredential` pattern for Azure SDK authentication
- [ ] RBAC follows least-privilege principle
- [ ] Key Vault for any remaining secrets
- [ ] No sensitive data in Bicep parameters or outputs

### Observability (Gold/Silver)

- [ ] Health check endpoint (`GET /health`) on all services
- [ ] OpenTelemetry tracing with Azure Monitor export (see `aigbb-observability` skill)
- [ ] Structured logging — never `print()` / `console.log()`
- [ ] `APPLICATION_INSIGHTS_CONNECTION_STRING` configured in Bicep

### Documentation

- [ ] README covers: overview, prerequisites, quickstart, architecture, deployment
- [ ] `docs/ARCHITECTURE.md` exists (Gold requirement)
- [ ] API documentation if service exposes endpoints
- [ ] Troubleshooting section with common issues

---

## 5. Auto-Fix Guidance

When compliance violations are found, prioritize fixes in this order:

| Priority | Category | Auto-fixable? |
|----------|----------|:-------------:|
| P0 | Missing `ip-metadata.json` | Yes — generate from repo analysis |
| P0 | Secrets in code/config | No — manual removal + Key Vault setup |
| P1 | Missing `LICENSE` | Yes — create MIT license |
| P1 | Invalid `azure.yaml` | Partial — fix syntax, add `remoteBuild` |
| P1 | Missing health endpoints | Yes — add `GET /health` route |
| P2 | Incomplete README | Partial — generate template sections |
| P2 | Missing `.gitignore` entries | Yes — add language-specific patterns |
| P3 | Missing tests | No — requires application knowledge |
| P3 | Missing architecture docs | Partial — generate template |

### Auto-fix workflow

1. Run compliance checklist
2. Generate findings report with pass/fail/warning
3. List auto-fixable items with proposed changes
4. **Ask user permission** before applying any fix
5. Apply approved fixes
6. Re-run checklist to confirm resolution

---

## Validation

### Local JSON Schema Validation

```bash
# Python
python -c "
import json, jsonschema
schema = json.load(open('.github/ip-metadata.schema.json'))
data = json.load(open('.github/ip-metadata.json'))
jsonschema.validate(data, schema)
print('Valid')
"
```

### PowerShell Quick Check

```powershell
$schema = Get-Content .github/ip-metadata.schema.json | ConvertFrom-Json
$data = Get-Content .github/ip-metadata.json | ConvertFrom-Json

# Check required fields
$required = @('name','description','maturity','region','industry','owner','pattern','services')
$missing = $required | Where-Object { -not $data.PSObject.Properties[$_] }
if ($missing) { Write-Error "Missing: $($missing -join ', ')" }
else { Write-Host "All required fields present" -ForegroundColor Green }
```

---

## References

- Schema file: `.github/ip-metadata.schema.json`
- Related skills: `aigbb-azure-security`, `aigbb-azd-compliance`, `aigbb-observability`
- Related prompts: `ipCompliance.prompt.md`, `ipMetadata.prompt.md`
