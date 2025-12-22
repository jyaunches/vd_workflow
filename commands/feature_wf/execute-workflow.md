---
name: execute-workflow
description: Execute the complete feature development workflow from spec to implementation
usage: /execute-workflow <spec_file_path>
example:
  - /execute-workflow specs/2025-11-09_15-23_report-storage-system.md
  - /execute-workflow specs/2025-11-10_10-45_api-caching.md
---

# Execute Automated Workflow: $ARGUMENTS

I'll execute the complete automated two-phase workflow for the specified specification file.

**This command is designed for non-interactive execution** using `claude -p` with `--dangerously-skip-permissions` flag to auto-accept all tool uses.

## Workflow Overview

The workflow executes in two independent phases:

**Phase 1: Review (review-executor agent)**
1. Simplify Specification - Apply PATTERNS.md enforcement
2. Generate Test Specification - Create comprehensive test specs
3. Design Review - Review design patterns and architecture
4. Implementation Review - Review implementation decisions and clarity

**Phase 2: Implementation (feature-writer agent)**
5. Implement Phases - TDD-based phase implementation (tracked with beads)
6. Validation - Run tests and validate acceptance criteria (tracked with beads)

**Intelligent Recommendation Filtering**: Review phase automatically applies recommendations that align with PATTERNS.md and existing architecture, but pauses for user approval on architectural changes, breaking changes, or new dependencies.

---

## Execution

Let me begin the automated workflow execution:

### Step 1: Check Prerequisites

First, verify all prerequisites are met:

```bash
# Check beads is initialized
ls -la .beads/ 2>/dev/null || echo "BEADS_NOT_INITIALIZED"
```

```bash
# Check PATTERNS.md exists (optional - used for pattern enforcement)
ls -la .claude/PATTERNS.md 2>/dev/null || echo "PATTERNS_NOT_FOUND"
```

**Note**: The `review-executor` and `feature-writer` agents are provided by the cc_workflow_tools plugin. No local agent files are required.

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

### Step 3: Initialize Beads (if needed)

If `.beads/` directory doesn't exist:
- Use `mcp__beads__init` to initialize beads in workspace

### Step 4: Execute Review Phase

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
1. /feature_wf:spec-simplify $SPEC_FILE --auto-apply
2. /feature_wf:spec-tests $SPEC_FILE
3. /feature_wf:spec-review-design $SPEC_FILE <test_spec_file> --auto-apply
4. /feature_wf:spec-review-implementation $SPEC_FILE <test_spec_file> --auto-apply

For each review command:
- Auto-apply safe recommendations using /feature_wf:take-recommendations
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

### Step 5: Parse Reviewed Specs for Phases

Read the final reviewed spec file and extract all phase headers:

```bash
grep -E "^#+\s+Phase\s+[0-9]+:" "$SPEC_FILE"
```

Count the phases found for bead creation.

### Step 6: Create Beads for Implementation

Use beads to create the workflow tracking structure:

**IMPORTANT**: Do NOT specify `id` parameter when creating tasks - let beads auto-generate IDs with the correct prefix.

1. Create epic: "Feature: [feature_name]" (extracted from spec filename)
   - Use `mcp__beads__create` with `issue_type="epic"`, `title="Feature: [feature_name]"`, `description="..."`, `priority=1`
   - Do NOT include `id` parameter - beads will auto-generate with correct prefix
   - Store the epic ID for linking tasks

2. Create tasks for each phase found:
   - For each phase N: "Phase N: [phase_name]" (task, priority 1)
   - "Validation - check-work" (task, priority 1)
   - For each task: use `mcp__beads__create` WITHOUT `id` parameter

3. Set up dependencies:
   - Phase 1 blocks Phase 2
   - Phase N blocks Phase N+1
   - Last Phase blocks Validation

### Step 7: Execute Implementation Phase

Invoke the feature-writer agent to implement the phases.

Use the Task tool to invoke feature-writer:

**Task Tool Parameters:**
- **subagent_type**: `"feature-writer"`
- **description**: `"Implement feature phases"`
- **model**: `"sonnet"` (agent default)
- **prompt**:
```
Implement the feature defined in reviewed specs: $SPEC_FILE

The beads epic and phase tasks have been created based on the reviewed specs.

Your responsibilities:
1. Query beads for the next ready phase task (bd ready --json)
2. Based on the task title, execute the appropriate command:
   - "Phase N: ..." → /feature_wf:implement-phase $SPEC_FILE <test_spec_file> --auto
   - "Validation" → /feature_wf:check-work $SPEC_FILE <test_spec_file>
3. Before executing each phase, update the task to in_progress
4. After successful completion, close the task
5. If blocked, update task with issue details
6. Continue until all phases and validation complete

Key details:
- Spec file: $SPEC_FILE
- Test spec file: <test_spec_file> (derived from spec filename)
- Use --auto flag for non-interactive implementation
- Follow TDD approach for each phase

When all tasks complete:
- Close the epic
- Output completion summary with phase count and test results
```

**Feature-writer agent will:**
- Query beads for ready tasks
- Execute `/feature_wf:implement-phase` for each phase
- Execute `/feature_wf:check-work` for validation
- Update beads task status throughout
- Generate completion summary

---

## Two-Phase Architecture Benefits

**Phase 1: Review (No Beads)**
- Reviews and refines the specs
- Git history tracks all review decisions
- No beads overhead for review tasks
- Clean separation: spec refinement

**Phase 2: Implementation (With Beads)**
- Creates beads from reviewed specs
- Beads track implementation progress
- Clean separation: feature building

**Why This Works:**
- Reviewed specs become the "contract" between phases
- No context needed from review phase to implementation phase
- Each phase is independently trackable
- Git history for review decisions, beads for implementation progress

## Workflow State

Track progress using:

**During Review Phase:**
- `git log --oneline -N` - See review changes

**During Implementation Phase:**
- `bd ready` - Show tasks ready to execute
- `bd list --status in_progress` - Show current tasks
- `bd list --status closed` - Show completed tasks
- `bd blocked` - Show blocked tasks

---

**Starting automated workflow execution for**: $ARGUMENTS
