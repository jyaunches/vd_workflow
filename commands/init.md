---
description: Initialize project with specs/ directory and optional ecosystem mode
---

# Initialize Project for Workflow Tools

Set up this project with the starter files needed for the cc_workflow_tools workflow.

## Step 1: Check What's Missing

First, check which files already exist:

```bash
echo "=== Checking project setup ==="
[ -d "specs" ] && echo "specs/: EXISTS" || echo "specs/: MISSING"
[ -d ".claude/skills" ] && echo ".claude/skills/: EXISTS (ecosystem mode)" || echo ".claude/skills/: NOT SET UP"
```

## Step 2: Create specs Directory

If the `specs/` directory doesn't exist, create it:

```bash
mkdir -p specs
```

This is where feature specifications will be stored when using `/spec` command.

## Step 3: Ecosystem Mode (Optional)

**Ask the user:**

Is this repository part of a multi-repo ecosystem where you need to share context across services?

Ecosystem mode enables:
- Expert skill file for this repository (`.claude/skills/{project}_expert.md`)
- Cross-repo research using the `cross-repo-researcher` agent
- Shared context across related repositories

### If YES to ecosystem mode:

#### 3.1: Check for existing ecosystem config

```bash
if [ -f "$HOME/.claude/ecosystem-config.json" ]; then
    echo "=== Existing Ecosystems ==="
    cat "$HOME/.claude/ecosystem-config.json"
else
    echo "No existing ecosystem config found"
fi
```

#### 3.2: Ask which ecosystem this belongs to

**If ecosystems exist:**
- Show list of existing ecosystems
- Option to select one OR add new

**If no ecosystems OR adding new:**
- Ask for ecosystem name (e.g., "trading", "client_a", "personal")
- Ask for base path where ecosystem repos live (e.g., "~/Development/trading/")

#### 3.3: Update ecosystem-config.json

Create or update `~/.claude/ecosystem-config.json`:

```json
{
  "ecosystems": [
    {
      "name": "ecosystem_name",
      "base_path": "~/Development/ecosystem_path/"
    }
  ]
}
```

#### 3.4: Create skills directory and expert skill

```bash
mkdir -p .claude/skills
```

Create `.claude/skills/{project}_expert.md` with starter template:

```markdown
# {Project} Expert Skill

You are an expert on the {project_name} system. You have deep knowledge of how it works, why design decisions were made, and how to debug or extend it.

## Core Expertise

You are an expert in:

1. **[Domain Area 1]**
   - [Key knowledge points]

2. **[Domain Area 2]**
   - [Key knowledge points]

## Architecture Overview

[Describe the high-level architecture]

## Key Patterns

[Document important patterns used in this codebase]

## When to Invoke This Skill

Invoke this skill when:
- Working on features that touch [specific areas]
- Debugging issues related to [specific functionality]
- Understanding how [specific component] works

---

**Remember:** This skill provides deep context. Update it when major architectural changes occur.
```

### If NO to ecosystem mode:

Skip skills setup. The project will use standard workflow without cross-repo features.

## Summary

After running this command, you should have:

**Basic setup (always):**
- `specs/` directory - Where feature specifications will be stored

**Ecosystem mode (if enabled):**
- `.claude/skills/{project}_expert.md` - Expert knowledge for this repo
- `~/.claude/ecosystem-config.json` - Registry of your ecosystems

The workflow commands (`/cc_workflow_tools:feature_wf:execute-workflow`, etc.) use the plugin's `shared_docs/PATTERNS.md` to guide auto-apply decisions.
