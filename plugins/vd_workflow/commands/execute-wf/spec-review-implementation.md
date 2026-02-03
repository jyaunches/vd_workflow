---
description: Review specification for implementation clarity and technical decisions
argument-hint: <spec_dir> [--auto-apply]
---

# Spec Review - Implementation

Review a specification and its test specification for implementation clarity and technical decisions using intelligent filtering.

## Arguments

- spec_dir: Path to the spec directory containing spec.md and tests.md
- --auto-apply: (Optional) Enable intelligent auto-apply mode for automated workflows

## Usage

```bash
# Manual mode - prompts for user decision
/execute-wf:spec-review-implementation @specs/2025-01-08_weather_api_integration/

# Auto-apply mode - automatically applies safe implementation decisions
/execute-wf:spec-review-implementation @specs/2025-01-08_weather_api_integration/ --auto-apply
```

**Internal Path Resolution:**
- Spec file: `<spec_dir>/spec.md`
- Test spec file: `<spec_dir>/tests.md`

You can type `/execute-wf:spec-review-implementation @` and Claude will provide directory suggestions as you type.

## Description

This command performs **Phase 2: Implementation Review** - a detailed analysis of implementation clarity and technical decisions. This should be run after completing `/spec-review` (Phase 1: Design Review).

### Locate PATTERNS.md

Before starting the review, locate the project's PATTERNS.md file using this fallback order:

1. **Repo-local**: `shared_docs/PATTERNS.md` (project customization)
2. **Plugin default**: `~/Development/vd_workflow/plugins/vd_workflow/shared_docs/PATTERNS.md`

Read the PATTERNS.md file to understand which implementation decisions align with project standards and can be auto-applied. If no PATTERNS.md is found, use conservative defaults (only auto-apply decisions that match existing codebase patterns).

### Implementation Review Focus Areas

Reviews both spec and test spec for implementation clarity:
1. **Implementation Questions**: Highlight areas that need clarification before implementation
2. **Test Coverage Gaps**: Identify missing test scenarios or unclear test requirements
3. **Phase Alignment**: Ensure test phases align properly with implementation phases

### Output Format

Each Implementation Question is presented in a structured table format with section numbering (starting at Section 5 to continue from Phase 1):

**Section X - Question: [Clear statement of what needs to be decided]**

| Option | Description | Benefits | Tradeoffs | Complexity |
|--------|-------------|----------|-----------|------------|
| A | Brief description | Key benefit summary | Main tradeoff summary | Low |
| B | Brief description | Key benefit summary | Main tradeoff summary | Medium |
| C | Brief description | Key benefit summary | Main tradeoff summary | High |

**💡 Recommendation:** Option [X] - [Clear reasoning with specific benefits]

**Additional Details:**
- **Option A Benefits:** • Benefit 1 • Benefit 2
- **Option A Tradeoffs:** • Tradeoff 1 • Tradeoff 2
- **Option B Benefits:** • Benefit 1 • Benefit 2
- **Option B Tradeoffs:** • Tradeoff 1 • Tradeoff 2

This format provides a clean overview table followed by detailed breakdowns for better terminal readability.

## Process Flow

### Manual Mode (Default)
1. **Present Implementation Questions**: Show all findings with numbered sections (continuing from Phase 1 numbering)
2. **User Choice**: Accept all recommendations (via `/take-recommendations`), discuss individually, or skip
3. **Update Files**: Apply decisions to both spec and test spec files based on user feedback
4. **Phase 2 Complete**: Implementation Review finished, git history tracks all decisions

### Auto-Apply Mode (`--auto-apply` flag)
1. **Present Implementation Questions**: Show all findings with numbered sections (continuing from Phase 1 numbering)
2. **Intelligent Recommendation Filtering**:
   - **Auto-Apply**: Implementation decisions aligned with `shared_docs/PATTERNS.md` (examples):
     - Existing implementation patterns in codebase
     - Simple and consistent approaches
     - Performance optimizations within existing architecture
     - Standard error handling patterns
     - Conventional naming and structure
   - **Ask User**: Decisions requiring discussion
     - New architectural patterns
     - API design choices
     - Data structure decisions
     - Complexity vs simplicity tradeoffs
     - Breaking changes to existing interfaces
     - Technology/library choices
3. **Apply Auto-Recommendations**: Use `/execute-wf:take-recommendations sections: X, Y, Z` to apply safe decisions
4. **Present Remaining Items**: Show only implementation questions that need user input
5. **User Choice for Remaining Items**: Accept all remaining (via `/take-recommendations`), discuss individually, or skip
6. **Update Files**: Apply remaining decisions based on user feedback
7. **Phase 2 Complete**: Implementation Review finished, git history tracks all decisions

## Focus Areas

The review focuses on:
- Clarifying ambiguous implementation details
- Identifying technical decisions that need to be made
- Ensuring test coverage is comprehensive
- Verifying phase alignment between spec and test spec
- Following pythonic and best practice approaches
- Maintaining consistency with existing codebase patterns

## Change Tracking

All implementation decisions are tracked via git commits created by `/execute-wf:take-recommendations`:
- Each applied section creates a separate commit
- Commit message format: "Apply spec review recommendation from section X"
- Section numbering continues from Phase 1 (Design Review)
- View changes: `git log --oneline` to see all decisions applied
- Detailed history: `git show <commit-sha>` to see specific changes

This provides a complete audit trail of implementation decisions and test coverage additions, without needing separate bead documentation.

## Continuation from Phase 1

**Important**: Section numbering continues sequentially from Phase 1 (Design Review). For example:
- Phase 1 sections: 1-4
- Phase 2 sections: 5, 6, 7, etc.

This allows seamless use of `/take-recommendations` across both review phases.
