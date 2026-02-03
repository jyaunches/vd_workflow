---
description: Review specification for unnecessary complexity and over-engineering
argument-hint: <spec_dir> [--auto-apply]
---

# Spec Simplify

Review a specification for unnecessary complexity. This is a **simplification-only pass** before the full spec-review.

## Arguments

- spec_dir: Path to the spec directory containing spec.md
- --auto-apply: Auto-apply safe recommendations

**Path Resolution:**
- Spec file: `<spec_dir>/spec.md`
- Test spec file (if exists): `<spec_dir>/tests.md`

## Core Principles

1. **No Future-Proofing** - Remove "for later" or "just in case" features
2. **No Backward Compatibility** - Unless explicitly required
3. **Simplest Testing** - Direct tests over comprehensive frameworks
4. **Minimal Abstractions** - Only abstract at 3+ concrete cases
5. **Delete Before Add** - Look for things to remove

## Review Checklist

| Area | Look For | Action |
|------|----------|--------|
| **Future-Proofing** | "future enhancement" in phases, extensibility hooks with no use case, config for non-existent options | Remove or move to Future Enhancements |
| **Backward Compat** | Supporting old+new simultaneously, deprecation paths, migration helpers | Remove. Direct replacement is fine. |
| **Testing Complexity** | Mock hierarchies 3+ deep, fixtures setting up entire systems, parametrized tests that could be 2-3 simple tests | Simplify to behavior-focused tests |
| **Architecture** | Interfaces with one implementation, Factory/Strategy/Builder patterns for simple cases | Use direct implementations |
| **Premature Abstraction** | Base classes with one subclass, utilities used in one place, "DRY" on similar-but-different code | Inline until 3rd use case |
| **Config Bloat** | Config with one valid value, env vars for hardcoded decisions, feature flags for unwritten code | Remove, use constants |
| **Documentation** | Docstrings for obvious functions, architecture diagrams for simple flows | Remove or consolidate |

## Output Format

```markdown
### Section X: [Area] - Remove [What]

**Current Approach:** [Quote from spec]

**Why This Is Complexity:**
- [YAGNI violation]
- [Over-engineering pattern]

**Simplified Approach:** [Concrete alternative]

**What to Delete:**
- [Phase sections, test cases, config, abstractions]

**Impact:**
- Lines saved: ~X
- Concepts removed: [list]
- Risk: Low/Medium/High
- Recovery cost: Low (add back in X min if needed)

**Recommendation:** Remove / Consider Removing / Discuss
```

## Process Flow

1. Read spec and tests.md (if exists)
2. Identify complexity from checklist
3. Present findings (highest impact first)
4. User decision: Accept all / Review individually / Skip
5. Apply approved changes via `/execute-wf:take-recommendations`
6. Report what was simplified

### Auto-Apply Mode (`--auto-apply`)

**Auto-apply** (align with PATTERNS.md):
- YAGNI removals, premature abstractions, test simplification, config bloat, documentation overhead

**Needs approval**:
- Architectural changes, breaking APIs, new dependencies, major refactoring

## Red Flags in Specs

Phrases that indicate complexity to review:
- "To support future...", "For extensibility...", "Just in case..."
- "Following SOLID principles...", "Using the Strategy/Factory pattern..."
- "Comprehensive test suite...", "Abstract base class for..."

Ask: **Do we need this NOW for THIS feature?** If no, remove it.

**Next Step**: After simplification, run `/spec-review` for design patterns and implementation clarity.
