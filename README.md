# vd_workflow

A Claude Code plugin providing spec-driven development workflow with TDD methodology.

## Overview

This plugin provides generic workflow commands and agents for any software project. It implements a structured approach to feature development:

1. **Spec Creation** - Write technical specifications
2. **Spec Review** - Simplify, generate tests, review design/implementation
3. **Implementation** - TDD-based phase-by-phase development
4. **Validation** - Verify acceptance criteria

## Installation

### Option 1: GitHub Marketplace (Recommended for New Environments)

Add the marketplace and install in one step:

```bash
# Add marketplace from GitHub
/plugin marketplace add yourorg/vd_workflow

# Install the plugin
/plugin install vd_workflow@vd_workflow
```

Or configure in `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "vd_workflow": {
      "source": {
        "source": "github",
        "repo": "yourorg/vd_workflow"
      }
    }
  },
  "enabledPlugins": {
    "vd_workflow@vd_workflow": true
  }
}
```

### Option 2: Local Clone (For Development)

Clone the repository to your development environment:

```bash
cd ~/Development
git clone git@github.com:yourorg/vd_workflow.git
```

Then add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "vd_workflow": {
      "source": {
        "source": "directory",
        "path": "~/Development/vd_workflow"
      }
    }
  },
  "enabledPlugins": {
    "vd_workflow@vd_workflow": true
  }
}
```

Or use the interactive command:

```bash
/plugin marketplace add ~/Development/vd_workflow
/plugin install vd_workflow@vd_workflow
```

### Option 3: Specific Branch or Tag

Reference a specific version:

```bash
/plugin marketplace add yourorg/vd_workflow#v1.0.0
/plugin marketplace add yourorg/vd_workflow#main
```

## Plugin Cache

When the plugin is updated, Claude Code doesn't automatically pick up changes due to caching. To refresh:

```bash
rm -rf ~/.claude/plugins/cache/
# Then restart Claude Code sessions
```

## Project Setup

After installing, initialize your project:

```bash
/vd_workflow:init
```

This creates:
- `specs/` directory - Where specifications are stored

The plugin includes `shared_docs/PATTERNS.md` which defines patterns for auto-apply decisions.

### Ecosystem Mode (Optional)

For multi-repository environments, `/init` offers ecosystem mode which enables cross-repo research:

```bash
# When prompted during init, choose "Yes" for ecosystem mode
/vd_workflow:init
```

This creates:
- `.claude/skills/{project}_expert.md` - Deep repository knowledge
- `~/.claude/ecosystem-config.json` - Registry of ecosystems

With ecosystem mode, you can use the `cross-repo-researcher` agent to investigate how things work across related repositories.

## Commands

### Feature Workflow (`/vd_workflow:spec`, `/vd_workflow:execute-wf`)

| Command | Description |
|---------|-------------|
| `spec` | Create a new feature specification |
| `spec-simplify` | Apply YAGNI principles to simplify specs |
| `spec-tests` | Generate test specifications |
| `spec-review-design` | Review design patterns and architecture |
| `spec-review-implementation` | Review implementation decisions |
| `implement-phase` | Implement a spec phase using TDD |
| `check-work` | Validate acceptance criteria |
| `bug` | Fix a bug using TDD methodology |

### Utility Commands

| Command | Description |
|---------|-------------|
| `init` | Initialize project with specs/ directory and optional ecosystem mode |
| `setup-project` | Scaffold a new repository with ecosystem integration |
| `fix-tests` | Run tests and fix failures |
| `git-session-cleanup` | Clean up temporary files |

## Agents

| Agent | Purpose |
|-------|---------|
| `spec-writer` | Creates technical specifications |
| `review-executor` | Orchestrates the spec review phase |
| `feature-writer` | Implements feature phases from reviewed specs |
| `feature-architect` | Analyzes architecture and designs solutions |
| `tests-writer` | Generates comprehensive test suites |
| `cross-repo-researcher` | Investigates across repositories in an ecosystem |
| `validation-researcher` | Discovers validation tools and recommends approaches |

## Skills

| Skill | Purpose |
|-------|---------|
| `project-setup-expert` | Repository scaffolding and ecosystem integration |
| `validation-expert` | Validation tool catalog and deployment patterns |

## Usage Example

```bash
# Create a spec for a new feature
/vd_workflow:spec "Add user authentication"

# Run the complete workflow
/vd_workflow:execute-wf specs/user-auth.md

# Scaffold a new project with ecosystem integration
/vd_workflow:setup-project --reference ../existing_project
```

## Key Principles

- **No backward compatibility** - Direct integration, no parallel systems
- **TDD approach** - Write failing tests first
- **Phase-based implementation** - Incremental, buildable phases
- **No code in specs** - Architecture described conceptually only

## License

MIT License
