---
description: Check acceptance criteria, run tests with auto-fixes, and recommend next steps after /implement-phase
argument-hint: <spec_file_path> <test_spec_file_path>
---

# Check Work: $ARGUMENTS

I'll analyze the implementation against acceptance criteria to determine if work is complete and assess integration test coverage.

## Command Purpose

This command helps you determine:
- ✅ Which acceptance criteria have been met
- 🧪 Current test suite health (runs `make test` and auto-fixes simple issues)
- ⚠️ What work remains incomplete (both criteria and test failures)
- 🎯 Whether to continue with `/implement-phase` or use `/bug` commands
- 📊 How well integration tests cover the new functionality
- 📋 Specific recommendations for next steps with exact commands

---

## Phase 1: Implementation Analysis

### Step 1.1: Read Specifications

First, I'll read both specification files to understand the requirements:

```bash
echo "=== Reading Specification Files ==="
echo "Main Spec: $1"
echo "Test Spec: $2"
```

I'll extract:
- All phases defined in the spec
- Acceptance criteria for each phase
- Test requirements from the test spec
- Implementation status markers

### Step 1.2: Analyze Git History

```bash
echo "\n=== Analyzing Implementation Status ==="

# Check for completed phase markers
grep -n "Phase.*:" "$1" | head -20

echo "\n=== Completed Phases ==="
grep -n "\[COMPLETED:" "$1" || echo "No phases marked as completed"

echo "\n=== Recent Implementation Commits ==="
git log --oneline -15 --grep="Phase" --grep="implement" -i
```

### Step 1.3: Examine Code Changes

```bash
echo "\n=== Code Changes Analysis ==="

# Get the commit range for implementation
first_commit=$(git log --oneline -50 | grep -i "phase" | tail -1 | cut -d' ' -f1)
if [ -n "$first_commit" ]; then
    echo "Changes since start of implementation:"
    git diff "${first_commit}^..HEAD" --stat

    echo "\n=== Files Modified ==="
    git diff "${first_commit}^..HEAD" --name-only | grep -E "\.(py|js|ts|go)" | head -20
fi
```

### Step 1.4: Check Test Coverage

```bash
echo "\n=== Test Files Modified ==="
git diff "${first_commit}^..HEAD" --name-only | grep -E "test.*\.(py|js|ts|go)" | head -20

echo "\n=== New Tests Added ==="
git diff "${first_commit}^..HEAD" --name-only | grep -E "test.*\.(py|js|ts|go)" | xargs -I {} sh -c 'echo "{}:"; git diff "${first_commit}^..HEAD" -- {} | grep "^+def test_\|^+it(\|^+describe(\|^+test(" | head -5'
```

---

## Phase 2: Acceptance Criteria Assessment

### Step 2.1: Map Acceptance Criteria

I'll create a comprehensive checklist of all acceptance criteria from the specifications:

**Acceptance Criteria Checklist:**
```markdown
## Phase 1: [Phase Name]
- [ ] Criterion 1.1: [Description]
- [ ] Criterion 1.2: [Description]

## Phase 2: [Phase Name]
- [ ] Criterion 2.1: [Description]
- [ ] Criterion 2.2: [Description]

[Continue for all phases...]
```

### Step 2.2: Verify Implementation

For each criterion, I'll check:
1. **Code Implementation** - Does the code exist to satisfy this?
2. **Test Coverage** - Is there a test validating this criterion?
3. **Documentation** - Is the feature documented?

**Verification Method:**
- Review git diff for relevant code changes
- Search for test cases covering the criterion
- Check for comments/docs mentioning the feature

### Step 2.3: Calculate Completion Score

```markdown
## Completion Metrics

**Overall Progress:**
- Total Acceptance Criteria: [X]
- Fully Completed: [Y] ([Y/X * 100]%)
- Partially Completed: [Z]
- Not Started: [W]

**Completion Score: [Y/X * 10]/10**

**By Phase:**
- Phase 1: [X/Y] criteria met ([percentage]%)
- Phase 2: [X/Y] criteria met ([percentage]%)
- Phase 3: [X/Y] criteria met ([percentage]%)
```

---

## Phase 3: Integration Test Coverage Analysis

### Step 3.1: Identify Existing Integration Tests

```bash
echo "\n=== Existing Integration Tests ==="

# Find integration test files
find tests -type f -name "*integration*.py" -o -name "*e2e*.py" -o -path "*/integration/*" 2>/dev/null

# Check for CLI integration tests
find tests -type f -name "*cli*.py" | xargs grep -l "def test_" 2>/dev/null

# Check for end-to-end workflow tests
grep -r "end.to.end\|e2e\|integration\|workflow" tests/ --include="*.py" | grep "def test" | head -10
```

