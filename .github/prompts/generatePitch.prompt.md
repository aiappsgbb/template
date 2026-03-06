---
agent: 'agent'
model:
  - Claude Opus 4.6 (copilot)
  - Claude Sonnet 4 (copilot)
tools: ['githubRepo', 'search/codebase', 'edit', 'changes', 'runCommands']
description: 'Generate a professional PPTX pitch deck about this repository for sellers and presales engineers'
---

# Generate Pitch Deck

Create a polished, professional PowerPoint (PPTX) presentation about this repository. The deck is for **sellers and presales engineers** to pitch the solution to customers and stakeholders.

## Phase 1 — Research & Analysis

Before creating any slides, deeply analyze the repository:

1. **Read the README.md** — extract the value proposition, architecture, key features, prerequisites, and deployment steps
2. **Scan `/docs` folder** (if present) — pull in architecture diagrams descriptions, API docs, user guides
3. **Read `azure.yaml`** (if present) — understand services, infrastructure, deployment model
4. **Scan `/infra` folder** (if present) — identify Azure services used (from Bicep/Terraform files)
5. **Read `.github/ip-metadata.json`** (if present) — extract name, description, industry, services, patterns, tags, owner, contacts
6. **Scan `/src` folder structure** — understand the tech stack, languages, frameworks
7. **Look for demo assets** — screenshots, videos, architecture diagrams in `/assets`, `/docs`, or `/images`

Compile your findings into a structured brief before proceeding to slide creation.

## Phase 2 — Slide Deck Structure (15–20 slides max)

Build the deck with this structure. Adapt section lengths based on available content — skip sections that don't apply, but never exceed 20 slides.

### Section 1: Opening (2–3 slides)
- **Title slide** — Solution name, one-line tagline, date, "Confidential — Microsoft Internal"
- **Agenda** — Numbered list of sections in the deck
- **The Problem** — What customer pain point does this solve? Frame as a business problem, not a technical one

### Section 2: The Solution (3–5 slides)
- **Solution Overview** — 2–3 sentence elevator pitch + key differentiators (bullet points)
- **Architecture Diagram** — Describe the high-level architecture. If an architecture image exists in the repo, reference it. Otherwise create a text-based component diagram
- **Azure Services Used** — Table or visual showing each Azure service and its role (extract from Bicep/azure.yaml)
- **Key Features** — 3–5 headline features with one-line descriptions. Use icons or emoji for visual appeal
- **Demo Flow** (if demo info available) — Step-by-step walkthrough of the demo scenario

### Section 3: Technical Deep-Dive (3–5 slides)
- **Tech Stack** — Languages, frameworks, SDKs used (with version info if available)
- **Deployment Model** — How to deploy (azd up, CI/CD, manual). Prerequisites
- **Security & Compliance** — Authentication model, RBAC, secret management, networking
- **Integration Points** — APIs, data flows, external service connections

### Section 4: Business Value (2–3 slides)
- **Use Cases** — 2–3 concrete customer scenarios where this solution applies (infer from industry/pattern metadata)
- **Customer Outcomes** — What measurable outcomes can customers expect? (time saved, cost reduced, capability unlocked)
- **Competitive Advantage** — Why this approach vs. alternatives

### Section 5: Getting Started (2–3 slides)
- **Prerequisites** — What the customer/partner needs before starting
- **Quick Start** — 3–5 steps to get running (derived from README)
- **Resources & Next Steps** — Links to docs, repo, contacts. Clear call-to-action

### Section 6: Closing (1 slide)
- **Thank You / Q&A** — Contact info from ip-metadata.json contacts, repo URL

## Phase 3 — PPTX File Creation

Use the `python-pptx` library to create the actual `.pptx` file. Follow these visual design guidelines:

### Visual Standards
- **Color palette**: Use Microsoft brand-adjacent colors:
  - Primary: `#0078D4` (Microsoft Blue)
  - Secondary: `#50E6FF` (Light Azure Blue)
  - Accent: `#00B294` (Teal Green)
  - Dark: `#243A5E` (Dark Navy) for backgrounds on title/section dividers
  - Text: `#323130` (near-black) on white, `#FFFFFF` on dark backgrounds
- **Fonts**: Use `Segoe UI` (headings) and `Segoe UI` (body) — available on all Windows machines
- **Slide dimensions**: Widescreen 16:9 (13.33" × 7.5")
- **Margins**: At least 0.5" on all sides
- **Font sizes**:
  - Slide titles: 28–32pt bold
  - Subtitles: 18–20pt
  - Body text: 14–16pt
  - Footnotes/captions: 10–12pt

### Layout Rules
- **Max 6 bullet points per slide** — if more content, split across slides
- **No walls of text** — use short phrases, not sentences
- **Use two-column layouts** where comparing items (e.g., before/after, features table)
- **Section divider slides** — dark navy background with white text, used between major sections
- **Footer on every content slide**: solution name on left, "Microsoft Confidential" on right, slide number centered

### Implementation Steps
1. Install python-pptx: `pip install python-pptx`
2. Create the presentation programmatically
3. Save as `PITCH_DECK.pptx` in the repository root
4. Commit the file

## Required Deliverable

You **MUST** create a file named `PITCH_DECK.pptx` in the root of the repository containing the complete presentation.

## Quality Checklist

Before finalizing, verify:
- [ ] Deck has 15–20 slides (no more, no fewer than 12)
- [ ] Title slide has solution name and tagline
- [ ] Architecture section accurately reflects the repo's actual Azure services
- [ ] No placeholder text remains (e.g., "[INSERT HERE]")
- [ ] All bullet points are concise (≤15 words each)
- [ ] Color scheme is consistent throughout
- [ ] Footer appears on all content slides
- [ ] File is saved as `PITCH_DECK.pptx` in repo root
- [ ] Content is factual — derived from actual repo contents, not hallucinated
