---
description: Fix a bug using Test-Driven Development (TDD) methodology with optional automated execution
argument-hint: <description> [--auto]
---

# bug: $ARGUMENTS

Fix a bug using Test-Driven Development (TDD) methodology. This command guides Claude through researching the bug, writing a failing test, and then implementing the fix.

**Mode Detection:**
```bash
if [[ "$*" == *"--auto"* ]]; then
    echo "🚀 AUTO MODE: Will proceed through all phases without user approval"
else
    echo "📋 INTERACTIVE MODE: Will wait for approval at each phase"
fi
```

## Arguments

- `description`: A detailed description of the bug, including:
  - What behavior is observed
  - What behavior is expected
  - Any error messages or symptoms
  - Steps to reproduce (if known)
- `--auto` (optional): Enable automated execution without waiting for user approval at each phase

## Process

### Phase 1: Research & Planning
1. Analyze the bug description to understand the problem
2. **Reproduce the bug:**
   - Run the actual CLI commands that trigger the issue
   - Document exact steps, inputs, and outputs
   - Capture error messages, stack traces, or unexpected behavior
3. Search the codebase to locate relevant code
4. Identify the root cause of the issue
5. Determine which files need modification
6. **Present findings to the user:**
   - Bug reproduction steps and results
   - Root cause analysis
   - Files that need to be modified
   - Recommended fix approach
7. **IF INTERACTIVE MODE**: Wait for user approval before proceeding
8. **IF AUTO MODE**: Automatically proceed to Phase 2 after presenting findings

### Phase 2: Write Failing Test (TDD - Red)
1. Write a test that reproduces the bug scenario
2. Ensure the test captures the expected behavior
3. **Choose the appropriate test file location:**
   - **Add to existing test file**: If tests for the affected module/class already exist, add the new test to that file
   - **Create new logical test file**: Only if no appropriate test file exists, create one following the naming convention:
     - For module `src/myservice/reporting.py`, use `tests/unit/test_reporting.py`
     - For class `ReportingService`, add tests to existing `TestReportingService` class if it exists
     - Name test classes after the module/class being tested (e.g., `TestReportingService`, `TestBatchProcessor`)
   - **Never create bug-specific files**: Avoid names like `test_xyz_bug.py` or `test_issue_123.py`
   - **Follow existing organization**: Check how similar tests are organized in the codebase
4. Run the test to confirm it fails with the current code
5. **Present the failing test code and output to the user**
6. **IF INTERACTIVE MODE**: Discuss the test approach and get user feedback before committing
7. **IF AUTO MODE**: Automatically proceed to commit the failing test
8. Commit ONLY the failing test with message:
   ```
   test: Add failing test for [bug description]

   This test demonstrates the bug where [specific issue].
   Expected: [expected behavior]
   Actual: [current broken behavior]

   🤖 Generated with Claude Code

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
9. **IF INTERACTIVE MODE**: Wait for user confirmation before moving to implementation
10. **IF AUTO MODE**: Automatically proceed to Phase 3

### Phase 3: Implement Fix (TDD - Green)
1. **Present the implementation approach to the user**
2. **IF INTERACTIVE MODE**: Wait for user approval before implementing
3. **IF AUTO MODE**: Automatically proceed with implementation
4. Implement the minimal code change to make the test pass
5. Run the test to confirm it now passes
6. Run related tests to ensure no regressions
7. **Show the user the passing tests and implementation**
8. **IF INTERACTIVE MODE**: Wait for user approval before committing
9. **IF AUTO MODE**: Automatically commit the fix
10. Commit the fix with message:
   ```
   fix: [Concise description of what was fixed]

   Resolves issue where [bug description].
   The fix [brief explanation of the solution].

   🤖 Generated with Claude Code

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

### Phase 4: Refactor (TDD - Refactor) [Optional]
1. **Evaluate if refactoring is needed**
2. **IF INTERACTIVE MODE**: Discuss with user and get approval before refactoring
3. **IF AUTO MODE**: Only refactor if it's clearly necessary and safe
4. Implement agreed-upon refactoring
5. Ensure all tests still pass after refactoring
6. **IF INTERACTIVE MODE**: Get user approval before committing
7. **IF AUTO MODE**: Automatically commit refactoring
8. Commit any refactoring separately

## User Interaction Points

**INTERACTIVE MODE (default):**
The process includes explicit pauses for user interaction at each phase:

1. **After Research**: User reviews and approves the bug analysis and fix plan
2. **After Test Creation**: User reviews the failing test before it's committed
3. **After Test Commit**: User confirms readiness to proceed with implementation
4. **Before Fix Implementation**: User approves the implementation approach
5. **After Implementation**: User reviews the fix before it's committed
6. **Before Refactoring**: User decides if refactoring is needed

**AUTO MODE (--auto flag):**
The process runs autonomously without user interaction:

1. **After Research**: Present findings and automatically proceed to Phase 2
2. **After Test Creation**: Present failing test and automatically commit
3. **After Test Commit**: Automatically proceed to implementation
4. **After Implementation**: Present passing tests and automatically commit
5. **Refactoring**: Only perform if clearly necessary and safe

## Output

At each phase, Claude will provide:

### Phase 1 Output
- Summary of bug research findings
- Root cause analysis
- Proposed fix approach
- Files that will be modified

### Phase 2 Output
- The failing test code
- Test execution output showing the failure
- Explanation of what the test validates

### Phase 3 Output
- The fix implementation
- Test execution showing it now passes
- Any related tests that were run

### Phase 4 Output (if applicable)
- Refactoring changes
- Confirmation that all tests still pass

## Benefits

- **User Control**: User maintains oversight at each critical step (in interactive mode)
- **Automated Execution**: Supports `--auto` mode for unattended bug fixes
- **Test Coverage**: Ensures the bug fix includes a regression test
- **Documentation**: The test serves as documentation of the bug
- **Verification**: Confirms the fix actually resolves the issue
- **Clean History**: Separates test and implementation in git history
- **TDD Practice**: Follows red-green-refactor cycle with deliberate pacing

## Beads Issue Tracking (Auto Mode)

When using beads commands during automated bug fixes, always use these flags for non-interactive execution:

- **Use `--json` flag** on all beads commands for machine-readable output
- **Use `--force` flag** for destructive operations like `bd delete`
- **Environment**: `BD_ACTOR` is set to "claude-code" for automated tracking

Examples:
```bash
# Check ready work
bd ready --json

# Create new issue
bd create "Fix bug: [description]" -t bug -p 1 --json

# Update issue status
bd update bd-42 --status in_progress --json

# Close completed issue
bd close bd-42 --reason "Bug fixed" --json

# Delete issue (requires --force)
bd delete bd-42 --force --json
```

**Important**: Always use `--json` flag to prevent interactive prompts that would cause the command to hang when run with `--dangerously-skip-permissions`.

## Notes

- The test should be minimal and focused on the specific bug
- Follow existing test patterns in the codebase
- Use appropriate test fixtures and mocks as needed
- Avoid fixing unrelated issues in the same commit
- If the bug affects multiple areas, consider breaking into multiple bug fixes
- The test should fail for the right reason (the actual bug, not setup issues)
- User can skip phases or request modifications at any interaction point (interactive mode)
- In auto mode, Claude will make reasonable decisions and proceed autonomously
