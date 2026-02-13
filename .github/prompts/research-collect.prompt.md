---
description: "Execute documentation collection for all refined search terms using Context7 and MS Learn. Delegates to the azure-docs-research agent."
model:
  - Claude Opus 4.6 (copilot)
  - Claude Sonnet 4 (copilot)
agent: azure-docs-research
---

Run Phase 2 (Collect) of your research workflow. A finalized research plan must exist in `.github/scratchpad/research-plan-*.md`. For every refined search term in the plan, execute the tool-call sequence (MS Learn search → code samples → Context7 docs → full page fetch → Azure MCP → web search fallback) and produce structured Findings. Save to `.github/scratchpad/research-collection-[TIMESTAMP].md` using the template from `.github/templates/research-collection-template.md`.

Do NOT stop until every refined search term has a completed Finding or justified N/A.

User input:

$ARGUMENTS