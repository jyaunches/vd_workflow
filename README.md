# cc_workflow_tools

A Claude Code plugin providing spec-driven development workflow with TDD methodology.

## Overview

This plugin provides generic workflow commands and agents for any software project. It implements a structured approach to feature development:

1. **Spec Creation** - Write technical specifications
2. **Spec Review** - Simplify, generate tests, review design/implementation
3. **Implementation** - TDD-based phase-by-phase development
4. **Validation** - Verify acceptance criteria

## Installation

### Via Marketplace

If you have access to the marketplace that hosts this plugin:

```
/plugin marketplace add <marketplace-path>
/plugin install cc_workflow_tools
```

### Via Local Path

Add to your project's `.claude/settings.json`:

```json
{
  "enabledPlugins": [
    "/path/to/cc_workflow_tools"
  ]
}
```

## Commands

### Feature Workflow (`/cc_workflow_tools:feature_wf:*`)

| Command | Description |
|---------|-------------|
| `spec` | Create a new feature specification |
| `spec-simplify` | Apply YAGNI principles to simplify specs |
| `spec-tests` | Generate test specifications |
| `spec-review-design` | Review design patterns and architecture |
| `spec-review-implementation` | Review implementation decisions |
| `implement-phase` | Implement a spec phase using TDD |
| `check-work` | Validate acceptance criteria |
| `execute-workflow` | Run the complete workflow end-to-end |

### Utility Commands

| Command | Description |
|---------|-------------|
| `add-doc` | Create documentation |
| `capture-need` | Capture a feature need |
| `fix-tests` | Run tests and fix failures |
| `git_session_cleanup` | Clean up temporary files |
| `track-learning` | Capture learnings from development |

## Agents

| Agent | Purpose |
|-------|---------|
| `feature-writer` | Implements feature phases from reviewed specs |
| `feature-architect` | Analyzes architecture and designs solutions |
| `spec-writer` | Creates technical specifications |
| `tests-writer` | Generates comprehensive test suites |
| `review-executor` | Orchestrates the spec review phase |

## Usage Example

```bash
# Create a spec for a new feature
/cc_workflow_tools:feature_wf:spec "Add user authentication"

# Run the complete workflow
/cc_workflow_tools:feature_wf:execute-workflow specs/user-auth.md
```

## License

MIT License
