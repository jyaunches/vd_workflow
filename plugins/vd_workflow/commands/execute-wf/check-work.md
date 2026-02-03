---
description: Check acceptance criteria, run tests with auto-fixes, and recommend next steps after /implement-phase
argument-hint: <spec_dir>
---

# Check Work: $ARGUMENTS

Analyze implementation against acceptance criteria and assess test suite health.

**Path Resolution:**
- Spec file: `<spec_dir>/spec.md`
- Test spec file: `<spec_dir>/tests.md`

## Workflow

### 1. Read Specifications
- Extract all phases from spec
- Extract acceptance criteria per phase
- Check implementation status markers (`[COMPLETED: sha]`)

### 2. Analyze Implementation
```bash
# Check completed phases
grep -n "\[COMPLETED:" "$SPEC_DIR/spec.md"

# Recent commits
git log --oneline -15 --grep="Phase"
```

### 3. Run Tests with Auto-Fix
```bash
make test 2>&1 | tee test_output.txt
```

For failures, categorize as:
- **Auto-fixable**: Import errors, simple assertions, missing fixtures
- **Complex**: Logic errors, integration failures (use `/bug` command)

### 4. Assess Completion

For each criterion:
1. Code exists to satisfy it?
2. Test validates it?
3. Documented?

### 5. Generate Report

```markdown
# Work Completion Report

## Summary
- **Acceptance Criteria Score**: X/10
- **Test Suite Health**: Passing | Failing
- **Recommendation**: Continue /implement-phase | File bugs | Complete

## Completed
- [List completed criteria]

## Remaining
- [List incomplete criteria]

## Test Results
- Passing: X
- Auto-Fixed: Y
- Still Failing: Z

## Next Steps
1. [If <70%] `/implement-phase <spec_dir>`
2. [If >=70%] `/bug "Fix specific issue"`
3. [If 100%] Ready for validation
```

## Recommendation Logic

| Completion | Test Status | Recommendation |
|------------|-------------|----------------|
| <70% | Any | Continue `/implement-phase` |
| >=70% | Failures | Fix with `/bug` |
| 100% | Passing | Ready for validation |
