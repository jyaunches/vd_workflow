---
description: Review and approve validation plan before execution
argument-hint: <spec_dir>
---

# Validation Review: $ARGUMENTS

I'll present the validation plan for your review and approval before implementation begins.

**Internal Path Resolution:**
- Validation plan: `<spec_dir>/validation.md`

---

## Step 1: Read Validation Plan

```bash
SPEC_DIR="${1%/}"
VALIDATION_FILE="$SPEC_DIR/validation.md"

echo "=== Validation Plan ==="
cat "$VALIDATION_FILE"
```

---

## Step 2: Present Coverage Summary

I'll extract and present the key metrics from the validation plan:

### Coverage Summary

| Metric | Count |
|--------|-------|
| **Happy Paths** | X scenarios |
| **Sad Paths** | Y scenarios |
| **Total** | Z scenarios |

### Scenarios by Phase

| Phase | Happy | Sad | Total |
|-------|-------|-----|-------|
| Phase 1: Name | X | Y | Z |
| Phase 2: Name | X | Y | Z |
| ... | ... | ... | ... |

### Tools Required

- Tool 1: Used for X scenarios
- Tool 2: Used for Y scenarios
- ...

---

## Step 3: User Review

**Please review the validation plan and confirm:**

> **Review Checklist:**
> - [ ] All critical user flows are covered (happy paths)
> - [ ] Obvious failure modes are tested (sad paths)
> - [ ] No missing edge cases that should be validated
> - [ ] Tools specified are available and appropriate
> - [ ] Scenarios are executable (not vague or impossible)

### Review Options

I'll ask you to choose how to proceed:

1. **Approve as-is** - The validation plan is complete and ready
2. **Add scenarios** - Specify additional scenarios to include
3. **Remove scenarios** - Identify scenarios that are unnecessary or duplicative
4. **Modify scenarios** - Request changes to specific scenarios
5. **Regenerate** - Start over with different focus or constraints

---

## Step 4: Handle User Feedback

### If "Approve as-is"

Commit the approved validation plan and continue:

```bash
git add "$VALIDATION_FILE"
git commit -m "Approve validation plan for $(basename $SPEC_DIR)"
```

### If "Add scenarios"

I'll ask for details:
- Which phase should the scenario belong to?
- Happy path or sad path?
- What's the scenario name?
- Given/When/Then description?
- Which tools should be used?

Then update the validation plan and re-present for approval.

### If "Remove scenarios"

I'll ask which scenario IDs to remove (e.g., "1.3, 2.1").

Then update the validation plan and re-present for approval.

### If "Modify scenarios"

I'll ask which scenario to modify and what changes to make.

Then update the validation plan and re-present for approval.

### If "Regenerate"

I'll ask for guidance on what to change:
- Focus on specific phases?
- Add more sad paths?
- Use different tools?
- Simplify scope?

Then run `/execute-wf:validation-plan` again with adjusted parameters.

---

## Step 5: Final Approval

Once you approve the validation plan:

```markdown
## Validation Plan Approved

**Spec Directory**: <spec_dir>
**Validation Plan**: <spec_dir>/validation.md

**Coverage**:
- Happy Paths: X
- Sad Paths: Y
- Total: Z scenarios

**Status**: APPROVED - Ready for implementation

**Next Steps**:
1. Implementation phase will proceed
2. After implementation completes, validation-executor will run these scenarios
3. Failed scenarios trigger /bug --auto (up to 3 attempts)
4. Passed scenarios get [VALIDATED: sha] markers
```

---

## Important Notes

### Why User Review Matters

- **Coverage completeness**: You know your feature better than automated generation
- **Tool availability**: Confirm the tools are actually accessible in your environment
- **Priority alignment**: Ensure critical paths are covered, not just obvious ones
- **Feasibility check**: Some scenarios may be impossible to execute automatically

### What Good Feedback Looks Like

**Good**: "Add a scenario for when the database connection times out during save"
**Good**: "Remove scenario 2.3 - that's already covered by unit tests"
**Good**: "Modify 1.2 to use Playwright instead of curl since it needs browser auth"

**Not Helpful**: "Add more tests" (too vague)
**Not Helpful**: "This looks fine" (no actual review)

### When to Add More Scenarios

- Critical business logic that must work
- Data integrity concerns
- Security-sensitive operations
- User-facing error messages
- Integration points with external systems

### When to Remove Scenarios

- Already covered by unit tests
- Duplicate of another scenario
- Impossible to execute with available tools
- Tests implementation details, not behavior

---

**Presenting validation plan for review**: $ARGUMENTS
