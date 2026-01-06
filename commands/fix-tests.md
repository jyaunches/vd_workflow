---
name: fix-tests
description: Run tests, identify failures, and fix them with context from recent commits
usage: /fix-tests [--limit N]
examples:
  - /fix-tests
  - /fix-tests --limit 5
---

# fix-tests: $ARGUMENTS

Run `make test` to identify failing tests, then attempt to fix them using context from recent commits. This command helps maintain test health after implementing new features or fixes.

## Arguments

- `--limit N` (optional): Only process the first N failing tests (default: process all)

## Process

### Phase 1: Run Tests and Identify Failures

1. Run `make test` to execute the full test suite
2. Parse the output to identify all failing tests
3. Extract test names, file paths, and failure messages
4. Present a summary of all failing tests to the user

### Phase 2: Analyze Commit Context

For each failing test:

1. **Identify the test file location** (e.g., `tests/historical_context/test_service.py`)
2. **Search recent commits** (last 10) for clues:
   - Commits that modified the test file itself
   - Commits that modified the source files being tested
   - Commit messages mentioning related features
3. **Analyze the failure message** to understand:
   - What assertion failed
   - Expected vs actual values
   - Stack trace and error type
4. **Categorize the failure:**
   - **Clear context**: Failure clearly relates to a specific recent commit
   - **Unclear context**: Failure doesn't clearly map to recent work
   - **New field/API change**: Test expects old field names or API
   - **Data/fixture update needed**: Ground truth or fixture out of sync

### Phase 3: Fix Tests with Clear Context

For tests with clear commit context:

1. **Present the analysis:**
   - Test name and failure message
   - Related commit(s) identified
   - Proposed fix approach
2. **Implement the fix** automatically
3. **Run the specific test** to verify it passes
4. **Commit the fix** with a reference to the original work:
   ```
   test: Fix [test_name] after [commit_subject]

   Updates test to work with changes from commit [short_sha].
   [Brief explanation of what needed to be updated]

   Related to: [short_sha]

   🤖 Generated with Claude Code

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

### Phase 4: Present Unclear Cases

For tests without clear context:

1. **Present the failing test details:**
   - Test name and location
   - Full failure message and stack trace
   - Recent commits that might be related
2. **Ask the user for guidance:**
   - Is this related to recent work?
   - Should we investigate the failure?
   - Should we skip this test for now?
3. **Wait for user decision** before proceeding

### Phase 5: Final Verification

1. Run `make test` again to verify all fixes work
2. Present summary of:
   - Tests fixed automatically
   - Tests fixed with user guidance
   - Tests still failing (if any)
3. Show final git status

## Commit Context Analysis Strategy

The command will look for:

1. **Direct file changes:**
   - `git log --oneline -10 -- <test_file_path>`
   - `git log --oneline -10 -- <source_file_path>`

2. **Related commit messages:**
   - Commits mentioning the feature being tested
   - Commits with "fix:", "test:", "refactor:" related to the same area

3. **Recent changes to tested modules:**
   - Parse the test file to identify which modules it imports
   - Check if those modules were modified recently

## Categorization Rules

**Clear Context:**
- Test file modified in last 3 commits
- Source file modified in last 3 commits
- Commit message explicitly mentions the test or feature
- Failure is about new field names (e.g., `current` -> `volatility_20d`)
- Failure is about API changes clearly visible in recent commits

**Unclear Context:**
- Test hasn't been modified recently
- Source file hasn't been modified recently
- Failure appears unrelated to recent work
- Failure is in infrastructure/fixtures not touched recently
- Complex integration test with many dependencies

## Example Output

```
=== Phase 1: Running Tests ===
Running: make test

Found 3 failing tests:
  1. tests/historical_context/test_service.py::TestHistoricalContextService::test_volatility_fields
  2. tests/integration/test_api.py::TestAPI::test_historical_endpoint
  3. tests/unit/test_validator.py::TestValidator::test_bounds

=== Phase 2: Analyzing Commit Context ===

Test 1: test_volatility_fields
  Status: CLEAR CONTEXT
  Related commit: fc609a4 "fix: Align historical-context volatility calculation"
  Failure: KeyError: 'current'
  Analysis: Test expects old field name 'current', but commit fc609a4 changed it to 'volatility_20d'
  Fix: Update test assertions to use new field names

Test 2: test_historical_endpoint
  Status: CLEAR CONTEXT
  Related commit: 4396645 "fix: Remove incorrect data transformation in API client"
  Failure: List index out of expected order
  Analysis: Test assumes prices are oldest-first, but commit 4396645 changed to newest-first
  Fix: Reverse test expectations to match new ordering

Test 3: test_bounds
  Status: UNCLEAR CONTEXT
  No recent commits modified test_validator.py or validator.py
  Failure: AssertionError: expected 10, got 11
  Analysis: Cannot determine which recent commit caused this failure
  Action: Needs user guidance

=== Phase 3: Fixing Clear Context Tests ===

Fixing test_volatility_fields...
  ✓ Updated assertions for new field names
  ✓ Test now passes
  ✓ Committed: "test: Fix test_volatility_fields after volatility calculation alignment"

Fixing test_historical_endpoint...
  ✓ Reversed list ordering expectations
  ✓ Test now passes
  ✓ Committed: "test: Fix test_historical_endpoint after API ordering fix"

=== Phase 4: Unclear Cases - User Guidance Needed ===

Test: test_bounds
Location: tests/unit/test_validator.py::TestValidator::test_bounds
Failure:
  AssertionError: expected 10, got 11
  at line 45: assert result.count == 10

Recent commits (last 10):
  6f6d5a6 test: Update tests for new volatility fields and dual fetch strategy
  fc609a4 fix: Align historical-context volatility calculation with realtime-context
  4396645 fix: Remove incorrect data transformation in API client
  77f10dd Fix exception handling to properly log errors and return correct HTTP status codes
  ...

How would you like to proceed?
  1. Investigate this failure
  2. Skip for now
  3. Revert recent changes to validator.py
```

## Benefits

- **Automated fixes** for straightforward test updates
- **Commit context** helps understand why tests are failing
- **Clean git history** with references to original work
- **User guidance** for complex or unclear failures
- **Verification** that fixes actually work

## Notes

- Always run the full test suite first to get complete picture
- Fix tests in order of clarity (clear context first)
- Don't guess at fixes - present unclear cases to user
- Commit each test fix separately with proper references
- Re-run full suite at the end to catch any regressions
- If a test fix requires source code changes, present to user first
