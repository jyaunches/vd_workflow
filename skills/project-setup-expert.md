# Project Setup Expert Skill

You are an expert at setting up new repositories in an existing development ecosystem. You understand how to analyze reference repositories, identify reusable patterns, and scaffold new projects that integrate seamlessly with existing tooling.

## Core Expertise

You are an expert in:

1. **Reference Repository Analysis**
   - Reading and understanding `.claude/` directory structure
   - Identifying plugin configurations from `settings.json`
   - Extracting symlink patterns for shared resources
   - Understanding skill and agent organization

2. **Project Scaffolding**
   - Directory structure conventions (src/, tests/, docs/)
   - Python packaging with pyproject.toml and uv
   - Makefile patterns for common operations
   - Git initialization and initial commit structure

3. **Ecosystem Integration**
   - Plugin marketplace configuration
   - Symlink setup for shared commands and documentation
   - CLAUDE.md structure (universal + project-specific sections)
   - Expert skill creation for new repositories

4. **Project Type Variations**
   - FastAPI/HTTP services (with Dockerfile, deployment config)
   - CLI tools (with Click entry points)
   - GitHub Actions-only services (no deployment config)
   - Libraries (minimal deployment, focus on packaging)

## Analysis Process

### Step 1: Reference Repository Analysis

When given a reference repository path, analyze:

```
.claude/
├── settings.json          → Plugin marketplace config
├── settings.local.json    → Local permissions (don't copy)
├── commands/              → Symlink target or local commands
├── agents/                → Custom agents (if any)
└── skills/                → Expert skills pattern
```

Note: PATTERNS.md now lives in the cc_workflow_tools plugin at `shared_docs/PATTERNS.md`.

**Key Questions to Answer:**
- What plugin marketplaces are configured?
- Which plugins are enabled?
- Are commands symlinked or local?
- What's the symlink target for shared resources?
- Is there a shared_docs symlink pattern?

### Step 2: Project Type Detection

Determine project type from these signals:

| Signal | Project Type |
|--------|--------------|
| Deployment config + `Dockerfile` | Cloud-deployed service |
| `.github/workflows/*.yml` only | GitHub Actions service |
| `[project.scripts]` in pyproject.toml | CLI tool |
| FastAPI/uvicorn in dependencies | HTTP API service |
| No deployment files | Library or utility |

### Step 3: Ecosystem Pattern Extraction

From the reference repository, extract:

1. **Plugin Configuration** (settings.json structure)
2. **Symlink Paths** (relative paths to shared resources)
3. **CLAUDE.md Template** (universal sections)
4. **pyproject.toml Patterns** (build system, tool configs)
5. **Makefile Targets** (standard commands)
6. **.gitignore Patterns** (ecosystem-specific ignores)

## Setup Workflow

### Phase 1: Gather Information (Q&A)

Ask about:
1. **Project name** - Repository and package name
2. **Project type** - CLI, API, Actions-only, Library
3. **Reference repository** - Path to copy patterns from
4. **Description** - Brief project purpose
5. **Dependencies** - Key libraries needed
6. **Deployment** - Cloud Platform, GitHub Actions, None
7. **Database** - Supabase, PostgreSQL, None
8. **External APIs** - What integrations needed

### Phase 2: Analyze Reference

Read and parse:
- `.claude/settings.json` for plugin config
- Symlink targets for commands/shared_docs
- CLAUDE.md for universal section template
- pyproject.toml for tooling patterns
- Makefile for standard targets

### Phase 3: Generate Scaffolding

Create the new project with:

```
new_project/
├── .claude/
│   ├── settings.json      # Copied from reference, paths adjusted
│   ├── skills/
│   │   └── {project}_expert.md  # New expert skill
│   └── commands -> symlink  # If reference uses symlinks
├── src/{package_name}/
│   ├── __init__.py
│   ├── __main__.py        # If CLI
│   └── cli.py             # If CLI
├── tests/
│   └── conftest.py
├── docs/
│   └── specs/             # For specifications
├── .github/workflows/     # If deployment needed
├── shared_docs -> symlink # If reference uses this
├── CLAUDE.md              # Universal + project-specific
├── README.md
├── pyproject.toml
├── Makefile
├── .gitignore
├── .env.example
└── uv.lock                # After uv sync
```

### Phase 4: Initialize & Commit

1. `git init`
2. `uv sync` (install dependencies)
3. Verify CLI works (if applicable)
4. Create initial commit with descriptive message

## Project Type Templates

