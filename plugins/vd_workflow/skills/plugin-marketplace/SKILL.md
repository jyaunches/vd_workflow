---
name: plugin-marketplace
description: Complete reference for Claude Code plugin marketplace system. Use when creating plugins, marketplaces, troubleshooting plugin issues, or understanding update mechanisms.
---

# Claude Code Plugin Marketplace - Complete Reference

## CRITICAL: After Editing This Plugin

**Every time you modify files in this plugin (commands, agents, skills, etc.):**

1. **Commit and PUSH to GitHub:**
   ```bash
   git add -A && git commit -m "description" && git push origin main
   ```

2. **Tell the user to update the plugin:**
   ```
   Plugin changes have been pushed. To apply them:
   1. Run: /plugin marketplace update
   2. Restart Claude Code
   ```

Without pushing, changes only exist locally. Without updating, users won't see the changes.

---

## Overview

The Claude Code plugin system extends Claude Code with custom slash commands, agents, hooks, Skills, and MCP servers. Plugins are distributed through marketplaces.

**Core Concepts:**
- **Plugins**: Collections of commands, agents, hooks, Skills, MCP/LSP servers
- **Plugin Manifest**: `plugin.json` metadata file describing the plugin
- **Marketplace**: `marketplace.json` file listing plugins and their sources

---

## Directory Structure

### Marketplace Layout
```
repository-root/
├── .claude-plugin/
│   └── marketplace.json    <- Marketplace definition
└── plugins/
    └── my-plugin/          <- Individual plugins
        ├── .claude-plugin/
        │   └── plugin.json
        ├── commands/
        ├── agents/
        └── skills/
```

### Plugin Layout
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json         <- ONLY manifest here
├── commands/               <- At root level (NOT inside .claude-plugin/)
│   └── my-command.md
├── agents/                 <- At root level
│   └── my-agent.md
├── skills/                 <- At root level
│   └── my-skill/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── .mcp.json               <- MCP server config
└── .lsp.json               <- LSP server config
```

**Critical**: `commands/`, `agents/`, `skills/`, `hooks/` must be at plugin ROOT, not inside `.claude-plugin/`

---

## Marketplace Schema (marketplace.json)

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name"
  },
  "description": "Marketplace description",
  "plugins": [
    {
      "name": "plugin-id",
      "source": "./plugins/plugin-dir",
      "description": "Plugin description"
    }
  ]
}
```

### Required Fields
| Field | Purpose |
|-------|---------|
| `name` | Marketplace identifier (kebab-case) |
| `owner.name` | Maintainer name |
| `plugins` | Array of plugin entries |

### Plugin Entry Required Fields
| Field | Purpose |
|-------|---------|
| `name` | Plugin identifier (kebab-case) |
| `source` | Where to find plugin (must start with `./` for relative paths) |

---

## Plugin Manifest Schema (plugin.json)

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief description",
  "author": {
    "name": "Author Name"
  }
}
```

Only `name` is required. All other fields are optional.

---

## Plugin Sources

### Relative Path (Same Repository)
```json
{
  "source": "./plugins/my-plugin"
}
```
**Must start with `./`**

### GitHub Repository
```json
{
  "source": {
    "source": "github",
    "repo": "owner/repo",
    "ref": "branch-or-tag",
    "path": "subdirectory"
  }
}
```

### Git URL (Any Host)
```json
{
  "source": {
    "source": "git",
    "url": "https://gitlab.com/team/plugins.git",
    "ref": "v2.0"
  }
}
```

### Directory (Local)
```json
{
  "source": {
    "source": "directory",
    "path": "~/Development/my-plugins"
  }
}
```

---

## Installation & Configuration

### settings.json Format

```json
{
  "extraKnownMarketplaces": {
    "marketplace-name": {
      "source": {
        "source": "github",
        "repo": "owner/repo"
      }
    }
  },
  "enabledPlugins": {
    "plugin-name@marketplace-name": true
  }
}
```

### Scopes

| Scope | Location | Shared |
|-------|----------|--------|
| User | `~/.claude/settings.json` | No |
| Project | `.claude/settings.json` | Yes (git) |
| Local | `.claude/settings.local.json` | No (gitignored) |
| Managed | System directory | Enterprise |

---

## Updates & Versioning

### Version Format (SemVer)
```
MAJOR.MINOR.PATCH  (e.g., "2.1.0")

MAJOR: Breaking changes
MINOR: New features (backward-compatible)
PATCH: Bug fixes (backward-compatible)
```

### How Updates Work

**Pull-based model** - no automatic notifications:

1. Plugin owner updates code and bumps version in `plugin.json`
2. Plugin owner pushes to GitHub
3. Users must manually update

### Update Commands

```bash
# Refresh marketplace metadata
/plugin marketplace update

# Update specific plugin
claude plugin update plugin-name@marketplace-name

# Force fresh pull (nuclear option)
rm -rf ~/.claude/plugins/cache/
# Then restart Claude Code
```

### Cache Locations

| Path | Contents |
|------|----------|
| `~/.claude/plugins/cache/` | Installed plugin files |
| `~/.claude/plugins/known_marketplaces.json` | Marketplace metadata |
| `~/.claude/plugins/installed_plugins.json` | Installation records |

### Forcing Client Updates

To ensure clients receive updates:

1. **Bump version** in `plugin.json`:
   ```json
   {
     "version": "1.1.0"
   }
   ```

2. **Push to GitHub**

3. **Communicate to users** (no auto-notification):
   - Update README with changelog
   - Tell users to run: `/plugin marketplace update`
   - Or clear cache: `rm -rf ~/.claude/plugins/cache/`

---

## CLI Commands

### Plugin Management
```bash
# Install plugin
claude plugin install plugin@marketplace --scope project

