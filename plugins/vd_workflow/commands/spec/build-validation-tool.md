---
description: Build a validation tool in vd_workflow using recursive spec/execute workflow
argument-hint: <tool_name> "<description>"
---

# Build Validation Tool: $ARGUMENTS

Build a reusable validation tool in the vd_workflow plugin repository.

## Overview

This command creates a validation tool that will be available across all projects using this plugin. It uses the standard spec-driven workflow to design and implement the tool.

**Arguments:**
- `tool_name`: Name for the validation tool (e.g., "health-check-validator")
- `description`: What the tool validates and how

---

## Step 1: Parse Arguments

```bash
TOOL_NAME="$1"
DESCRIPTION="$2"

echo "Building validation tool:"
echo "  Name: $TOOL_NAME"
echo "  Description: $DESCRIPTION"
```

---

## Step 2: Switch to Plugin Directory

The tool will be built in the vd_workflow plugin directory so it's available to all projects:

```bash
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT}"
echo "Building in plugin directory: $PLUGIN_DIR"
cd "$PLUGIN_DIR"
```

---

## Step 3: Create Tool Specification

Create a spec for the validation tool:

```bash
# Generate spec filename with timestamp
SPEC_FILE="specs/$(date +%Y-%m-%d_%H-%M)_${TOOL_NAME}.md"
echo "Creating specification: $SPEC_FILE"
```

The specification will include:

### Tool Design Requirements

**Purpose**: $DESCRIPTION

**Interface Design**:
- CLI command or library function
- Input parameters (what to validate, configuration)
- Output format (success/failure, detailed report)
- Exit codes (0 for success, non-zero for failure)

**Implementation Phases**:
1. Core validation logic
2. Output formatting
3. Error handling
4. Integration with plugin structure

**Acceptance Criteria**:
- Tool can be invoked from any project using the plugin
- Clear success/failure indication
- Useful error messages on failure
- Documentation in README

Run the spec command to create the full specification:

```bash
/vd_workflow:spec "$TOOL_NAME" "$DESCRIPTION"
```

---

## Step 4: Execute Workflow

After the spec is created, implement the tool:

```bash
/vd_workflow:execute-wf "$SPEC_FILE"
```

This will:
1. Review and simplify the spec
2. Generate test specifications
3. Implement using TDD
4. Validate acceptance criteria

---

## Step 5: Update Validation Expert Skill

After successful implementation, update the skill catalog:

```bash
SKILL_FILE="${PLUGIN_DIR}/skills/validation-expert.md"
TODAY=$(date +%Y-%m-%d)

echo "Updating validation-expert skill..."
```

Add entry to the "Built Validation Tools" section:

```markdown
- **$TOOL_NAME**: $DESCRIPTION
  - Location: vd_workflow (available via plugin)
  - Usage: [usage instructions from implementation]
  - Built: $TODAY
  - Spec: $SPEC_FILE
```

---

## Step 6: Commit Skill Update

```bash
git add "$SKILL_FILE"
git commit -m "Update validation-expert skill with new tool: $TOOL_NAME

Added $TOOL_NAME to the Built Validation Tools catalog.

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Step 7: Report Completion

```markdown
## Validation Tool Built Successfully

**Tool**: $TOOL_NAME
**Location**: vd_workflow plugin
**Specification**: $SPEC_FILE

**The tool is now available for use in validation phases.**

To use this tool in future specs:
- The validation-researcher agent will now recommend it
- Reference it in validation phases as: `$TOOL_NAME`

**Next Steps**:
- Return to /design-validation to continue spec creation
- The new tool will be available for the current validation phase
```

---

## Error Handling

**If spec creation fails:**
- Report the error
- Do not proceed to execute-workflow
- Suggest manual spec creation

**If workflow execution fails:**
- Report the error and which phase failed
- Suggest running `/execute-workflow` again or manual intervention
- Do not update the skill file

**If skill update fails:**
- Report the error
- Provide manual update instructions
- The tool is still built and usable

---

## Notes

- All validation tools go into vd_workflow to be reusable across projects
- Tools follow the plugin's command/agent patterns
- The validation-expert skill is the single source of truth for available tools
- Built tools are automatically available to the validation-researcher agent

---

Ready to build validation tool: **$ARGUMENTS**