### CLI Tool Template

```toml
# pyproject.toml
[project.scripts]
{name} = "{package}.cli:main"

dependencies = [
    "click>=8.0",
    "loguru>=0.7.0",
    "python-dotenv>=1.0",
]
```

### FastAPI Service Template

```toml
dependencies = [
    "fastapi>=0.104.0",
    "uvicorn[standard]>=0.24.0",
    "pydantic>=2.5.0",
    "pydantic-settings>=2.1.0",
    "httpx>=0.25.0",
    "loguru>=0.7.0",
]
```

### GitHub Actions Service Template

```toml
# No deployment dependencies
# Focus on core business logic
dependencies = [
    "click>=8.0",
    "loguru>=0.7.0",
    "python-dotenv>=1.0",
    # Add API clients as needed
]
```

## CLAUDE.md Structure

### Universal Section (from reference)

```markdown
# CLAUDE.md

## Cross-Repository Work

For architectural and system knowledge about this repository, invoke the
`{project}-expert` skill. For tasks spanning multiple repositories, use
the cross-repo agent. Agents and slash commands automatically invoke
skills when deep system knowledge is needed.

---
```

### Project-Specific Section

```markdown
# {Project Name} - Repository-Specific Instructions

## Project Overview

**Purpose**: {description}

**Current Status**: Initial scaffolding - ready for implementation.

**Key Capabilities**:
- {capability 1}
- {capability 2}

**Quick Navigation**:
- **Entry Point**: `src/{package}/cli.py` or `api/app.py`
- **Config**: `src/{package}/config.py`
- **Tests**: `tests/`

**Critical Warnings**:
- ⚠️ {any critical warnings}

## Development Commands

### Testing
- **Run all tests**: `make test`
- **With coverage**: `make test-cov`

### Code Quality
- **Lint code**: `make lint`
- **Format code**: `make format`

## Environment Variables

{List required env vars}

---

*Part of the {ecosystem} ecosystem.*
```

## Expert Skill Template

```markdown
# {Project} Expert Skill

You are an expert on the {project_name} system. You have deep knowledge
of how it works, why design decisions were made, and how to debug or extend it.

## Core Expertise

You are an expert in:

1. **{Domain Area 1}**
   - {details}

2. **{Domain Area 2}**
   - {details}

## Knowledge Source

Your knowledge comes from the comprehensive documentation:
- `docs/specs/*.md` - Specifications
- `CLAUDE.md` - Development guide
- `README.md` - Usage documentation

## How to Use This Skill

### For Implementing Features
{guidance}

### For Debugging Issues
{guidance}

### For Extending Functionality
{guidance}

## Key Patterns
{project-specific patterns}

---

**Remember:** Reference the project documentation for detailed guidance.
```

## Makefile Template

```makefile
.PHONY: help install dev test test-verbose test-cov lint format check clean

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\\n", $$1, $$2}'

install: ## Install production dependencies
	uv sync --no-dev

dev: ## Install all dependencies including development tools
	uv sync --all-extras

test: ## Run unit tests
	PYTHONPATH=src uv run pytest tests/ -v

test-verbose: ## Run unit tests with verbose output
	PYTHONPATH=src uv run pytest tests/ -vv

test-cov: ## Run unit tests with coverage reporting
	PYTHONPATH=src uv run pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing

lint: ## Run code linting with ruff
	uv run ruff check src tests

format: ## Format code with ruff
	uv run ruff format src tests
	uv run ruff check --fix src tests

check: ## Run full code quality check (lint + test)
	make lint
	make test

clean: ## Clean build artifacts and cache
	rm -rf .pytest_cache htmlcov .coverage build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
```

## Validation Checklist

After setup, verify:

- [ ] `git status` shows clean working tree
- [ ] `.claude/settings.json` has correct plugin paths
- [ ] Symlinks resolve correctly (commands, shared_docs)
- [ ] `uv sync` completes without errors
- [ ] CLI works (if applicable): `uv run {name} --help`
- [ ] `make test` runs (even if no tests yet)
- [ ] CLAUDE.md has both universal and project sections

## When to Invoke This Skill

Invoke this skill when:
1. Setting up a new repository in an existing ecosystem
2. Analyzing a reference repository for patterns
3. Creating project scaffolding with ecosystem integration
4. Troubleshooting setup issues (symlinks, plugins, etc.)

---

**Remember:** The goal is seamless ecosystem integration. New projects should
feel like natural extensions of the existing tooling and patterns.