# Disable plugin
claude plugin disable plugin@marketplace

# Enable plugin
claude plugin enable plugin@marketplace

# Uninstall plugin
claude plugin uninstall plugin@marketplace
```

### Marketplace Management
```bash
# Add marketplace (GitHub)
/plugin marketplace add owner/repo

# Add marketplace (local)
/plugin marketplace add ./path/to/marketplace

# Update marketplace
/plugin marketplace update marketplace-name

# Remove marketplace
/plugin marketplace remove marketplace-name

# Validate
claude plugin validate .
```

### Development
```bash
# Test plugin locally
claude --plugin-dir ./my-plugin
```

---

## Plugin Components

### Commands
**Location**: `commands/` at plugin root
**Namespacing**: Auto-prefixed with plugin name (`hello.md` -> `/plugin:hello`)

```markdown
---
description: Command description
---

# Command Title

Prompt instructions for Claude...
```

### Agents
**Location**: `agents/` at plugin root

```markdown
---
description: Agent description
capabilities: ["capability1", "capability2"]
---

# Agent Title

Agent instructions...
```

### Skills
**Location**: `skills/skill-name/SKILL.md`

```markdown
---
name: skill-name
description: When to use this skill
---

Skill content and instructions...
```

### Hooks
**Location**: `hooks/hooks.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/hook.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook Events**: PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, UserPromptSubmit, Notification, Stop, SubagentStart, SubagentStop, SessionStart, SessionEnd, PreCompact

### MCP Servers
**Location**: `.mcp.json` at plugin root

```json
{
  "mcpServers": {
    "server-name": {
      "command": "${CLAUDE_PLUGIN_ROOT}/server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  }
}
```

---

## Troubleshooting

### Marketplace Not Loading
- Verify `.claude-plugin/marketplace.json` exists
- Check JSON syntax: `claude plugin validate .`
- For private repos, ensure access permissions

### Commands Not Appearing
- Check `commands/` is at plugin ROOT (not inside .claude-plugin/)
- Verify Markdown syntax and YAML frontmatter
- Check `/plugin` Errors tab
- Restart Claude Code

### Plugin Installation Fails
- Source paths must start with `./` for relative
- GitHub repos must be public (or user has access)
- Validate with `claude plugin validate .`

### Updates Not Propagating
1. Clear cache: `rm -rf ~/.claude/plugins/cache/`
2. Clear metadata: `rm ~/.claude/plugins/known_marketplaces.json`
3. Restart Claude Code
4. Re-add marketplace: `/plugin marketplace add owner/repo`

### Nuclear Cleanup (Complete Reset)

When a plugin is completely broken and nothing else works, use the nuclear cleanup script:

```bash
# From this plugin's skill directory, or copy the script
./nuclear-cleanup.sh <plugin_name> <marketplace_name> [github_repo]

# Example for vd_workflow:
./nuclear-cleanup.sh vd_workflow vd_workflow jyaunches/vd_workflow
```

This script removes ALL traces of a plugin from:
- `~/.claude/plugins/cache/`
- `~/.claude/plugins/marketplaces/`
- `~/.claude/settings.json`
- `~/.claude/plugins/known_marketplaces.json`
- `~/.claude/plugins/installed_plugins.json`

After running, restart Claude Code and re-add the marketplace fresh.

**Manual Nuclear Cleanup** (if script unavailable):
```bash
PLUGIN="vd_workflow"
MARKETPLACE="vd_workflow"

# Remove cache and marketplace dirs
rm -rf ~/.claude/plugins/cache/$MARKETPLACE
rm -rf ~/.claude/plugins/marketplaces/$MARKETPLACE
rm -rf ~/.claude/plugins/marketplaces/github.com-*$MARKETPLACE*

# Clean JSON files (requires jq)
cat ~/.claude/settings.json | jq "del(.enabledPlugins[\"${PLUGIN}@${MARKETPLACE}\"]) | del(.extraKnownMarketplaces[\"${MARKETPLACE}\"])" > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
cat ~/.claude/plugins/known_marketplaces.json | jq "del(.[\"${MARKETPLACE}\"])" > /tmp/k.json && mv /tmp/k.json ~/.claude/plugins/known_marketplaces.json
cat ~/.claude/plugins/installed_plugins.json | jq "del(.plugins[\"${PLUGIN}@${MARKETPLACE}\"])" > /tmp/i.json && mv /tmp/i.json ~/.claude/plugins/installed_plugins.json

# Then restart Claude Code and re-add:
# /plugin marketplace add jyaunches/vd_workflow
```

### Common JSON Errors
- Source path must start with `./` (not `.` or bare path)
- Missing commas between properties
- Extra comma after last property

---

## Quick Checklist

### Creating a Plugin
- [ ] Create `.claude-plugin/plugin.json` with `name`
- [ ] Add `commands/` at root with `.md` files
- [ ] Add `agents/` at root (optional)
- [ ] Add `skills/` at root (optional)
- [ ] Test with `claude --plugin-dir ./my-plugin`

### Creating a Marketplace
- [ ] Create `.claude-plugin/marketplace.json`
- [ ] Add `name`, `owner`, `plugins` array
- [ ] Plugin sources start with `./`
- [ ] Validate: `claude plugin validate .`
- [ ] Push to GitHub

### Distributing Updates
- [ ] Bump version in `plugin.json`
- [ ] **PUSH to GitHub** (changes don't exist remotely until pushed!)
- [ ] Tell user: "Run `/plugin marketplace update` then restart Claude Code"

**IMPORTANT**: If you edit this plugin and don't push, the changes only exist locally.
Users (including yourself in new sessions) won't see updates until you push AND they update.
