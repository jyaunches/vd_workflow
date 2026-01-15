---
description: Review specification for unnecessary complexity and over-engineering
argument-hint: <spec_path> [test_spec_path] [--auto-apply]
---

# Spec Simplify

Review a specification for unnecessary complexity and over-engineering. This is a **simplification-only pass** that runs before the full spec-review.

## Arguments

- spec_path: Path to the specification file (use @ for file suggestions)
- test_spec_path: (Optional) Path to the test specification file (use @ for file suggestions)
- --auto-apply: (Optional) Enable intelligent auto-apply mode for automated workflows

## Usage

```bash
# Manual mode - prompts for user decision
/execute-wf:spec-simplify @specs/2025-10-31_22-00_cli-analyze-intraday-impact.md

# Auto-apply mode - automatically applies safe recommendations
/execute-wf:spec-simplify @specs/2025-10-31_22-00_cli-analyze-intraday-impact.md --auto-apply

# With test spec
/execute-wf:spec-simplify @specs/2025-10-31_22-00_cli-analyze-intraday-impact.md @specs/tests_2025-10-31_cli-analyze-intraday-impact.md --auto-apply
```

You can type `/execute-wf:spec-simplify @` and Claude will provide file path suggestions as you type.

## Description

This command performs a **ruthless simplification review** focused on removing unnecessary complexity, future-proofing, and over-engineering. The mindset is: **ship the simplest thing that works**.

### Core Principles

1. **No Future-Proofing**: Remove features "for later" or "just in case"
2. **No Backward Compatibility**: Unless explicitly required, don't support old patterns
3. **Simplest Testing**: Prefer simple, direct tests over comprehensive test frameworks
4. **Minimal Abstractions**: Only abstract when you have 3+ concrete cases
5. **Delete Before Add**: Look for things to remove, not add

## Review Checklist

The review examines these specific areas:

### 1. Future-Proofing Check
**Look for:**
- Features marked "future enhancement" but included in phases
- Extensibility hooks with no current use case
- Configuration for options that don't exist yet
- Generic solutions for a single concrete case
- "What if we need to..." thinking

**Action:** Remove or move to "Future Enhancements" section

### 2. Backward Compatibility Check
**Look for:**
- Supporting old and new patterns simultaneously
- Deprecation paths for code that can just be replaced
- "For compatibility with..." justifications
- Migration helpers for internal refactors

**Action:** Remove. Direct replacement is fine for internal code.

### 3. Testing Complexity Check
**Look for:**
- Complex mock hierarchies (3+ levels deep)
- Test fixtures that set up entire systems
- Parametrized tests that could be 2-3 simple tests
- Testing implementation details instead of behavior
- Separate test files for each small utility

**Action:** Simplify to direct, behavior-focused tests

### 4. Architecture Over-Engineering Check
**Look for:**
- Interfaces/protocols with only one implementation
- Factory patterns for creating simple objects
- Strategy patterns for 2 options (use if/else)
- Builder patterns for objects with <5 fields
- Multiple layers of indirection

**Action:** Use direct, simple implementations

### 5. Premature Abstraction Check
**Look for:**
- Base classes with one subclass
- Shared utilities used in one place
- Extracted functions called once
- "DRY" applied to code that's similar but not identical

**Action:** Inline or keep concrete until 3rd use case appears

### 6. Configuration Bloat Check
**Look for:**
- Config options with one valid value
- Env vars for hardcoded decisions
- Feature flags for code not yet written
- Settings that could be constants

**Action:** Remove config, use constants or code

### 7. Documentation Overhead Check
**Look for:**
- Docstrings for obvious functions
- Architecture diagrams for simple flows
- Multiple spec files for one feature
- Section headers with no content

**Action:** Remove or consolidate

## Output Format

Present findings in numbered sections with specific actionable recommendations:

### Section X: [Area] - Remove [What]

**Current Approach:**
[Quote or summary from spec]

**Why This Is Complexity:**
- Reason 1: [Specific YAGNI violation]
- Reason 2: [Specific over-engineering pattern]

**Simplified Approach:**
[Concrete, simpler alternative]

**What to Delete:**
- Phase sections to remove
- Test cases to remove
- Configuration to remove
- Abstractions to remove

**Impact:**
- Lines of code saved: ~X
- Test cases saved: ~X
- Concepts removed: [list]

---

## Decision Points

For each simplification, explicitly note:
- **Risk Level**: Low/Medium/High (if removing this causes problems)
- **Recovery Cost**: How hard to add back if needed later
- **Recommendation Strength**: Remove / Consider Removing / Discuss

## Process Flow

1. **Read Both Specs**: Analyze spec and test spec together
2. **Identify Complexity**: Flag all instances from checklist
3. **Categorize**: Group by impact (high-value simplifications first)
4. **Present All Findings**: Show complete simplification report
5. **User Decision**:
   - Accept all simplifications
   - Discuss individually
   - Reject and proceed to full review
6. **Update Files**: Apply approved simplifications
7. **Summary**: Report what was removed and simplified

## What This Review Does NOT Cover

