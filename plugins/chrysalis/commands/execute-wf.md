---
description: Execute the complete feature development workflow from spec to implementation
argument-hint: <spec_dir>
---

# Execute Automated Workflow: $ARGUMENTS

I'll execute the complete automated three-phase workflow for the specified spec directory.

**This command is designed for non-interactive execution** using `claude -p` with `--dangerously-skip-permissions` flag to auto-accept all tool uses.

## Spec Directory Structure

The `<spec_dir>` argument points to a directory containing:
```
<spec_dir>/
├── spec.md          # Main specification
├── tests.md         # Test specification (generated during review)
└── validation.md    # Validation plan (generated during review)
```

## Workflow Overview

The workflow executes in three phases:

**Phase 1: Review (review-executor agent)**
1. Simplify Specification - Apply pattern enforcement from `shared_docs/PATTERNS.md`
2. Generate Test Specification - Create `<spec_dir>/tests.md`
3. Generate Validation Plan - Create `<spec_dir>/validation.md` with BDD scenarios
4. Validation Review - **User approval of validation plan**
5. Design Review - Review design patterns and architecture
6. Implementation Review - Review implementation decisions and clarity

**Phase 2: Implementation (feature-writer agent)**
7. Implement Phases - TDD-based phase implementation (tracked via git SHA markers in spec)
8. Check Work - Validate acceptance criteria and test coverage

**Phase 3: Validation (validation-executor agent)**
9. Execute Validation - Run BDD scenarios from `validation.md`
10. Fix Issues - Use `/bug --auto` for failures (3 attempts per scenario)
11. Mark Complete - Add `[VALIDATED: sha]` markers to passed scenarios

**Intelligent Recommendation Filtering**: Review phase automatically applies recommendations that align with `shared_docs/PATTERNS.md` and existing architecture, but pauses for user approval on architectural changes, breaking changes, or new dependencies.

---

## Execution

Let me begin the automated workflow execution:

### Step 1: Check Prerequisites

First, verify all prerequisites are met:

```bash
# Check specs directory exists
[ -d "specs" ] && echo "specs/: FOUND" || echo "specs/: NOT FOUND - will be created by /chrysalis:spec"
```

**Note**: The `review-executor` and `feature-writer` agents are provided by the chrysalis plugin. No local agent files are required.

### Step 1b: Locate PATTERNS.md

The workflow uses `PATTERNS.md` to determine which recommendations can be auto-applied. Locate it using this fallback order:

1. **Repo-local**: `shared_docs/PATTERNS.md` (project customization)
2. **Plugin default**: `~/Development/chrysalis/plugins/chrysalis/shared_docs/PATTERNS.md`

```bash
# Check for PATTERNS.md
if [ -f "shared_docs/PATTERNS.md" ]; then
  PATTERNS_PATH="shared_docs/PATTERNS.md"
elif [ -f "$HOME/Development/chrysalis/plugins/chrysalis/shared_docs/PATTERNS.md" ]; then
  PATTERNS_PATH="$HOME/Development/chrysalis/plugins/chrysalis/shared_docs/PATTERNS.md"
else
  echo "WARNING: PATTERNS.md not found - auto-apply will use conservative defaults"
  PATTERNS_PATH=""
fi
```

Read the PATTERNS.md file (if found) to understand the project's coding patterns and standards. This informs which review recommendations can be safely auto-applied.

### Step 2: Extract Spec Directory and Extra Instructions

Parse the arguments: **$ARGUMENTS**

**Format**: `<spec_dir> [extra instructions]`

Examples:
- `specs/2024-01-15_user_auth/` - Just the spec directory
- `specs/2024-01-15_user_auth/ "Focus on performance, this is for high-volume production"` - Spec dir + context
- `specs/2024-01-15_user_auth/ "Keep it simple, this is a prototype"` - Spec dir + simplicity guidance

Extract:
- `SPEC_DIR` - The first argument (spec directory path)
- `EXTRA_INSTRUCTIONS` - Everything after the spec directory path (optional)

Derive internal paths:
- `SPEC_FILE` = `$SPEC_DIR/spec.md`
- `TEST_SPEC_FILE` = `$SPEC_DIR/tests.md`
- `VALIDATION_FILE` = `$SPEC_DIR/validation.md`

If `EXTRA_INSTRUCTIONS` is provided, it will be passed to review-executor, feature-writer, and validation-executor agents to influence their execution.

### Step 3: Execute Review Phase

Invoke the review-executor agent to execute the review phase.

Use the Task tool to invoke review-executor:

