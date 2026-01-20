---
description: Design validation strategy for a specification through Q&A
argument-hint: <spec_file_path>
---

# Design Validation: $ARGUMENTS

I'll help you design a validation strategy for this specification through a guided Q&A process.

## Overview

This command:
1. Analyzes your spec to understand what needs validation
2. Discovers available validation tools in your session
3. Asks about your validation approach and confirms tools to use
4. Designs validation steps and adds them to your spec

---

## Step 1: Read and Analyze the Specification

First, let me read the specification:

```bash
cat "$1"
```

I'll identify:
- What the feature does
- Key acceptance criteria
- Integration points that need verification

---

## Step 2: Discover Available Validation Tools

I'll check what validation tools are available in this session.

**Checking for MCP servers in current session:**

Look for available MCP tools with patterns like:
- `mcp__playwright__*` - Browser automation, UI testing, web interactions
- `mcp__supabase__*` - Database queries, state verification
- `mcp__github__*` - GitHub operations, PR checks, workflow status

**Checking project tools:**
```bash
# Check for test frameworks and CLIs
cat package.json 2>/dev/null | grep -E "(playwright|puppeteer|cypress|jest)" || true
grep -E "(pytest|httpx|playwright)" pyproject.toml 2>/dev/null || true
ls .github/workflows/*.yml 2>/dev/null || true
```

**I'll report what tools I found before proceeding.**

---

## Step 3: Ask About Validation Approach

**Please tell me about your validation needs:**

1. **What needs to be validated?**
   - What's the most important thing to verify works correctly?
   - Should we validate the full user journey (E2E) or just specific components?

2. **What tools do you have available?**
   - MCP servers in your session (e.g., Playwright, Supabase, GitHub)
   - CLIs or SDKs installed in your project
   - Test frameworks you're using

3. **How should validation work?**
   - Manual steps vs fully automated
   - Real data vs synthetic test data
   - Any authentication or setup required

**Example response:**
> "Validate that the API endpoint returns correct data. Use the Supabase MCP to query the database and curl to hit the endpoint. Should be fully automated with real data from the dev database."

---

## Step 4: Confirm Validation Tools

Based on my discovery and your input, here are the tools I'll use for validation:

**Tools I found in this session:**
- [I'll list the MCP servers and tools I discovered]

**Tools I recommend for this validation:**
- [Tool 1]: [why/how it will be used for this feature]
- [Tool 2]: [why/how it will be used for this feature]

**Please confirm these tools are correct, or tell me what else to use.**

Once confirmed, I'll design the validation steps using these specific tools.

---

## Step 5: Design Validation Steps

Based on your input, I'll propose specific validation steps.

For each step I'll specify:
- **What to verify**: The specific check
- **Tool to use**: MCP server, CLI, or command
- **Expected result**: What success looks like

**Example:**
```
Step 1: Query test data
- Tool: Supabase MCP
- Query: SELECT * FROM users WHERE test_account = true LIMIT 1

Step 2: Call API endpoint
- Tool: curl
- Command: curl -X GET "https://api.example.com/users/{id}"
- Expected: 200 response with user data

Step 3: Verify response
- Check: Response contains expected fields
- Expected: name, email, created_at present
```

**Please review and adjust the steps as needed.**

---

## Step 6: Add Validation Phase to Spec

Once you approve the validation steps, I'll add a validation phase to your spec:

```markdown
## Phase [N]: Validation

<!-- VALIDATION_PHASE -->

**Description**: Verify the feature works correctly end-to-end using the confirmed validation tools.

**Tools**: [List confirmed tools - e.g., Playwright MCP, Supabase MCP, curl]

**Validation Steps**:

1. **[Step name]**
   - Tool: [specific tool from confirmed list]
   - Action: [what to do]
   - Expected: [result]

2. **[Step name]**
   - Tool: [specific tool from confirmed list]
   - Action: [what to do]
   - Expected: [result]

**Execution Instructions**:

When executing this validation phase, Claude MUST:
1. Execute each validation step using the specified tools
2. If a validation step fails or issues are found:
   - Identify the root cause
   - Fix the issue in the implementation
   - Re-run the validation step
   - Continue this loop until the step passes
3. Only mark this phase complete when ALL validation steps pass
4. Report any issues that could not be resolved

**Acceptance Criteria**:
- [ ] All validation steps executed with specified tools
- [ ] Any issues found were fixed and re-validated
- [ ] Feature confirmed working end-to-end
```

I'll add this phase before the "Clean the House" phase in your spec.

---

## Summary

After completing this command:
- Your spec will have a validation phase with clear, executable steps
- Validation tools have been discovered and confirmed
- The validation phase includes execution loop instructions for Claude to:
  - Use the confirmed tools to validate the feature
  - Fix any issues found and re-validate
  - Loop until all validation passes

---

Ready to design validation for: **$1**
