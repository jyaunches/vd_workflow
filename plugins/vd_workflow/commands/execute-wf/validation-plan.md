---
description: Generate BDD validation plan with Given/When/Then scenarios
argument-hint: <spec_dir>
---

# Validation Plan: $ARGUMENTS

I'll generate a comprehensive BDD-style validation plan for the specified spec directory.

**Internal Path Resolution:**
- Spec file: `<spec_dir>/spec.md`
- Test spec file: `<spec_dir>/tests.md`
- Output: `<spec_dir>/validation.md`

---

## Step 1: Analyze Specification and Test Spec

First, I'll read the spec and test spec to understand:
- Feature phases and acceptance criteria
- Unit test coverage (to avoid duplication)
- Integration points that need E2E validation

```bash
SPEC_DIR="${1%/}"
SPEC_FILE="$SPEC_DIR/spec.md"
TEST_SPEC_FILE="$SPEC_DIR/tests.md"

echo "=== Reading Specification ==="
cat "$SPEC_FILE"
```

```bash
echo "=== Reading Test Specification ==="
cat "$TEST_SPEC_FILE" 2>/dev/null || echo "No test spec found yet"
```

---

## Step 2: Discover Available Validation Tools

I'll check what validation tools are available in this session.

**Checking for MCP servers:**
- `mcp__playwright__*` - Browser automation, UI testing
- `mcp__*_db__*`, `mcp__postgres__*` - Database queries, state verification
- `mcp__github__*` - GitHub operations, PR checks

**Checking project tools:**
```bash
# Check for test frameworks and CLIs
cat package.json 2>/dev/null | grep -E "(playwright|puppeteer|cypress|jest)" || true
grep -E "(pytest|httpx|playwright)" pyproject.toml 2>/dev/null || true
ls .github/workflows/*.yml 2>/dev/null | head -3 || true
which gh && echo "gh CLI available" || true
```

---

## Step 3: Generate BDD Scenarios

For each spec phase, I'll generate BDD scenarios covering:

### Happy Paths
- **Complete user journeys** that exercise the feature end-to-end
- All major success flows

### Sad Paths (Obvious Failures)
- **Invalid input** - What happens with bad data?
- **Auth failures** - What happens without proper permissions?
- **Missing data** - What happens when required data is absent?
- **Edge cases** - Boundary conditions that could fail

### Scenario Structure

Each scenario follows BDD format:

```markdown
### Scenario X.Y: <Descriptive Name> [STATUS: pending]
**Type**: Happy Path | Sad Path

**Given**: <Precondition - system state, user state, data setup>
**When**: <Action - what the user/system does>
**Then**: <Outcome - observable result that proves it works>

**Validation Steps**:
1. **Setup**: <Tool>: <Setup action>
2. **Execute**: <Tool>: <Trigger action>
3. **Verify**: <Tool>: <Check expected state>

**Tools Required**: <List of tools needed>
```

---

## Step 4: Generate Validation Plan File

I'll create `<spec_dir>/validation.md` with this format:

```markdown
# Validation Plan: <Feature Name>

Generated from: <spec_dir>/spec.md
Test Spec: <spec_dir>/tests.md

## Overview
**Feature**: <Brief description>
**Available Tools**: <Playwright MCP, Database MCP, gh CLI, etc.>

## Coverage Summary
- Happy Paths: <count> scenarios
- Sad Paths: <count> scenarios
- Total: <count> scenarios

---

## Phase 1: <Phase Name> - Validation Scenarios

### Scenario 1.1: <Happy Path Name> [STATUS: pending]
**Type**: Happy Path

**Given**: <Precondition>
**When**: <Action>
**Then**: <Expected outcome>

**Validation Steps**:
1. **Setup**: <Tool>: <Action>
2. **Execute**: <Tool>: <Action>
3. **Verify**: <Tool>: <Check>

**Tools Required**: <List>

---

### Scenario 1.2: <Sad Path Name> [STATUS: pending]
**Type**: Sad Path

**Given**: <Precondition>
**When**: <Invalid action>
**Then**: <Error handling expectation>

**Validation Steps**:
1. **Setup**: <Tool>: <Action>
2. **Execute**: <Tool>: <Action>
3. **Verify**: <Tool>: <Check error state>

**Tools Required**: <List>

---

## Phase 2: <Phase Name> - Validation Scenarios

### Scenario 2.1: ...

---

## Summary

| Phase | Happy | Sad | Total | Passed | Failed | Pending |
|-------|-------|-----|-------|--------|--------|---------|
| Phase 1 | X | Y | Z | 0 | 0 | Z |
| Phase 2 | X | Y | Z | 0 | 0 | Z |
| **Total** | **X** | **Y** | **Z** | **0** | **0** | **Z** |
```

---

## Scenario Generation Guidelines

### What Makes a Good Scenario

1. **Specific and Observable**: The outcome must be something we can actually verify with tools
2. **Independent**: Each scenario can run without depending on other scenarios
3. **Complete**: Given/When/Then fully describes the scenario without ambiguity
4. **Tool-Appropriate**: Validation steps use the right tool for the job

### What to Avoid

- **Duplicate unit test coverage**: Don't test what unit tests already cover
- **Implementation details**: Test behavior, not internal implementation
- **Vague outcomes**: "Works correctly" is not verifiable - be specific
- **Impossible scenarios**: Don't generate scenarios we can't actually execute

### Tool Selection

| Validation Need | Tool |
|----------------|------|
| Browser UI interaction | Playwright MCP |
| Database state verification | Database MCP |
| API endpoint testing | curl / httpx |
| GitHub PR/workflow checks | gh CLI |
| File system verification | Bash |
| Running test suites | pytest / jest |

---

## Step 5: Commit Validation Plan

After generating the validation plan:

```bash
git add "$SPEC_DIR/validation.md"
git commit -m "Add validation plan for $(basename $SPEC_DIR)"
```

---

## Output

After completion, report:
- Total scenarios generated
- Happy path count
- Sad path count
- Tools required
- Path to validation.md

**Next Step**: Run `/execute-wf:validation-review <spec_dir>` to review and approve the validation plan before implementation.
