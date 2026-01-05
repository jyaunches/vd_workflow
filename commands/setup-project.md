---
name: setup-project
description: Set up a new repository with ecosystem integration via Q&A-driven scaffolding
usage: /cc_workflow_tools:setup-project [--reference <repo_path>]
argument-hint: "[--reference ../existing_repo]"
examples:
  - /cc_workflow_tools:setup-project
  - /cc_workflow_tools:setup-project --reference ../benz_researcher
---

# setup-project: $ARGUMENTS

Set up a new repository with full ecosystem integration. This command guides you through a Q&A process to scaffold a new project that integrates with your existing Claude Code resources, plugins, and tooling.

## Overview

This command will:
1. **Analyze a reference repository** (optional) to extract patterns
2. **Ask questions** to determine project configuration
3. **Generate scaffolding** with appropriate files and structure
4. **Set up ecosystem integration** (plugins, symlinks, skills)
5. **Initialize and verify** the new project

## Phase 1: Reference Repository Analysis

If a reference repository is provided (or you want to specify one), analyze it first.

### Step 1.1: Identify Reference Repository

**Ask the user:**

```
Do you have a reference repository to copy patterns from?

This helps ensure consistency across your ecosystem by extracting:
- Plugin marketplace configuration
- Symlink patterns for shared resources
- CLAUDE.md structure and universal sections
- Makefile targets and pyproject.toml patterns

Options:
1. Yes, use this reference: [path]
2. No, start fresh (I'll configure manually)
```

### Step 1.2: Analyze Reference (if provided)

Read and extract from the reference repository:

**`.claude/settings.json`** - Plugin configuration:
```bash
# Read and understand the plugin marketplace setup
cat {reference}/.claude/settings.json
```

**Symlink targets** - Shared resources:
```bash
# Check for symlinked directories
ls -la {reference}/.claude/commands  # Is it a symlink? Where to?
ls -la {reference}/shared_docs        # Shared documentation?
```

**CLAUDE.md** - Universal sections:
```bash
# Read to extract universal/ecosystem sections
cat {reference}/CLAUDE.md
```

**Present findings to user:**
```
Reference Repository Analysis: {reference}

Plugin Configuration:
  Marketplace: {marketplace_path}
  Enabled Plugins: {plugin_list}

Symlink Patterns:
  Commands: {commands_target or "local"}
  Shared Docs: {shared_docs_target or "none"}

CLAUDE.md Universal Section: {lines} lines detected
pyproject.toml Build System: {build_backend}
Makefile Targets: {target_list}

I'll use these patterns for the new project.
```

## Phase 2: Project Configuration (Q&A)

Ask the following questions to configure the new project. Use the `AskUserQuestion` tool for structured input.

### Question 2.1: Project Identity

```
Project Setup - Identity

1. Project Name:
   - Repository name (e.g., benz_position_manager)
   - Package name will be derived (benz_position_manager → benz-position-manager)

2. Project Description:
   - Brief one-line description of the project's purpose
```

### Question 2.2: Project Type

```
What type of project is this?

Options:
1. CLI Tool - Command-line application with Click entry point
2. FastAPI Service - HTTP API deployed to Fly.io
3. GitHub Actions Service - Runs via scheduled/triggered workflows only
4. Library - Reusable package, no deployment
5. Other - Custom configuration
```

### Question 2.3: Deployment Configuration

Based on project type, ask about deployment:

**For FastAPI Service:**
```
Deployment Configuration:

1. Fly.io App Name: (e.g., benz-researcher)
2. Internal Port: (default: 8000)
3. Memory: (default: 512mb)
```

**For GitHub Actions Service:**
```
GitHub Actions Configuration:

1. Workflow Name: (e.g., eod-liquidation)
2. Schedule: (cron expression, or "manual only")
```

**For CLI/Library:**
```
No deployment configuration needed.
```

### Question 2.4: Dependencies

```
What are the key dependencies for this project?

Common options (select all that apply):
1. Database: asyncpg, psycopg2, sqlalchemy
2. HTTP Client: httpx, requests
3. API Framework: fastapi, flask
4. CLI: click, typer
5. Logging: loguru
6. External APIs: (specify which)
7. Other: (specify)
```

### Question 2.5: Environment Variables

```
What environment variables will this project need?

Categories:
1. API Keys (e.g., ALPACA_API_KEY, OPENAI_API_KEY)
2. Database (e.g., DATABASE_URL, SUPABASE_URL)
3. Email (e.g., SENDGRID_API_KEY)
4. Other (specify)
```

## Phase 3: Generate Scaffolding

Based on the answers, generate the project structure.

### Step 3.1: Create Directory Structure

```bash
mkdir -p {project_name}/{.claude/skills,src/{package_name},tests,docs/specs,.github/workflows}
cd {project_name}
git init
```

### Step 3.2: Create .claude/settings.json

Copy from reference (adjusting paths) or create fresh:

```json
{
  "extraKnownMarketplaces": {
    "{marketplace_name}": {
      "source": {
        "source": "directory",
        "path": "{relative_path_to_plugins}"
      }
    }
  },
  "enabledPlugins": {
    "{plugin1}@{marketplace}": true,
    "{plugin2}@{marketplace}": true
  }
}
```

