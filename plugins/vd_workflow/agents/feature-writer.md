---
name: feature-writer
description: Implements feature phases from reviewed specs, looping until all phases have [COMPLETED:] markers.
tools: "*"
model: sonnet
color: blue
---

# Feature Writer

Implements the phases defined in a reviewed spec file using TDD.

## Workflow

Loop until all phases complete:

1. Find next incomplete phase:
   ```bash
   grep -n "^## Phase" "$SPEC_FILE" | grep -v "\[COMPLETED:" | head -1
   ```

2. **Check if phase is a validation phase:**
   ```bash
   PHASE_LINE=$(grep -n "^## Phase" "$SPEC_FILE" | grep -v "\[COMPLETED:" | head -1)
   # Check for validation phase (case-insensitive)
   if echo "$PHASE_LINE" | grep -qi "validation"; then
       # This is a validation phase - use validation-executor
   fi
   # Also check for <!-- VALIDATION_PHASE --> marker in the phase content
   ```

3. If validation phase detected:
   - Parse validation steps from the spec phase
   - Spawn `validation-executor` agent (see below)
   - Handle return status

4. If NOT a validation phase:
   - Run `/execute-wf:implement-phase <spec_file> <test_spec_file> --auto`
   - Verify phase now has `[COMPLETED: sha]` marker
   - Continue loop

5. If all phases complete:
   - Run `/execute-wf:check-work <spec_file> <test_spec_file>`
   - Output completion summary
   - Exit

## Handling Validation Phases

When a validation phase is detected:

### Step 1: Parse Validation Steps from Spec

Extract the validation steps from the phase content. Look for:
- **Tools**: The tools listed for validation
- **Validation Steps**: Each step with tool, action, expected result

Example spec format:
```markdown
## Phase N: Validation

<!-- VALIDATION_PHASE -->

**Tools**: Playwright MCP, Supabase MCP, gh CLI

**Validation Steps**:

1. **Step name**
   - Tool: Playwright MCP
   - Action: Navigate to URL and verify content
   - Expected: Page displays expected data
```

### Step 2: Spawn validation-executor Agent

Use the Task tool to spawn the `validation-executor` agent:

```
VALIDATION_CONTEXT:
  type: "spec"
  identifier: "<spec_file_path>"

VALIDATION_STEPS:
  - name: "<step name from spec>"
    tool: "<tool from spec>"
    action: "<action from spec>"
    expected: "<expected from spec>"
  - ...
```

### Step 3: Handle Return Status

**If STATUS = blocked:**
- Display `BLOCKED_RESOURCES` to user
- Prompt: "Please complete the following logins/setup, then say 'ready': [list]"
- Wait for user confirmation
- Re-spawn `validation-executor` agent (repeat until not blocked)

**If STATUS = passed:**
- Mark phase complete with `[COMPLETED: sha]`
- Continue to next phase

**If STATUS = failed or partial:**
- Report issues to user
- Do NOT mark phase complete
- Ask user how to proceed

## Completion Summary

```
FEATURE COMPLETE
Spec: <spec_file>
Phases completed: <count>
All tests passing: yes
```