This review focuses ONLY on simplification. It does not:
- Suggest better patterns (that's spec-review Phase 1)
- Answer implementation questions (that's spec-review Phase 2)
- Review code (that's post-impl-review)
- Check test coverage completeness (that's spec-review Phase 2)

**Next Step**: After simplification, run `/spec-review` for design patterns and implementation clarity.

## Example Output

```
### Section 1: Phase Structure - Remove "Output Format" Abstraction

**Current Approach:**
Spec includes formatter interface with multiple output formats (formatted text, JSON)
and suggests --json flag as future enhancement but includes JSON serialization in Phase 2.

**Why This Is Complexity:**
- YAGNI: JSON output is explicitly marked "future enhancement" but Phase 2 includes to_dict()
- Single concrete case: Only formatted text is needed now
- False abstraction: "Output format" is an interface for one implementation

**Simplified Approach:**
Remove all JSON/to_dict() mentions. Just format as text directly.
If JSON is needed later (unlikely for a debugging CLI), add it then.

**What to Delete:**
- Phase 2: Remove to_dict() serialization logic
- Test Spec Phase 2: Remove test_should_serialize_to_json
- Architecture: Remove "OutputFormatter" interface concept
- Use simple function: format_analysis_report(analysis) -> str

**Impact:**
- Lines of code saved: ~50
- Test cases saved: 3
- Concepts removed: OutputFormatter abstraction, serialization layer
- Risk Level: Low (JSON not in requirements)
- Recovery Cost: Low (add to_dict() takes 30 min if actually needed)

**Recommendation Strength:** Remove
```

## User Interaction

### Manual Mode (Default)

After presenting all simplification recommendations:

> I found X simplifications that could reduce complexity by ~Y lines of code and Z concepts.
>
> Would you like to:
> 1. **Accept all** - Apply all simplifications and update both spec files
> 2. **Review individually** - Discuss each recommendation one by one
> 3. **Skip simplification** - Keep specs as-is and proceed to full spec-review
>
> Your choice?

If user chooses "Review individually":
- Present recommendations in order of impact (highest value first)
- For each: "Accept this simplification? (yes/no/discuss)"
- Track accepted vs. rejected
- Apply changes incrementally

### Auto-Apply Mode (`--auto-apply` flag)

When `--auto-apply` flag is present, use intelligent filtering:

**Step 1: Categorize Recommendations**

For each recommendation, determine category:

**Auto-Apply** (align with `shared_docs/PATTERNS.md` and existing architecture):
- Removing YAGNI features (future-proofing, "just in case" code)
- Removing premature abstractions (base class with one subclass, single-use utilities)
- Simplifying tests (reducing mock complexity, parametrized → simple tests)
- Removing config bloat (env vars with one valid value)
- Removing documentation overhead (docstrings for obvious functions)
- Following existing module patterns (matching current file structure)
- Using established testing patterns (matching existing test organization)
- Configuration consolidation (using existing config patterns)

**Needs User Approval**:
- Architectural changes (new module structure, layer reorganization)
- Breaking API changes (signature changes, interface modifications)
- New external dependencies (libraries, services not yet in codebase)
- Major refactoring (changing core abstractions)
- Removing features explicitly requested by user

**Step 2: Auto-Apply Safe Recommendations**

For recommendations in "Auto-Apply" category:
- Collect section numbers for auto-applicable simplifications
- Use `/execute-wf:take-recommendations sections: X, Y, Z` to apply them
- Each section creates a git commit tracking the change

**Step 3: Present Remaining Recommendations**

If recommendations remain in "Needs User Approval" category:
> **Auto-Applied Simplifications:** Sections 1, 2, 4, 6 via `/take-recommendations`
> (removed ~120 LOC, 5 concepts)
>
> **Remaining Recommendations Needing Approval:**
>
> [Present only the recommendations that need user input]
>
> Would you like to:
> 1. **Accept all remaining** - Apply architectural/breaking changes via `/take-recommendations`
> 2. **Review individually** - Discuss each one
> 3. **Skip remaining** - Keep these as-is and proceed
>
> Your choice?

If ALL recommendations are auto-applied (none need approval):
> **Auto-Applied All Simplifications:** Sections 1-6 via `/take-recommendations`
> (removed ~165 LOC, 8 concepts)
>
> All recommendations aligned with `shared_docs/PATTERNS.md` and existing architecture.
> Git history contains individual commits for each simplification.

## Success Metrics

A successful simplification pass should:
- Remove at least 3 unnecessary abstractions
- Cut at least 20% of test cases (by simplifying test approach)
- Eliminate all future-proofing in current phases
- Remove all backward compatibility support (unless explicitly required)
- Result in a spec that can be implemented in fewer lines of code

## Anti-Patterns to Catch

Specific patterns that almost always indicate over-engineering:

1. **"Extensible Architecture"** - with one extension
2. **"Flexible Configuration"** - with one valid value
3. **"Comprehensive Test Coverage"** - testing getters/setters
4. **"Future-Proof Design"** - solving problems you don't have
5. **"Enterprise Patterns"** - AbstractFactoryFactory for a 100-line CLI
6. **"Clean Architecture"** - 5 layers for CRUD operations
7. **"Defensive Programming"** - validating impossible states
8. **"Backward Compatible"** - for code no one uses yet

## Red Flags in Specs

Phrases that indicate complexity to review:

- "To support future..."
- "For extensibility..."
- "To maintain backward compatibility..."
- "Just in case..."
- "This allows for..."
- "To make it easy to add..."
- "Following SOLID principles..."
- "Using the Strategy/Factory/Builder pattern..."
- "Comprehensive test suite..."
- "Abstract base class for..."

When you see these, ask: **Do we need this NOW for THIS feature?**
If no, remove it.

## Change Tracking

All simplification changes are tracked via git commits created by `/execute-wf:take-recommendations`:
- Each applied section creates a separate commit
- Commit message format: "Apply spec review recommendation from section X"
- View changes: `git log --oneline` to see all simplifications applied
- Detailed history: `git show <commit-sha>` to see specific changes

This provides a complete audit trail of what was simplified and why, without needing separate bead documentation.
