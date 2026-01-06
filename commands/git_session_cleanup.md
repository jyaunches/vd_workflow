---
description: Clean up temporary scripts and files created during skill usage sessions
---

You are helping the user clean up their git working directory after skill usage sessions, including analyzing uncommitted functional work and test fixes.

## Task Overview

Perform a comprehensive cleanup that includes:
1. Analyzing uncommitted changes (modified files) in the context of recent git history
2. Reviewing untracked files and deciding what to keep, move, or delete

## Phase 1: Analyze Uncommitted Changes

### Steps:
1. Run `git status` to see all modified files
2. Run `git log --oneline -10` to understand recent commit context
3. For each modified file or group of related files:
   - Run `git diff <file>` to see specific changes
   - Analyze if changes are:
     - **Functional improvements** that extend recent work
     - **Bug fixes** or test fixes related to recent commits
     - **Refactoring** that improves code quality
     - **Temporary debug changes** that should be reverted
     - **Configuration updates** (e.g., .beads files) that may be auto-generated

### Analysis Process:
1. **Group related changes** by functionality or purpose
2. **Connect to recent commits** by examining:
   - Which recent commit(s) these changes relate to
   - Whether they complete unfinished work from a recent commit
   - If they fix issues introduced by recent changes
3. **Suggest commit strategies**:
   - If changes complete recent work: Suggest commit message referencing the original commit
   - If changes fix issues: Suggest fix commit with reference to what it fixes
   - If changes are new improvements: Suggest appropriate feature/enhancement commit
   - For test fixes: Reference which feature/fix they support

### Example Analysis Output:
```
## Uncommitted Changes Analysis

### Group 1: Timezone handling improvements (relates to commit 05b946d)
Files: src/myapp/utils/date_utils.py, tests/unit/utils/test_date.py
Analysis: These changes appear to extend the timezone fixes from commit 05b946d
Suggestion: Commit as "fix: Additional timezone handling improvements for date_utils

            Extends the work from 05b946d to cover additional edge cases"

### Group 2: Test stability improvements (relates to commit 4fd6bd2)
Files: tests/conftest.py, tests/integration/test_premarket_timezone_validation.py
Analysis: Fixes for test reliability issues, continuing work from 4fd6bd2
Suggestion: Commit as "test: Further test stability improvements

            Continues test reliability work from 4fd6bd2"
```

## Phase 2: Review Untracked Files

Categories for untracked files:

1. **Temporary investigation scripts** - Delete these (they served their one-time purpose)
2. **Reusable utilities** - Consider moving to `.claude/skills/<skill-name>/scripts/` or `scripts/`
3. **Migration/deployment artifacts** - User should decide if still needed
4. **Documentation/analysis files** - Review if content should be integrated into existing docs
5. **Data files** - User should decide based on relevance

### Standard Recommendations

#### Delete immediately:
- Scripts with prefixes like `check_*`, `investigate_*`, `verify_*`, `test_*`, `debug_*`
- One-off debugging/investigation tools
- Temporary analysis scripts

#### Review for preservation:
- Migration scripts (e.g., `migrate_*.py`, `backup_*.sh`)
- Data files (e.g., `*.json`, `*.csv`)
- Analysis documentation (e.g., `*_ANALYSIS.md`, `*_INVESTIGATION.md`)

#### Consider moving to appropriate locations:
- Reusable skill utilities → `.claude/skills/<skill-name>/scripts/`
- General utilities → `scripts/`
- Important findings → Integrate into `CLAUDE.md` or relevant docs in `docs/`

## Execution Steps

1. **Phase 1: Uncommitted Changes**
   - Analyze all modified files with `git diff`
   - Review recent git history with `git log --oneline -10`
   - Group related changes and connect to recent commits
   - Present analysis with commit suggestions
   - Ask user which changes to commit and how

2. **Phase 2: Untracked Files**
   - Run `git status --short` to see untracked files
   - Categorize all untracked files
   - Present categorized recommendations
   - Execute approved deletions/moves

3. **Final Status**
   - Show final `git status` to confirm cleanup
   - Summarize actions taken

## Important Notes

- Never delete or commit files without user confirmation
- For uncommitted changes, always provide context from recent commits
- Suggest atomic commits that group related changes
- For markdown files, offer to read and summarize key findings before deletion
- Always preserve functional improvements and test fixes with proper commit messages
- Auto-generated files (.beads/daemon.pid) can usually be ignored or reverted
