---
description: "Generate a structured research plan for Azure services and SDKs. Delegates to the azure-docs-research agent."
model:
  - Claude Opus 4.6 (copilot)
  - Claude Sonnet 4 (copilot)
agent: azure-docs-research
---

Run Phase 1 (Plan) of your research workflow for the following request. Generate a structured research plan — scope snapshot, topics, resolved Context7 library IDs, refined search terms, and open notes. Save the plan to `.github/scratchpad/research-plan-[TIMESTAMP].md` using the template from `.github/templates/research-plan-template.md`.

User request:

$ARGUMENTS