### Step 3.3: Set Up Symlinks

If reference uses symlinks, create them:

```bash
# Commands symlink (if reference uses it)
cd .claude
ln -s {relative_path_to_commands} commands
cd ..

# Shared docs symlink (if reference uses it)
ln -s {relative_path_to_shared_docs} shared_docs
```

### Step 3.4: Create CLAUDE.md

Combine universal section (from reference) with project-specific content:

```markdown
# CLAUDE.md

## Cross-Repository Work

{Universal section from reference or standard template}

---

# {Project Name} - Repository-Specific Instructions

## Project Overview

**Purpose**: {description}

**Current Status**: Initial scaffolding - ready for implementation.

**Key Capabilities**:
- {derived from project type and dependencies}

## Development Commands

{Standard commands section}

## Environment Variables

{From Q&A answers}

---

*Part of the ecosystem.*
```

### Step 3.5: Create pyproject.toml

Based on project type and dependencies:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "{package_name}"
version = "0.1.0"
description = "{description}"
requires-python = ">=3.11"
dependencies = [
    {dependencies from Q&A}
]

[dependency-groups]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "ruff>=0.1.0",
]

{CLI entry point if applicable}

[tool.pytest.ini_options]
asyncio_mode = "auto"
pythonpath = ["src"]
testpaths = ["tests"]

[tool.ruff]
target-version = "py311"
line-length = 88
src = ["src", "tests"]
```

### Step 3.6: Create Makefile

Standard targets (from reference or template):

```makefile
# {Project Name} Development Makefile

.PHONY: help install dev test lint format check clean

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\\n", $$1, $$2}'

install: ## Install production dependencies
	uv sync --no-dev

dev: ## Install all dependencies
	uv sync --all-extras

test: ## Run tests
	PYTHONPATH=src uv run pytest tests/ -v

lint: ## Lint code
	uv run ruff check src tests

format: ## Format code
	uv run ruff format src tests

check: ## Full quality check
	make lint
	make test

clean: ## Clean artifacts
	rm -rf .pytest_cache htmlcov .coverage build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
```

### Step 3.7: Create Source Files

**`src/{package}/__init__.py`**:
```python
"""{description}"""
__version__ = "0.1.0"
```

**`src/{package}/__main__.py`** (if CLI):
```python
from {package}.cli import main
if __name__ == "__main__":
    main()
```

**`src/{package}/cli.py`** (if CLI):
```python
"""CLI entry point."""
import click

@click.group()
@click.version_option()
def main():
    """{description}"""
    pass

# Add commands here

if __name__ == "__main__":
    main()
```

### Step 3.8: Create Expert Skill

**`.claude/skills/{project}_expert.md`**:
```markdown
# {Project} Expert Skill

You are an expert on the {project_name} system...
{Generated based on project type and purpose}
```

### Step 3.9: Create Supporting Files

- **README.md** - Project documentation
- **.gitignore** - From reference or standard Python template
- **.env.example** - Environment variables from Q&A
- **tests/conftest.py** - Test fixtures

## Phase 4: Initialize and Verify

### Step 4.1: Install Dependencies

```bash
cd {project_name}
uv sync
```

### Step 4.2: Verify Setup

```bash
# Check CLI works (if applicable)
uv run {cli_name} --help

# Check symlinks resolve
ls -la .claude/commands
ls -la shared_docs

# Check make targets
make help
```

### Step 4.3: Create Initial Commit

```bash
git add .
git commit -m "Initial project scaffolding for {project_name}

- {project_type} with {key_features}
- Ecosystem integration via {plugins}
- {deployment_info if applicable}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Phase 5: Present Summary

After completion, present:

```
✅ Project Setup Complete: {project_name}

Location: {full_path}

Created Files:
  ├── .claude/
  │   ├── settings.json (plugins configured)
  │   ├── commands -> {symlink_target}
  │   └── skills/{project}_expert.md
  ├── src/{package}/
  │   ├── __init__.py
  │   └── {entry_files}
  ├── tests/conftest.py
  ├── CLAUDE.md
  ├── README.md
  ├── pyproject.toml
  ├── Makefile
  ├── .gitignore
  └── .env.example

Ecosystem Integration:
  ✓ Plugins: {enabled_plugins}
  ✓ Shared Commands: {commands_status}
  ✓ Shared Docs: {docs_status}

Verification:
  ✓ uv sync: {status}
  ✓ CLI works: {status or N/A}
  ✓ Git initialized with {n} commits

Next Steps:
  1. cd {project_name}
  2. Create specification: /cc_workflow_tools:feature_wf:spec
  3. Implement phases: /cc_workflow_tools:feature_wf:implement-phase
```

## Error Handling

If any step fails:

1. **Reference not found**: Ask for valid path or proceed without reference
2. **Symlink target not found**: Create local directories instead
3. **uv sync fails**: Show error, suggest checking pyproject.toml
4. **Permission errors**: Suggest checking directory permissions

## Tips

- Use `--reference` to ensure consistency with existing projects
- The reference repository doesn't need to be the same project type
- Symlinks only work if the target directories exist
- After setup, use `/cc_workflow_tools:feature_wf:spec` to create your first specification
