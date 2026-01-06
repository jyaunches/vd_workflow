# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Claude Code plugin (`cc_workflow_tools`) that provides spec-driven development workflow commands and agents. It implements a structured approach to feature development: Spec Creation → Spec Review → TDD Implementation → Validation.

## Plugin Structure

```
.claude-plugin/plugin.json    # Plugin manifest with hooks
commands/                     # Slash commands (markdown files)
  feature_wf/                 # Feature workflow commands
  init.md, fix-tests.md, etc. # Utility commands
agents/                       # Agent definitions (markdown files)
skills/                       # Expert skills (markdown files)
hooks/                        # Session hooks (shell scripts)
```

## Key Workflows

### Complete Feature Workflow
`/cc_workflow_tools:feature_wf:execute-workflow <spec_file>` runs the full automated workflow:

1. **Review Phase** (review-executor agent): Simplify spec → Generate test spec → Design review → Implementation review
2. **Implementation Phase** (feature-writer agent): TDD phase-by-phase implementation with beads tracking

### Manual Steps
- `/cc_workflow_tools:feature_wf:spec <name> "<description>"` - Create new specification (includes validation design Q&A)
- `/cc_workflow_tools:feature_wf:implement-phase <spec> <test_spec> [--auto]` - Execute implementation phases

### Validation Design Workflow

Every `/spec` command now includes a validation design phase:

1. **After spec creation**, `/design-validation` is automatically invoked
2. **Q&A phase**: Asks about deployment type and proposes validation requirements
3. **User confirms** validation requirements
4. **Subagent researches** available tools (MCP servers, CLIs, SDKs)
5. **Recommendations presented**: Use existing, install, or build custom tools
6. **If building**: `/build-validation-tool` creates reusable tools in this plugin
7. **Validation phase added** to the spec

The `validation-expert` skill tracks known validation methods and learns from discoveries.

## Agent Architecture

Agents are Tier 2 orchestrators that route to slash commands:
- **spec-writer** (opus): Creates technical specifications
- **review-executor** (sonnet): Orchestrates spec review phase
- **feature-writer** (sonnet): Implements phases using beads for progress tracking
- **tests-writer**: Generates test suites
- **feature-architect**: Analyzes architecture and designs solutions
- **validation-researcher** (sonnet): Discovers validation tools and recommends approaches (subagent)

## Skills

Skills provide domain expertise:
- **project-setup-expert**: Repository scaffolding and ecosystem integration
- **validation-expert**: Validation tool catalog and deployment-specific patterns

## Specification Format Requirements

Phase headers must follow this exact format for `/implement-phase` compatibility:
```markdown
## Phase 1: [Name]
## Phase 2: [Name] [COMPLETED: git-sha]
```

All specs must include a final "Clean the House" phase for post-implementation cleanup.

## Project Setup

When this plugin is used in a project, it expects:
- `.claude/PATTERNS.md` - Defines patterns for auto-apply decisions
- `specs/` directory - Where specifications are stored

Run `/cc_workflow_tools:init` to create these.

### New Repository Setup

To scaffold a new repository with full ecosystem integration:

`/cc_workflow_tools:setup-project [--reference <repo_path>]`

This Q&A-driven command will:
1. **Analyze a reference repository** to extract plugin config, symlinks, and patterns
2. **Ask questions** about project type, dependencies, and deployment
3. **Generate scaffolding** with appropriate files and ecosystem integration
4. **Set up symlinks** for shared commands and documentation
5. **Create expert skill** for the new repository
6. **Initialize git** with a proper initial commit

The `project-setup-expert` skill provides detailed guidance on repository analysis and scaffolding patterns.

## Plugin Cache Management

When this plugin is updated (new commands, skills, or agents), Claude Code doesn't automatically pick up changes due to caching. This is a known issue (GitHub #14061, #15369, #15642).

**To refresh the plugin after updates:**

```bash
# Clear the plugin cache
rm -rf ~/.claude/plugins/cache/

# Then restart Claude Code sessions
```

This is required after:
- Adding new commands, skills, or agents
- Modifying existing files
- Changing plugin structure

## Key Principles Enforced

- **No backward compatibility** - Always direct integration, no parallel systems
- **TDD approach** - Write failing tests first
- **Phase-based implementation** - Incremental, buildable phases
- **No code in specs** - Architecture described conceptually only
