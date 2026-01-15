---
description: Review specification for design improvements and architectural alignment
argument-hint: <spec_path> <test_spec_path> [--auto-apply]
---

# Spec Review - Design

Review a specification and its test specification for design improvements and architectural alignment.

## Arguments

- spec_path: Path to the specification file (use @ for file suggestions)
- test_spec_path: Path to the test specification file (use @ for file suggestions)
- --auto-apply: (Optional) Enable intelligent auto-apply mode for automated workflows

## Usage

```bash
# Manual mode - prompts for user decision
/execute-wf:spec-review-design @specs/2025-01-08_weather_api_integration.md @specs/tests_2025-01-08_weather_api_integration.md

# Auto-apply mode - automatically applies safe recommendations
/execute-wf:spec-review-design @specs/2025-01-08_weather_api_integration.md @specs/tests_2025-01-08_weather_api_integration.md --auto-apply
```

You can type `/execute-wf:spec-review-design @` and Claude will provide file path suggestions as you type.

## Description

This command performs **Phase 1: Design Review** of both a specification file and its test specification. This should be run after completing `/spec-simplify`.

### Phase 1: Design Review
Reviews both spec and test spec for fundamental design improvements:
1. **Simplify Design**: Identify overly complex approaches and suggest simpler alternatives
2. **Pythonic Patterns**: Recommend Python-specific patterns and libraries (stdlib and 3rd party)
3. **Architecture Alignment**: Find opportunities to reuse existing code or align with current patterns
4. **Conciseness**: Suggest ways to make each spec more focused and actionable

#### Output
This phase returns a structured review across both spec and test spec with numbered sections:
- **Section 1 - Simplification Opportunities**: Specific suggestions to reduce complexity
- **Section 2 - Pythonic Improvements**: Better ways to leverage Python features
- **Section 3 - Reuse Opportunities**: Existing code that could be leveraged
- **Section 4 - Recommended Libraries**: Python packages that could simplify implementation

#### User Interaction

**Manual Mode (Default):**
After presenting Phase 1 recommendations, ask if the user wants to:
- Accept all recommendations and update both spec files
- Discuss specific items individually (with confirmation after each change)
- Proceed to Phase 2 without changes

**Auto-Apply Mode (`--auto-apply` flag):**
Automatically applies safe recommendations, pauses only for architectural decisions.

**Note**: This command performs Phase 1 (Design Review) only. After completing this phase, use `/spec-review-implementation` to perform Phase 2 (Implementation Review) which focuses on implementation clarity and technical decisions.

## Process Flow

### Manual Mode (Default)
1. **Present Design Recommendations**: Show all Phase 1 findings with numbered sections
2. **User Choice**: Accept all (via `/take-recommendations`), discuss individually, or skip
3. **Update Files**: Apply changes to both spec and test spec files based on user feedback
4. **Phase 1 Complete**: Design Review finished, git history tracks all changes

### Auto-Apply Mode (`--auto-apply` flag)
1. **Present Design Recommendations**: Show all Phase 1 findings with numbered sections
2. **Intelligent Recommendation Filtering**:
   - **Auto-Apply**: Recommendations aligned with `shared_docs/PATTERNS.md` and existing architecture
     - Pythonic improvements (dataclasses, type hints, context managers)
     - Using existing module patterns
     - Leveraging stdlib features
     - Established libraries already in use (e.g., requests, typer)
     - Simplifications that reduce complexity
   - **Ask User**: Recommendations requiring approval
     - New architectural patterns
     - New external dependencies (libraries not yet in codebase)
     - Breaking API changes
     - Major refactoring
3. **Apply Auto-Recommendations**: Use `/execute-wf:take-recommendations sections: X, Y, Z` to apply safe recommendations
4. **Present Remaining Items**: Show only recommendations that need user discussion
5. **User Choice for Remaining Items**: Accept all remaining (via `/take-recommendations`), discuss individually, or skip
6. **Update Files**: Apply remaining changes based on user feedback
7. **Phase 1 Complete**: Design Review finished, git history tracks all changes

**Next Step**: Run `/spec-review-implementation` for Phase 2 (Implementation Review)

## Focus Areas

The review focuses on:
- Using Python's built-in features effectively (dataclasses, context managers, etc.)
- Leveraging existing libraries instead of reinventing wheels
- Identifying patterns in the current codebase that could be reused
- Simplifying architectural decisions where possible
- Ensuring the spec is actionable and not over-engineered
- Clarifying implementation details and technical decisions

## Output Format

Phase 1 will present structured recommendations with numbered sections (1-4):
- **Section Number**: Sequential numbering for easy reference (e.g., "Section 1", "Section 2")
- **Category**: Which review area the recommendation addresses
- **Current Approach**: What the spec currently describes
- **Recommended Change**: Specific suggestion for improvement
- **Rationale**: Why this change would be beneficial
- **Impact**: How this affects other parts of the spec or implementation

## Change Tracking

All design improvements are tracked via git commits created by `/execute-wf:take-recommendations`:
- Each applied section creates a separate commit
- Commit message format: "Apply spec review recommendation from section X"
- Section numbering continues from spec-simplify phase
- View changes: `git log --oneline` to see all improvements applied
- Detailed history: `git show <commit-sha>` to see specific changes

This provides a complete audit trail of design decisions, without needing separate bead documentation.
