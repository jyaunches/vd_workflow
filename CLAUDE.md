# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Claude Code plugin (`vd_workflow`) that provides spec-driven development workflow commands and agents. It implements a structured approach to feature development: Spec Creation → Spec Review → TDD Implementation → Validation.

## Repository Structure (Marketplace Layout)

```
vd_workflow/                    # Marketplace root
├── .claude-plugin/
│   └── marketplace.json              # Marketplace manifest
├── plugins/
│   └── vd_workflow/            # Plugin directory
│       ├── .claude-plugin/
│       │   └── plugin.json           # Plugin manifest
│       ├── commands/                 # Slash commands
│       │   ├── spec.md               # Create new specification
│       │   ├── execute-wf.md         # Run full automated workflow
│       │   ├── spec/                 # Spec support commands
│       │   └── execute-wf/           # Workflow support commands
│       ├── agents/                   # Agent definitions
│       ├── skills/                   # Expert skills
│       ├── hooks/                    # Session hooks
│       └── shared_docs/              # Shared documentation
├── CLAUDE.md                         # This file
└── README.md                         # User documentation
```

## Key Workflows

### Complete Feature Workflow
`/vd_workflow:execute-wf <spec_file>` runs the full automated workflow:

1. **Review Phase** (review-executor agent): Simplify spec → Generate test spec → Design review → Implementation review
2. **Implementation Phase** (feature-writer agent): TDD phase-by-phase implementation with beads tracking

### Manual Steps
- `/vd_workflow:spec <name> "<description>"` - Create new specification (includes validation design Q&A)
- `/vd_workflow:execute-wf:implement-phase <spec> <test_spec> [--auto]` - Execute implementation phases

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
- **feature-writer** (sonnet): Implements phases using git SHA markers for progress tracking
- **tests-writer**: Generates test suites
- **feature-architect**: Analyzes architecture and designs solutions
- **validation-researcher** (sonnet): Discovers validation tools and recommends approaches (subagent)

## Skills

Skills provide domain expertise:
- **validation-expert**: Validation tool catalog and deployment-specific patterns

## Specification Format Requirements

Phase headers must follow this exact format for `/implement-phase` compatibility:
```markdown
## Phase 1: [Name]
## Phase 2: [Name] [COMPLETED: git-sha]
```

All specs must include a final "Clean the House" phase for post-implementation cleanup.

The plugin includes `shared_docs/PATTERNS.md` which defines patterns for auto-apply decisions during spec reviews.

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