**Task Tool Parameters:**
- **subagent_type**: `"review-executor"`
- **description**: `"Execute spec review phase"`
- **model**: `"sonnet"` (agent default)
- **prompt**:
```
Execute the review phase for spec directory: $SPEC_DIR

[If EXTRA_INSTRUCTIONS provided:]
Additional Context/Guidance:
$EXTRA_INSTRUCTIONS

Use this guidance to inform your review decisions, simplifications, and recommendations.
[End if]

Run the following commands in sequence:
1. /execute-wf:spec-simplify $SPEC_DIR --auto-apply
2. /execute-wf:spec-tests $SPEC_DIR
3. /execute-wf:validation-plan $SPEC_DIR
4. /execute-wf:validation-review $SPEC_DIR  ← PAUSES FOR USER APPROVAL
5. /execute-wf:spec-review-design $SPEC_DIR --auto-apply
6. /execute-wf:spec-review-implementation $SPEC_DIR --auto-apply

For each review command:
- Auto-apply safe recommendations using /execute-wf:take-recommendations
- Pause only for architectural decisions needing user approval
- Track all changes via git commits
- Consider the additional guidance when making decisions

After all reviews complete, generate a comprehensive summary of:
- What was simplified
- What design improvements were made
- What implementation decisions were made
- How many git commits were created
- Which files were modified
- Validation plan summary (scenarios created)

Internal paths derived from spec directory:
- spec.md at $SPEC_DIR/spec.md
- tests.md at $SPEC_DIR/tests.md
- validation.md at $SPEC_DIR/validation.md
```

**Review-executor agent will:**
- Execute all review commands with --auto-apply
- Create tests.md and validation.md in the spec directory
- Use `/take-recommendations` to apply safe changes
- Pause for validation review (user approves BDD scenarios)
- Pause only for architectural decisions needing user approval
- Generate summary of all changes made

**Wait for review phase to complete and return summary.**

### Step 4: Execute Implementation Phase

Invoke the feature-writer agent to implement the phases.

Use the Task tool to invoke feature-writer:

**Task Tool Parameters:**
- **subagent_type**: `"feature-writer"`
- **description**: `"Implement feature phases"`
- **model**: `"sonnet"` (agent default)
- **prompt**:
```
Implement feature from spec directory: $SPEC_DIR

Internal paths:
- Spec: $SPEC_DIR/spec.md
- Test spec: $SPEC_DIR/tests.md

Process phases sequentially by parsing the spec file:
1. Find phases without [COMPLETED:] markers
2. Execute /execute-wf:implement-phase $SPEC_DIR --auto for each
3. When all phases complete, run /execute-wf:check-work $SPEC_DIR

Phase completion is tracked via [COMPLETED: git-sha] markers in the spec file.
```

**Feature-writer agent will:**
- Parse spec file to find incomplete phases (those without `[COMPLETED:]`)
- Execute `/execute-wf:implement-phase` for each phase in order
- Execute `/execute-wf:check-work` for validation after all phases complete
- Generate completion summary

### Step 5: Execute Validation Phase

Invoke the validation-executor agent to run BDD scenarios.

Use the Task tool to invoke validation-executor:

**Task Tool Parameters:**
- **subagent_type**: `"validation-executor"`
- **description**: `"Execute validation scenarios"`
- **model**: `"sonnet"` (agent default)
- **prompt**:
```
Execute validation for spec directory: $SPEC_DIR

Validation plan: $SPEC_DIR/validation.md

Loop through each scenario in the validation plan:
1. Parse BDD scenarios from validation.md
2. Execute each scenario using specified tools
3. On failure: invoke /chrysalis:bug --auto (up to 3 attempts)
4. On pass: add [VALIDATED: sha] marker to scenario
5. Update summary table after each scenario
6. Continue until all scenarios pass or max attempts reached

Return final validation report with pass/fail status for each scenario.
```

**Validation-executor agent will:**
- Parse BDD scenarios from validation.md
- Execute each scenario with retry logic
- Use `/bug --auto` to fix failures automatically
- Track progress with `[VALIDATED: sha]` markers
- Generate final validation report

---

## Three-Phase Architecture Benefits

**Phase 1: Review**
- Reviews and refines the specs
- Creates test spec and validation plan
- User approves validation scenarios
- Git history tracks all review decisions
- Clean separation: spec refinement

**Phase 2: Implementation**
- Implements phases from reviewed specs
- Git SHA markers track phase completion in spec file
- Clean separation: feature building

**Phase 3: Validation**
- Executes BDD scenarios from validation plan
- Auto-fixes failures with `/bug --auto`
- Validates feature works end-to-end
- Clean separation: quality assurance

**Why This Works:**
- Reviewed specs and validation plan become the "contract" between phases
- No context needed between phases
- Each phase is independently trackable
- Git history + `[COMPLETED: sha]` + `[VALIDATED: sha]` markers provide full traceability

## Workflow State

Track progress using:

**During Review Phase:**
- `git log --oneline -N` - See review changes
- `ls $SPEC_DIR/` - See generated artifacts (tests.md, validation.md)

**During Implementation Phase:**
- `grep "\[COMPLETED:" $SPEC_DIR/spec.md` - See completed phases
- `git log --oneline -N` - See implementation commits

**During Validation Phase:**
- `grep "\[VALIDATED:" $SPEC_DIR/validation.md` - See validated scenarios
- `grep "STATUS:" $SPEC_DIR/validation.md` - See scenario statuses

---

**Starting automated workflow execution for**: $ARGUMENTS
