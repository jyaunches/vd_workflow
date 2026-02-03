---
name: validation-expert
description: |
  Expert at designing and executing validation strategies for software deployments.
  Use when creating acceptance criteria, discovering validation tools, designing E2E
  validation scenarios, or building custom validation automation. Triggers: validation,
  testing, E2E, acceptance criteria, deployment verification, MCP servers, browser
  automation, database verification, health checks.
user-invocable: true
---

# Validation Expert Skill

Expert at validating software deployments. Understands available validation tools and recommends strategies based on deployment type.

## Core Principle: E2E Validation is NOT Optional

**When MCP tools are available (Playwright, Supabase, etc.), E2E validation is REQUIRED.**

- Unit tests verify isolated logic; E2E validates complete user journeys
- Unit tests do NOT substitute for E2E when tools are available
- If Playwright MCP is available for user-facing code, you MUST execute E2E validation

## Core Expertise

1. **Validation Strategy Design** - Choosing methods, balancing thoroughness vs speed
2. **Tool Catalog Knowledge** - Universal tools, MCP servers, project-specific patterns
3. **Deployment-Aware Validation** - Cloud, GitHub Actions, CLI, API patterns
4. **Tool Discovery** - MCP session detection, config file parsing
5. **Real Data Philosophy** - Use actual system data over synthetic test data

## Known Validation Methods

### Universal Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| pytest | Python test runner | `pytest tests/` |
| jest | JavaScript test runner | `npm test` |
| gh | GitHub CLI | `gh run list`, `gh pr checks` |
| curl | HTTP testing | `curl -f <url>` |

### MCP Servers

**CRITICAL**: Check what MCP servers are available in the current session via `mcp__*` tool patterns.

| Server | Tool Pattern | Validation Uses |
|--------|--------------|-----------------|
| Playwright | `mcp__playwright__*` | Browser automation, WhatsApp Web, UI testing |
| Supabase | `mcp__supabase__*` | Query state changes, verify persistence |
| GitHub | `mcp__github__*` | PR checks, workflow status |

## Deployment-Specific Patterns

### Cloud Platform
1. Health check: `curl -f <url>/health`
2. Platform status via CLI/API
3. Smoke test API request
4. Review logs for errors

### GitHub Actions
1. `gh run list --workflow=<name>`
2. `gh pr checks`
3. `gh run download` for artifacts

### CLI Tools
1. `<tool> --help` exits 0
2. `<tool> --version`
3. Run basic operation
4. Non-zero exit on error

### API Services
1. GET /health returns 200
2. Key endpoints respond correctly
3. Error responses are appropriate

## MCP Session Discovery

```
Look for tool names starting with mcp__:
- mcp__playwright__* → Browser automation available
- mcp__supabase__* → Database access available
- mcp__github__* → GitHub API available
```

This is the most reliable way to know what validation tools are available.

### Discovery Commands

```bash
# Check MCP servers in config
cat .claude/settings.json | jq '.mcpServers // empty'

# Check for global CLIs
which gh supabase aws gcloud 2>/dev/null
```

## GitHub Issue/PR Validation

### Analyzing PRs

```bash
gh pr view <number> --json title,body,files,commits,state
```

### PR File Change Patterns

| File Pattern | Validation Approach |
|--------------|---------------------|
| `.github/workflows/*.yml` | Trigger workflow, verify status |
| `**/service.py` | Run unit tests |
| `*.yaml` config | Verify config parses |
| `**/api/**/*.py` | Hit endpoints with curl |
| `streamlit_app/**/*.py` | Playwright for UI |
| `tests/**/*.py` | Run `pytest` |

### PR Triage Categories

**Merge Directly** (NO code changes): Workflow files, YAML config, docs

**Unit Tests + E2E** (Playwright available): Code changes with tests

**E2E Required**: WhatsApp handlers, multi-system integration, user-facing workflows

## Recommendation Output Format

```markdown
## Validation Recommendations

### Discovered Tools
- [List of tools found]

### For: [Requirement]

**Option A: Use Existing** (Recommended)
- Tool: [name]
- Usage: [command]
- Coverage: [what it validates]

**Option B: Install**
- Tool: [name]
- Installation: [command]

**Option C: Build Custom**
- Purpose: [what it does]
- Input/Process/Output
```

## When to Invoke

1. Creating specs with deployment/validation phases
2. Designing validation strategies for new features
3. Recommending validation tools
4. Building validation automation
5. Analyzing GitHub PRs/issues for validation needs
