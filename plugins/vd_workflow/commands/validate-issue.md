---
description: Validate a GitHub issue or PR with executable validation steps
argument-hint: <issue_or_pr_number>
---

# Validate Issue/PR: $ARGUMENTS

I'll analyze this GitHub issue/PR and execute validation to verify it works correctly.

**CRITICAL**: This command EXECUTES validation using available tools - it does NOT just propose steps.

---

## Step 1: Fetch Issue/PR Details

First, let me get the context from GitHub:

```bash
# Try as PR first (most common), fall back to issue
gh pr view $ARGUMENTS --json title,body,files,commits,state,baseRefName,headRefName 2>/dev/null || \
gh issue view $ARGUMENTS --json title,body,state
```

**Extract:**
- Title and description
- Files changed (for PRs)
- Related commits
- Current state

---

## Step 2: Analyze What Needs Validation

Based on the PR/issue content, identify:

### File Change Analysis

| Pattern | Inferred Validation |
|---------|---------------------|
| `.yml` workflow files | Trigger workflow, check `gh run list` status |
| `rules.py`, `service.py` | Run unit tests, verify categorization behavior |
| `categorization-rules.yaml` | Verify rules match expected transactions |
| Database migrations | Verify migration runs, check schema |
| API endpoints | Hit endpoints with curl/httpx |
| Streamlit pages | Use Playwright to verify UI |
| WhatsApp-related code | Use Playwright to send real WhatsApp message |

### Test Coverage Check

```bash
# Check if unit tests exist for changed files
gh pr view $ARGUMENTS --json files -q '.files[].path' | while read f; do
  base=$(basename "$f" .py)
  test_file="tests/unit/test_${base}.py"
  [ -f "$test_file" ] && echo "Tests exist: $test_file" || echo "No tests: $test_file"
done
```

---

## Step 3: Discover Available Validation Tools

**MCP Servers in Current Session:**

Check for available MCP tools with patterns:
- `mcp__playwright__*` - Browser automation for WhatsApp, web UI
- `mcp__supabase__*` - Database queries, state verification
- `mcp__github__*` - GitHub operations (alternative to gh CLI)

**Always Available:**
- `gh` CLI - GitHub operations, workflow status, PR checks
- `curl` - HTTP endpoint testing
- `pytest` - Run unit tests
- `git` - Verify commits, file changes

**I'll report what tools are available before proceeding.**

### E2E Validation Requirement (CRITICAL)

**If Playwright MCP is available (`mcp__playwright__*` tools exist), E2E validation is REQUIRED for PRs that involve:**
- WhatsApp handler changes
- User-facing workflow changes
- Multi-system integration changes
- Any code that affects user notifications or interactions

Unit tests do NOT substitute for E2E. Run both when tools are available.

---

## Step 4: Design Validation Plan

Based on the analysis, I'll create a validation plan:

```markdown
## Validation Plan for PR #$ARGUMENTS

### Validation Tools Available
- [ ] Playwright MCP: [Yes/No]
- [ ] Supabase MCP: [Yes/No]
- [ ] gh CLI: [Yes]
- [ ] pytest: [Yes]

### Validation Steps

1. **[Step Name]**
   - Tool: [specific tool]
   - Action: [what to do]
   - Expected: [success criteria]

2. **[Step Name]**
   - Tool: [specific tool]
   - Action: [what to do]
   - Expected: [success criteria]
```

---

## Step 5: EXECUTE VALIDATION (via validation-executor)

After designing the validation plan in Step 4, spawn the `validation-executor` agent to execute it.

### Spawn validation-executor Agent

Use the Task tool to spawn the `validation-executor` agent with:

```
VALIDATION_CONTEXT:
  type: "pr"
  identifier: "$ARGUMENTS"

VALIDATION_STEPS:
  - name: "<step name from validation plan>"
    tool: "<tool from validation plan>"
    action: "<action from validation plan>"
    expected: "<expected result from validation plan>"
  - ...
```

Format the validation steps from your Step 4 plan into the VALIDATION_STEPS structure.

### Handle Return Status

The `validation-executor` agent returns:

```
STATUS: passed | failed | partial | blocked
CAN_MARK_COMPLETE: true | false
BLOCKED_RESOURCES: [list, only if blocked]
STEPS_PASSED: [list]
STEPS_FAILED: [list with reasons]
ISSUES: [list]
```

**If STATUS = blocked:**
- Display blocked resources to user
- Ask: "Please complete the following logins/setup, then say 'ready': [list of BLOCKED_RESOURCES]"
- Wait for user to confirm ready
- Re-spawn validation-executor agent
- Repeat until not blocked

**If STATUS = passed | failed | partial:**
- Record the results
- Continue to Step 6 (Post Results)

---

## Step 6: Post Results to PR

After validation completes, post results as a comment:

```bash
gh pr comment $ARGUMENTS --body "$(cat <<'EOF'
## Validation Results

**Status**: [PASSED/FAILED]

### Checks Performed

| Check | Status | Details |
|-------|--------|---------|
| Unit Tests | [result] | [details] |
| [Other Check] | [result] | [details] |

### Issues Found
- [List any issues discovered]

### Recommendation
- [Merge / Needs fixes / etc.]

---
*Validated by Claude Code using `/vd_workflow:validate-issue`*
EOF
)"
```

---

## Step 7: Summary and Recommendation

After all validation completes:

**If all checks passed:**
> PR #$ARGUMENTS is ready to merge. All validation checks passed.

**If some checks failed:**
> PR #$ARGUMENTS has issues that need attention:
> - [List specific failures]
> - [Recommended fixes]

---

## Quick Reference: Common Validation Scenarios

### Scenario: Code Changes with Unit Tests
1. Run `pytest tests/` to verify existing tests pass
2. If tests exist for changed files, verify they cover the changes
3. Check code coverage if available

### Scenario: GitHub Actions Workflow Changes
1. Trigger the workflow manually: `gh workflow run <name>`
2. Watch for completion: `gh run watch`
3. Verify expected outcomes (commits, comments, etc.)

### Scenario: Categorization Rules/Logic Changes
1. Run categorization unit tests
2. Query database for test transactions
3. Verify rules match expected categories

### Scenario: WhatsApp Handler Changes
1. Use Playwright to send test WhatsApp message
2. Wait for GitHub Action to trigger
3. Verify response received in chat
4. Check database for expected state changes

---

**Starting validation for**: $ARGUMENTS