### Step 3.2: Assess Coverage of New Features

I'll evaluate how well the new functionality is covered:

```markdown
## Integration Test Coverage Assessment

**Coverage Rating: [X]/10**

### Well-Covered Areas:
- ✅ [Feature A]: Covered by `test_integration_foo.py::test_feature_a_workflow`
- ✅ [Feature B]: Covered by `test_cli_integration.py::test_command_x`

### Partially Covered:
- ⚠️ [Feature C]: Basic happy path tested, missing error cases
- ⚠️ [Feature D]: Unit tests exist, but no integration test

### Coverage Gaps:
- ❌ [Feature E]: No integration test for cross-component interaction
- ❌ [Feature F]: Missing end-to-end validation
```

### Step 3.3: Recommend Integration Tests

Based on gaps identified, I'll recommend specific integration tests:

```markdown
## Recommended Integration Test

### Priority: HIGH
**Test Name:** `test_[feature]_complete_workflow`

**Purpose:**
Validate the complete [feature name] workflow including error recovery and edge cases.

**Coverage Value:**
- Tests interaction between [Component A] and [Component B]
- Validates data persistence across operations
- Ensures proper error handling and recovery
- Verifies compatibility with existing features

**Test Structure:**
```python
def test_[feature]_complete_workflow(tmp_path, mock_api):
    """
    Integration test validating:
    1. Initial setup and configuration
    2. Normal operation flow
    3. Error recovery mechanisms
    4. State persistence
    5. Cleanup operations
    """
    # Setup test environment
    config = create_test_config(tmp_path)

    # Test normal workflow
    result = execute_feature_workflow(config)
    assert result.success

    # Test error recovery
    with simulate_failure():
        result = execute_feature_workflow(config)
        assert result.recovered

    # Verify state persistence
    restored = load_state(config.state_file)
    assert restored.is_valid()

    # Test interaction with existing features
    legacy_result = execute_legacy_workflow(config)
    assert legacy_result.compatible
```

**Why This Test Adds Value:**
- Generic enough to catch future regressions
- Tests critical user workflows
- Validates system resilience
- Can be extended for similar features
```

---

## Phase 4: Test Execution & Auto-Fix

### Step 4.1: Run Test Suite

I'll run the test suite to identify any failures:

```bash
echo "\n=== Running Test Suite ==="
make test 2>&1 | tee test_output.txt

# Capture exit code
test_exit_code=$?

if [ $test_exit_code -eq 0 ]; then
    echo "\n✅ All tests passing!"
else
    echo "\n❌ Test failures detected. Analyzing..."
fi
```

### Step 4.2: Analyze Test Failures

I'll categorize test failures into:
1. **Simple/Obvious Fixes** - Can be auto-fixed
2. **Complex Issues** - Need manual intervention

```bash
echo "\n=== Analyzing Test Failures ==="

# Extract failure information
grep -E "FAILED|ERROR|AssertionError|TypeError|AttributeError" test_output.txt | head -20

# Get list of failed test files
grep -E "FAILED.*::" test_output.txt | cut -d':' -f1 | sort -u
```

### Step 4.3: Auto-Fix Simple Issues

I'll attempt to fix obvious issues automatically:

```markdown
## Auto-Fix Candidates

### Category 1: Import Errors
**Pattern**: `ImportError: cannot import name 'X' from 'Y'`
**Auto-Fix**: Update import statements

### Category 2: Simple Assertion Failures
**Pattern**: `AssertionError: assert X == Y`
**Auto-Fix**: Update test expectations if implementation is correct

### Category 3: Missing Mock/Fixture
**Pattern**: `fixture 'X' not found`
**Auto-Fix**: Add missing fixture or mock

### Category 4: Type Errors
**Pattern**: `TypeError: X() takes Y positional arguments`
**Auto-Fix**: Update function calls with correct arguments
```

**Auto-Fix Process:**
1. Identify the error pattern
2. Locate the failing test file
3. Apply the fix
4. Re-run just that test to verify
5. If successful, continue; if not, add to complex issues list

### Step 4.4: Summarize Complex Issues

For issues that can't be auto-fixed:

```markdown
## Complex Test Failures Summary

### Failure 1: [Test Name]
**File**: `tests/test_module.py::TestClass::test_method`
**Error Type**: [e.g., Logic Error, Integration Failure]
**Error Message**:
```
[Full error message]
```

**Analysis**:
- Root cause: [What's likely causing this]
- Impact: [What functionality is affected]
- Dependencies: [Related code that might be involved]

**Recommended Fix**:
```python
# Suggested code change or approach
```

**Complexity**: [Low/Medium/High]
**Estimated Time**: [15 min / 1 hour / 2+ hours]

---

### Failure 2: [Test Name]
[Similar structure...]
```

