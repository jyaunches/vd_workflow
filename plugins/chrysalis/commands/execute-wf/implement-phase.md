---
description: Execute implementation phases from specification and test specification files using test-driven development
argument-hint: <spec_dir> [--auto]
---

# Implement Phase: $ARGUMENTS

I'll execute the implementation phases from the specified spec directory following a rigorous test-driven development workflow.

**Internal Path Resolution:**
- Spec file: `<spec_dir>/spec.md`
- Test spec file: `<spec_dir>/tests.md`

**Mode Detection:**
```bash
if [[ "$*" == *"--auto"* ]]; then
    echo "🚀 AUTO MODE: Will proceed through all phases without user approval"
else
    echo "📋 INTERACTIVE MODE: Will wait for approval at each phase"
fi
```

**⚠️ CRITICAL: AUTO MODE BEHAVIOR**

When `--auto` flag is present:
- **NEVER pause** for user confirmation at any step
- **NEVER ask questions** or wait for user input
- **NEVER stop** because phase content mentions manual steps or user interaction
- **ALWAYS proceed** automatically through all 7 steps for each phase
- **Even validation phases** with steps like "wait for user to verify" should be executed automatically
- The ONLY reasons to stop: actual errors, test failures, or missing dependencies

**⚠️ CRITICAL: Token Usage Policy**

Do NOT stop implementation due to token usage warnings or budget notifications. Token usage should NEVER interrupt phase completion.

**Rules**:
- Always complete the current phase even if token usage is high
- Only stop implementation for actual errors or if user input is required (interactive mode)
- Token warnings are informational only - they do not mean you must stop
- Continue through all workflow steps (write tests → implement → commit → validate → mark complete)

Let me start by analyzing the spec directory and identifying the current phase status:

```bash
SPEC_DIR="${1%/}"  # Remove trailing slash if present
SPEC_FILE="$SPEC_DIR/spec.md"
TEST_SPEC_FILE="$SPEC_DIR/tests.md"

echo "Spec directory: $SPEC_DIR"
echo "Spec file: $SPEC_FILE"
echo "Test spec file: $TEST_SPEC_FILE"
```

```bash
echo "\n=== Phases in Specification ==="
grep -n "Phase.*:" "$SPEC_FILE" | head -10
```

```bash
echo "\n=== Completed Phases ==="
grep -n "\[COMPLETED:" "$SPEC_FILE" || echo "No completed phases found"
```

```bash
echo "\n=== Test Phases Available ==="
grep -n "Phase.*:" "$TEST_SPEC_FILE" | head -10
```

## Phase Execution Workflow

For each unfinished phase, I will follow this exact 7-step pattern:

### Step 1: Phase Review & Alignment
- **Review the phase** to understand scope and requirements
- **Review how/where to write unit tests** - look for existing unit tests to modify, ways to improve/reduce number of tests with pythonic strategies, reusable modules or fixtures to keep consistency across tests
- **Prepare TDD approach** - Plan the incremental writing of the tests and actual code to complete the phase
- **IF INTERACTIVE MODE**: Present plan to user and WAIT for user confirmation before proceeding
- **IF AUTO MODE**: Log the plan and **immediately proceed to Step 2 without any pause or user interaction**

**CRITICAL AUTO MODE RULE**: In `--auto` mode, NEVER pause, ask questions, or wait for confirmation. Even if the phase content mentions manual steps, user interaction, or seems to require human input - proceed automatically. The `--auto` flag means fully autonomous execution.

### Step 2: Write Tests First
- **Use test specification** to write tests from the corresponding phase in the test spec file
- **Follow test guide exactly** including existing tests to modify and new tests to create
- **Ensure tests fail** (red phase of TDD)
- **Commit failing tests** with descriptive commit message

### Step 3: Implement Code
- **Write minimal code** to make tests pass (green phase of TDD)
- **Follow existing patterns** and integrate with current architecture
- **Only implement** what's necessary to pass the tests

### Step 4: Commit Implementation
- **Verify all tests pass**
- **Commit the implementation** with descriptive commit message

### Step 5: Validate Acceptance Criteria
- **Review phase acceptance criteria**
- **Determine if additional test/implementation cycles** are needed
- **Repeat steps 2-4** if criteria require more functionality

### Step 6: Phase Completion Review
- **Verify completed phase** against acceptance criteria
- **IF INTERACTIVE MODE**: Present completed phase for review and get explicit agreement that the phase meets all requirements
- **IF AUTO MODE**: Automatically validate that all tests pass and acceptance criteria are met, then **immediately proceed to Step 7 without any pause**
- **Confirm phase is ready** to mark as complete

**REMINDER**: In `--auto` mode, do NOT pause here. If tests pass and acceptance criteria appear met, proceed immediately.

### Step 7: Update Specification
- **Mark phase as completed** in spec file: `[COMPLETED: git-sha]`
- **Include the final commit SHA** from the phase
- **Commit spec file update**

## Current Phase Analysis

Let me identify the next phase to implement and begin the workflow:

```bash
# Find the first phase that isn't marked as COMPLETED
echo "\n=== Next Phase Analysis ==="
awk '/^#{1,4}.*Phase.*:/ { phase=$0; getline; content=$0; if(phase !~ /COMPLETED:/) { print "NEXT PHASE:", phase; exit } }' "$SPEC_FILE"
```

Based on my analysis of both the specification file and test specification file, I'll now begin **Step 1: Phase Review & Alignment** for the next unfinished phase.

## Implementation Strategy

Following the project's integration philosophy:
- **Direct integration** into existing files
- **No backward compatibility** - always direct integration
- **No parallel systems** - enhance current code
- **Follow existing patterns** and conventions
- **Use uv for dependencies** (never pip install)
- **Maintain type annotations** and dataclass patterns

## Phase Analysis & Approval Process

**INTERACTIVE MODE (default):**
I will first analyze the phase and present a detailed implementation plan. **I will NOT proceed with implementation until you explicitly approve the approach.**

This allows for:
- Discussion of implementation strategy
- Refinement of the approach based on your feedback
- Alignment on technical decisions before coding begins

**AUTO MODE (--auto flag):**
I will analyze each phase, present the implementation plan, and immediately proceed with implementation without waiting for approval. This mode:
- Powers through all unfinished phases sequentially
- Commits tests and implementation automatically
- Marks phases as completed in the spec file
- Continues until all phases are complete

Ready to analyze the first unfinished phase from:
- **Spec Directory**: $SPEC_DIR
- **Specification**: $SPEC_DIR/spec.md
- **Test Specification**: $SPEC_DIR/tests.md
