---
description: Design validation strategy for a specification through Q&A
argument-hint: <spec_file_path>
---

# Design Validation: $ARGUMENTS

I'll help you design a validation strategy for this specification through a guided Q&A process.

## Overview

This command:
1. Analyzes your spec to understand what needs validation
2. Asks you about your validation tools and approach
3. Adds a validation phase to your spec

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

## Step 2: Ask About Validation Approach

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

## Step 3: Design Validation Steps

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

## Step 4: Add Validation Phase to Spec

Once you approve the validation steps, I'll add a validation phase to your spec:

```markdown
## Phase [N]: Validation

**Description**: Verify the feature works correctly end-to-end.

**Validation Steps**:

1. **[Step name]**
   - Tool: [tool]
   - Action: [what to do]
   - Expected: [result]

2. **[Step name]**
   - Tool: [tool]
   - Action: [what to do]
   - Expected: [result]

**Acceptance Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

I'll add this phase before the "Clean the House" phase in your spec.

---

## Summary

After completing this command:
- Your spec will have a validation phase with clear, executable steps
- The validation uses tools you've specified
- Steps can be run during `/execute-wf` implementation

---

Ready to design validation for: **$1**