### Step 4.5: Test Fix Verification

After auto-fixes are applied:

```bash
echo "\n=== Re-running Tests After Auto-Fixes ==="

# List of files that were auto-fixed
for fixed_file in $auto_fixed_files; do
    echo "Testing $fixed_file..."
    make test-single TEST="$fixed_file"
done

# Run full test suite again
echo "\n=== Final Test Suite Run ==="
make test

final_exit_code=$?
```

### Step 4.6: Generate Test Report

```markdown
## Test Execution Report

### 📊 Test Statistics
- **Total Tests**: [X]
- **Initial Pass Rate**: [Y/X] ([percentage]%)
- **After Auto-Fix**: [Z/X] ([percentage]%)

### ✅ Auto-Fixed Issues ([count])
1. ✅ Fixed import error in `test_module.py`
2. ✅ Updated assertion in `test_feature.py`
3. ✅ Added missing fixture in `test_integration.py`

### ❌ Remaining Complex Issues ([count])

#### High Priority (Blocking)
1. **Test**: `test_critical_workflow`
   - **Issue**: Integration failure with API
   - **Fix Strategy**: Need to update API client mock
   - **Command**: `/bug "Fix API integration test failure in test_critical_workflow"`

#### Medium Priority (Important)
2. **Test**: `test_data_validation`
   - **Issue**: Schema mismatch in validation logic
   - **Fix Strategy**: Update schema or validation rules
   - **Command**: `/bug "Resolve schema validation mismatch in test_data_validation"`

#### Low Priority (Nice to Fix)
3. **Test**: `test_edge_case_handling`
   - **Issue**: Uncovered edge case in error handling
   - **Fix Strategy**: Add proper error handling
   - **Command**: `/bug "Add edge case handling for scenario X"`

### 🎯 Recommended Actions

Based on test results:

**If all tests pass after auto-fixes:**
- ✅ Tests are healthy
- Proceed with remaining acceptance criteria

**If high-priority failures remain:**
- 🔴 Address blocking issues first
- Use provided `/bug` commands
- Re-run `/check-work` after fixes

**If only low-priority failures:**
- 🟡 Can proceed with caution
- File bugs for tracking
- Fix in next iteration
```

---

## Phase 5: Final Recommendations

### Step 5.1: Determine Next Steps

Based on acceptance criteria, test results, and coverage analysis, I'll recommend one of three paths:

```markdown
## 🎯 Recommended Next Steps

### Option A: Continue with /implement-phase ✅
**When to Choose:**
- Completion score < 7/10
- Major functionality missing (>30% of criteria)
- Core features not implemented

**Specific Command:**
```bash
/execute-wf:implement-phase specs/[spec-file] specs/[test-spec-file]
```

**Focus Areas:**
1. [Missing Phase X]: Critical for feature completion
2. [Missing Phase Y]: Required acceptance criteria
3. [Missing tests]: Core functionality validation

---

### Option B: File Targeted Bugs 🐛
**When to Choose:**
- Completion score >= 7/10
- Minor gaps (<30% of criteria)
- Core features work but need polish

**Suggested Bug Commands:**
```bash
# Bug 1: High priority - blocks user workflow
/bug "Fix [specific issue]: [detailed description of problem and expected behavior]"

# Bug 2: Medium priority - edge case handling
/bug "Add validation for [scenario]: [what should happen vs what happens now]"

# Bug 3: Low priority - polish/UX improvement
/bug "Improve error message when [condition]: [current vs desired message]"
```

---

### Option C: Work is Complete ✨
**When to Choose:**
- Completion score = 10/10
- All acceptance criteria met
- Comprehensive test coverage

**Next Actions:**
1. Ready for deployment
```

### Step 5.2: Priority Matrix

```markdown
## Priority Matrix for Remaining Work

### 🔴 Critical (Must Fix)
- [ ] [Issue]: Blocks core functionality
- [ ] [Issue]: Security/data integrity concern

### 🟡 Important (Should Fix)
- [ ] [Issue]: Affects user experience
- [ ] [Issue]: Missing test coverage

### 🟢 Nice to Have (Could Fix)
- [ ] [Issue]: Code cleanup/refactoring
- [ ] [Issue]: Performance optimization
```

### Step 5.3: Risk Assessment

