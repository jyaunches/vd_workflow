---
description: Execute the complete feature development workflow from spec to implementation
argument-hint: <spec_file_path>
---

# Execute Automated Workflow: $ARGUMENTS

I'll execute the complete automated two-phase workflow for the specified specification file.

**This command is designed for non-interactive execution** using `claude -p` with `--dangerously-skip-permissions` flag to auto-accept all tool uses.

## Workflow Overview

The workflow executes in two independent phases:

**Phase 1: Review (review-executor agent)**
1. Simplify Specification - Apply pattern enforcement from `shared_docs/PATTERNS.md`
2. Generate Test Specification - Create comprehensive test specs
3. Design Review - Review design patterns and architecture
4. Implementation Review - Review implementation decisions and clarity

**Phase 2: Implementation (feature-writer agent)**
5. Implement Phases - TDD-based phase implementation (tracked via git SHA markers in spec)
6. Validation - Run tests and validate acceptance criteria

**Intelligent Recommendation Filtering**: Review phase automatically applies recommendations that align with `shared_docs/PATTERNS.md` and existing architecture, but pauses for user approval on architectural changes, breaking changes, or new dependencies.

---

## Execution

Let me begin the automated workflow execution:

### Step 1: Check Prerequisites

First, verify all prerequisites are met:

```bash
# Check specs directory exists
[ -d "specs" ] && echo "specs/: FOUND" || echo "specs/: NOT FOUND - will be created by /vd_workflow:spec"
```

**Note**: The `review-executor` and `feature-writer` agents are provided by the vd_workflow plugin. No local agent files are required.

### Step 2: Extract Spec File Path and Extra Instructions

Parse the arguments: **$ARGUMENTS**

**Format**: `<spec_file_path> [extra instructions]`

Examples:
- `specs/my_spec.md` - Just the spec file
- `specs/my_spec.md "Focus on performance, this is for high-volume production"` - Spec + context
- `specs/my_spec.md "Keep it simple, this is a prototype"` - Spec + simplicity guidance

Extract:
- `SPEC_FILE` - The first argument (spec file path)
- `EXTRA_INSTRUCTIONS` - Everything after the spec file path (optional)

If `EXTRA_INSTRUCTIONS` is provided, it will be passed to both review-executor and feature-writer agents to influence their execution.

### Step 3: Execute Review Phase

Invoke the review-executor agent to execute the review phase.

Use the Task tool to invoke review-executor:

**Task Tool Parameters:**
- **subagent_type**: `"review-executor"`
- **description**: `"Execute spec review phase"`
- **model**: `"sonnet"` (agent default)
- **prompt**:
```
Execute the review phase for specification: $SPEC_FILE

[If EXTRA_INSTRUCTIONS provided:]
Additional Context/Guidance:
$EXTRA_INSTRUCTIONS

Use this guidance to inform your review decisions, simplifications, and recommendations.
[End if]

Run the following commands in sequence:
1. /execute-wf:spec-simplify $SPEC_FILE --auto-apply
2. /execute-wf:spec-tests $SPEC_FILE
3. /execute-wf:spec-review-design $SPEC_FILE <test_spec_file> --auto-apply
4. /execute-wf:spec-review-implementation $SPEC_FILE <test_spec_file> --auto-apply

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

The test spec file path will be derived from spec filename: tests_<spec_file_name>.md
```

**Review-executor agent will:**
- Execute all review commands with --auto-apply
- Use `/take-recommendations` to apply safe changes
- Pause only for architectural decisions
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
Implement feature from spec: $SPEC_FILE
Test spec: <test_spec_file>

Process phases sequentially by parsing the spec file:
1. Find phases without [COMPLETED:] markers
2. Execute /execute-wf:implement-phase $SPEC_FILE <test_spec_file> --auto for each
3. When all phases complete, run /execute-wf:check-work $SPEC_FILE <test_spec_file>

Phase completion is tracked via [COMPLETED: git-sha] markers in the spec file.
```

**Feature-writer agent will:**
- Parse spec file to find incomplete phases (those without `[COMPLETED:]`)
- Execute `/execute-wf:implement-phase` for each phase in order
- Execute `/execute-wf:check-work` for validation after all phases complete
- Generate completion summary

---

## Two-Phase Architecture Benefits

**Phase 1: Review**
- Reviews and refines the specs
- Git history tracks all review decisions
- Clean separation: spec refinement

**Phase 2: Implementation**
- Implements phases from reviewed specs
- Git SHA markers track phase completion in spec file
- Clean separation: feature building

**Why This Works:**
- Reviewed specs become the "contract" between phases
- No context needed from review phase to implementation phase
- Each phase is independently trackable
- Git history + `[COMPLETED: sha]` markers provide full traceability

## Workflow State

Track progress using:

**During Review Phase:**
- `git log --oneline -N` - See review changes

**During Implementation Phase:**
- `grep "\[COMPLETED:" spec.md` - See completed phases
- `git log --oneline -N` - See implementation commits

---

**Starting automated workflow execution for**: $ARGUMENTS
