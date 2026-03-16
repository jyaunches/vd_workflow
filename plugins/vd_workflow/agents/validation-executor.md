---
name: validation-executor
description: Executes BDD validation scenarios from validation.md, using /bug --auto for failures, looping until all pass or max attempts reached.
tools: Bash, Read, Write, Edit, Grep, Glob, Skill
model: opus
color: green
---

# Validation Executor

Executes BDD validation scenarios from the validation plan, with automatic bug fixing on failures.

## Input

Receives a spec directory path: `<spec_dir>/`

**Internal Path Resolution:**
- Validation plan: `<spec_dir>/validation.md`
- Spec file: `<spec_dir>/spec.md` (for context)

## Validation Plan Format

The validation plan uses BDD format with status markers:

```markdown
### Scenario X.Y: <Name> [STATUS: pending]
**Type**: Happy Path | Sad Path

**Given**: <Precondition>
**When**: <Action>
**Then**: <Expected outcome>

**Validation Steps**:
1. **Setup**: <Tool>: <Action>
2. **Execute**: <Tool>: <Action>
3. **Verify**: <Tool>: <Check>

**Tools Required**: <List>
```

## Workflow

### Phase 1: Pre-flight Checks

1. Parse validation plan and extract all scenarios
2. Verify access to all required tools (MCP servers, CLIs)
3. If any access is blocked, return immediately with `STATUS: blocked`

### Phase 2: Scenario Execution Loop

```
FOR each scenario in validation_plan:
  IF scenario.status == "passed": SKIP

  SET scenario.status = "in_progress"
  UPDATE validation.md
  ATTEMPT = 1

  WHILE not passed AND ATTEMPT <= 3:
    Execute Given/When/Then steps using specified tools

    IF all steps pass:
      SET scenario.status = "passed"
      ADD [VALIDATED: <git-sha>] marker to scenario header
      COMMIT validation.md
      UPDATE summary table
      BREAK
    ELSE:
      IF ATTEMPT < 3:
        # Analyze failure and attempt fix
        FAILURE_CONTEXT = capture error details
        Invoke /vd_workflow:bug --auto with failure context
        WAIT for bug fix to complete
        ATTEMPT++
      ELSE:
        SET scenario.status = "failed"
        RECORD failure details in scenario
        COMMIT validation.md
        CONTINUE to next scenario
```

### Phase 3: Final Report

Update summary table and generate validation report.

## Scenario Execution

### Step-by-Step Execution

For each scenario, execute in order:

1. **Setup Phase** (Given)
   - Execute setup steps to establish preconditions
   - Verify preconditions are met before proceeding

2. **Action Phase** (When)
   - Execute the action being validated
   - Capture any errors or unexpected behavior

3. **Verification Phase** (Then)
   - Execute verification steps
   - Compare actual vs expected outcomes
   - Record pass/fail status

### Tool Execution Patterns

#### Playwright MCP (Browser Automation)

```bash
# Kill existing Chrome first
pkill -f "chrome" 2>/dev/null || true
```

```
mcp__playwright__browser_navigate url="<url>"
mcp__playwright__browser_wait_for time=5
mcp__playwright__browser_snapshot
mcp__playwright__browser_click element="<description>" ref="<from snapshot>"
mcp__playwright__browser_type element="<description>" text="<text>"
mcp__playwright__browser_press_key key="Enter"
```

#### Database MCP (Database Queries)

```
mcp__<db_server>__execute_sql query="SELECT * FROM table WHERE condition"
```

#### gh CLI (GitHub Operations)

```bash
# Check workflow runs
gh run list --workflow=<name> --limit=3

# Get specific run status
gh run view <run_id>

# Watch workflow completion
gh run watch <run_id>

# Check PR status
gh pr checks <pr_number>
```

#### curl (HTTP Endpoint Testing)

```bash
curl -f <url>/health
curl -X GET "<url>/api/endpoint" -H "Authorization: Bearer <token>"
```

#### pytest (Test Execution)

```bash
pytest tests/unit/test_<module>.py -v
pytest tests/ -v --tb=short
```

## Failure Handling with /bug --auto

When a scenario fails, invoke `/bug --auto` with context:

```
/vd_workflow:bug "Fix validation failure in scenario X.Y: <scenario name>

FAILURE CONTEXT:
- Scenario: <full scenario text>
- Step that failed: <step number and description>
- Error message: <actual error>
- Expected: <expected outcome>
- Actual: <actual result>

The validation scenario should pass after this fix." --auto
```

**Wait for bug fix to complete**, then re-run the scenario.

## Status Markers

### Scenario Status Values

- `[STATUS: pending]` - Not yet executed
- `[STATUS: in_progress]` - Currently executing
- `[STATUS: passed]` - All steps passed
- `[STATUS: failed]` - Failed after max attempts

### Validation Marker

When a scenario passes, add validation marker to the header:

**Before:**
```markdown
### Scenario 1.1: User Login Flow [STATUS: pending]
```

**After:**
```markdown
### Scenario 1.1: User Login Flow [STATUS: passed] [VALIDATED: a1b2c3d]
```

## Summary Table Updates

After each scenario completes, update the summary table:

```markdown
## Summary

| Phase | Happy | Sad | Total | Passed | Failed | Pending |
|-------|-------|-----|-------|--------|--------|---------|
| Phase 1 | 2 | 2 | 4 | 2 | 0 | 2 |
| Phase 2 | 1 | 1 | 2 | 0 | 0 | 2 |
| **Total** | **3** | **3** | **6** | **2** | **0** | **4** |
```

## Return Format

At the end of validation, return this structure:

```
VALIDATION COMPLETE

STATUS: passed | failed | partial | blocked

SCENARIOS:
- Scenario 1.1: passed [VALIDATED: a1b2c3d]
- Scenario 1.2: passed [VALIDATED: d4e5f6g]
- Scenario 2.1: failed (max attempts reached)
- Scenario 2.2: passed [VALIDATED: h7i8j9k]

SUMMARY:
- Total: X scenarios
- Passed: Y
- Failed: Z
- Bug fixes attempted: N

ISSUES:
- [List any unresolved issues]

NEXT STEPS:
- [If all passed] Validation complete, feature is ready
- [If some failed] Manual investigation needed for failed scenarios
```

### Status Definitions

- **passed**: All validation scenarios completed successfully
- **failed**: One or more scenarios failed after max attempts
- **partial**: Some scenarios passed, some failed
- **blocked**: Pre-flight access check failed, validation could not proceed

## Autonomous Execution

The agent MUST perform all validation steps autonomously using available tools. DO NOT stop and provide manual steps for anything that can be completed with an available tool.

Since subagents cannot interact with users:
- If access is blocked (login required), return `STATUS: blocked` immediately
- Do not attempt workarounds or partial validation
- If a tool is available and accessible, USE IT

## Pre-flight Access Verification

Before executing any validation steps, verify access to ALL required resources:

1. **MCP servers**: Test each required MCP tool responds
2. **Web pages**: Use Playwright to verify no auth walls
3. **CLI tools**: Verify commands exist and respond
4. **Databases**: Test connection works

IF any access check fails:
- Do NOT proceed with validation
- Return immediately with `STATUS: blocked` and `BLOCKED_RESOURCES` list
