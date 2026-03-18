# Plan: `/chrysalis:feature` — Worktree-Isolated Workflow with PR Creation

## Overview

New top-level command that wraps `execute-wf` with git worktree isolation and automatic PR creation. The user runs this instead of `execute-wf` when they want the work done on a feature branch in a separate checkout.

**Usage**: `/chrysalis:feature <spec_dir> [extra instructions]`

**Example**: `/chrysalis:feature specs/2026-02-11_user_auth/ "Focus on security"`

## Architecture Decision: How to Run in the Worktree

**Problem**: Claude Code's `Read`/`Write`/`Edit`/`Glob`/`Grep` tools work with absolute paths, and `Bash` maintains its own cwd. Agents launched via `Task` inherit the parent's working directory. We need the three agents (review-executor, feature-writer, validation-executor) to operate entirely within the worktree.

**Chosen approach**: The new command does NOT call `/execute-wf` as a sub-skill. Instead, it directly orchestrates the same three agents but with **absolute paths** and an explicit instruction to `cd` into the worktree for all Bash operations. This avoids nested skill invocation complexity and gives full control over path resolution.

The agents themselves don't need modification — the prompt given to each agent includes:
- The absolute worktree path as the working directory
- Absolute `SPEC_DIR` path (e.g., `/path/to/worktree/specs/2026-02-11_user_auth/`)
- Instruction to `cd $WORKTREE_PATH` before any Bash commands

## New File

**`plugins/chrysalis/commands/feature.md`** — Single new command file (~200 lines)

No changes to existing files (agents, execute-wf, sub-commands).

## Command Flow

### Step 1: Parse & Validate
- Extract `<spec_dir>` and optional extra instructions from `$ARGUMENTS`
- Verify `<spec_dir>/spec.md` exists
- Ensure spec changes are committed (no uncommitted spec files)
- Determine repo root (`git rev-parse --show-toplevel`) and repo name (basename)
- Determine current branch (used as the base for PR)

### Step 2: Create Feature Branch & Worktree
- Derive feature name from spec dir: `specs/2026-02-11_user_auth/` → `user_auth`
- Branch name: `feature/<feature_name>` (e.g., `feature/user_auth`)
- Worktree path: `../<repo_name>--<feature_name>/` (sibling directory)
  - Example: repo at `/Users/me/Dev/my_project` → worktree at `/Users/me/Dev/my_project--user_auth/`
- Commands:
  ```bash
  git branch feature/<feature_name>
  git worktree add ../<repo_name>--<feature_name> feature/<feature_name>
  ```
- Compute absolute paths:
  - `WORKTREE_PATH` = absolute path to worktree
  - `WORKTREE_SPEC_DIR` = `$WORKTREE_PATH/$SPEC_DIR`

### Step 3: Execute Review Phase (in worktree)
- Invoke `review-executor` agent via Task tool
- Prompt includes:
  - `WORKTREE_PATH` — "Change to this directory before any Bash operations: `cd $WORKTREE_PATH`"
  - `WORKTREE_SPEC_DIR` — absolute spec directory path
  - All the same orchestration instructions as execute-wf Step 3
- Agent runs spec-simplify, spec-tests, validation-plan, validation-review, design review, implementation review — all operating in the worktree

### Step 4: Execute Implementation Phase (in worktree)
- Invoke `feature-writer` agent via Task tool
- Same pattern: worktree path + absolute spec dir in prompt
- Agent implements phases using TDD, all commits land on the feature branch in the worktree

### Step 5: Execute Validation Phase (in worktree)
- Invoke `validation-executor` agent via Task tool
- Same pattern: worktree path + absolute spec dir in prompt
- Agent executes BDD scenarios, auto-fixes, marks validated

### Step 6: Push & Create Pull Request
- Push feature branch to remote:
  ```bash
  cd $WORKTREE_PATH && git push -u origin feature/<feature_name>
  ```
- Extract spec title/overview for PR description
- Create PR using `gh pr create`:
  ```bash
  cd $WORKTREE_PATH && gh pr create \
    --base <base_branch> \
    --title "<feature title from spec>" \
    --body "<workflow summary + validation results>"
  ```
- Report PR URL to user

### Step 7: Report & Cleanup Info
- Display:
  - PR URL
  - Worktree location
  - Branch name
  - Validation summary (pass/fail counts)
- Provide cleanup command:
  ```bash
  git worktree remove ../<repo_name>--<feature_name>
  git branch -d feature/<feature_name>  # after PR is merged
  ```
- Do NOT auto-delete the worktree (user may want to inspect)

## Branch & Worktree Naming Convention

| Spec Dir | Branch | Worktree Dir (sibling) |
|---|---|---|
| `specs/2026-02-11_user_auth/` | `feature/user_auth` | `../<repo>--user_auth/` |
| `specs/2026-01-05_dark_mode/` | `feature/dark_mode` | `../<repo>--dark_mode/` |

The date prefix is stripped from the branch/worktree name since it's metadata, not part of the feature identity.

## PR Body Template

```markdown
## Summary
<Extracted from spec overview/objectives>

## Workflow Phases Completed
- [x] Spec Review (simplification, test spec, validation plan)
- [x] Implementation (N phases completed via TDD)
- [x] Validation (X/Y BDD scenarios passed)

## Validation Results
<Summary table from validation-executor output>

## Spec
<Link or path to spec file>

---
Generated by chrysalis automated feature pipeline
```

## What Does NOT Change

- `execute-wf.md` — unchanged, still usable standalone
- Agent definitions (`review-executor.md`, `feature-writer.md`, `validation-executor.md`) — unchanged
- All sub-commands — unchanged
- `spec.md` — unchanged

## Edge Cases Handled

1. **Branch already exists**: Error with clear message, don't overwrite
2. **Worktree dir already exists**: Error with clear message
3. **Uncommitted spec changes**: Prompt user to commit first
4. **No git remote**: Warn and skip PR creation, but still complete workflow
5. **`gh` not installed**: Warn and provide manual PR creation instructions