```markdown
## Risk Assessment

### Technical Risks:
- **[Risk 1]**: [Description and mitigation]
- **[Risk 2]**: [Description and mitigation]

### Test Coverage Risks:
- **Integration Gap**: [What could break]
- **Mitigation**: Add test for [specific scenario]

### Deployment Readiness:
- [ ] All critical features implemented
- [ ] Core workflows tested
- [ ] Error handling in place
- [ ] Documentation updated
- [ ] Performance acceptable
```

---

## Phase 6: Comprehensive Summary Report

### Final Report Template

```markdown
# Work Completion Report

## 📊 Executive Summary
- **Acceptance Criteria Score**: [X]/10
- **Test Suite Health**: [Passing | Partially Passing | Failing]
- **Tests Auto-Fixed**: [Count]
- **Integration Coverage**: [X]/10
- **Recommendation**: [Continue /implement-phase | File bugs | Complete]
- **Estimated Effort**: [Hours/Days to complete]
- **Risk Level**: [Low | Medium | High]

## ✅ Completed Work
- [List of completed features/criteria]
- Total: [X] items

## ⚠️ Remaining Work
### Acceptance Criteria Gaps
- [List of incomplete criteria]
- Total: [Y] items

### Test Failures (After Auto-Fix)
- High Priority: [Count] failures blocking functionality
- Medium Priority: [Count] failures affecting quality
- Low Priority: [Count] minor issues

## 🧪 Test Status
### Test Results
- **Total Tests**: [X]
- **Passing**: [Y] ([percentage]%)
- **Auto-Fixed**: [Z]
- **Still Failing**: [W]

### Integration Test Coverage
- **Coverage Rating**: [X]/10
- **Critical Gaps**: [List]
- **Recommended Tests**: [Count]

## 📋 Next Steps
### Immediate Actions
1. [If test failures] Fix blocking test failures:
   - `/bug "Fix [test failure 1]"`
   - `/bug "Fix [test failure 2]"`

2. [Based on completion score]:
   - [If <70%] `/implement-phase specs/[spec] specs/[test-spec]`
   - [If >=70%] File minor bugs for remaining items
   - [If 100%] Ready for deployment

3. [If coverage gaps] Add recommended integration test

### Follow-up Actions
- [Additional recommendations based on analysis]

## 💡 Additional Notes
- [Any important observations from test runs]
- [Patterns in failures that suggest architectural issues]
- [Potential improvements]
- [Future considerations]
```

---

## Usage Guidelines

### When to Use This Command

**Use `/check-work` when:**
- You've completed one or more `/implement-phase` runs
- You're unsure if the feature is complete
- You want to assess test coverage
- You need to decide between continuing implementation or filing bugs

**Prerequisites:**
- Specification files with clear acceptance criteria
- At least one implementation phase completed
- Git history showing implementation commits

### What This Command Does NOT Do

- Does not write any code
- Does not fix issues (use `/bug` for fixes)
- Does not update documentation (Clean the House phase handles docs)

### Integration with Other Commands

**Workflow:**
1. `/spec` → Create specification
2. `/implement-phase` → Implement features (includes Clean the House for docs)
3. **`/check-work`** → Assess completion ← YOU ARE HERE
4. `/bug` or `/implement-phase` → Address gaps
5. Ready for deployment

---

## Example Output

```markdown
# Work Completion Report

## 📊 Executive Summary
- **Completion Score**: 7/10
- **Recommendation**: File targeted bugs
- **Estimated Effort**: 2-3 hours
- **Risk Level**: Low

## ✅ Completed Work (70%)
- ✅ Phase 1: Core checkpoint system implemented
- ✅ Phase 2: Recovery mechanisms in place
- ✅ Phase 3: Error handling added
- ✅ Unit tests for all new classes

## ⚠️ Remaining Work (30%)
- ❌ Edge case: Handling corrupt checkpoint files
- ❌ Missing validation for checkpoint size limits
- ❌ Integration test for full recovery workflow

## 🧪 Test Coverage
- **Integration Test Rating**: 6/10
- **Critical Gaps**:
  - No test for checkpoint corruption recovery
  - Missing end-to-end workflow test
- **Recommended Tests**: 2 high-priority tests

## 📋 Next Steps
1. `/bug "Add validation for corrupt checkpoint files"`
2. `/bug "Implement checkpoint size limit of 100MB"`
3. Add integration test: `test_checkpoint_recovery_workflow`

## 💡 Additional Notes
- Consider adding metrics/logging for checkpoint operations
- Future: Could add checkpoint compression for large datasets
```

---

Ready to analyze your implementation against specifications:
- **Main Spec:** $1
- **Test Spec:** $2