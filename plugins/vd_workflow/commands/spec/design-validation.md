---
description: Design validation strategy for a specification through Q&A and tool discovery
argument-hint: <spec_file_path>
---

# Design Validation: $ARGUMENTS

I'll help you design a validation strategy for this specification through a guided Q&A process.

## Overview

This command:
1. Analyzes your spec to infer validation needs
2. Asks you to confirm/edit the validation requirements
3. Researches available validation tools (via subagent)
4. Presents recommendations (use existing, install, or build)
5. Adds a validation phase to your spec

---

## Step 1: Read and Analyze the Specification

First, let me read the specification to understand what needs to be validated:

```bash
echo "Reading specification: $1"
cat "$1"
```

I'll analyze the spec for:
- Deployment targets (Cloud Platform, GitHub Actions, CLI, API, etc.)
- User-facing changes that need verification
- Integration points that should be tested
- Acceptance criteria that imply validation needs

**CRITICAL - Data Flow Analysis:**

I'll trace the complete data flow from input to final state:
```
User Action → [Component A] → [Component B] → ... → Final State Change
```

For each **hop** in the flow, I'll identify:
1. What triggers it
2. What state changes occur
3. How to verify it worked

---

## Step 2: Ask About Deployment/Validation

**What does deployment/validation look like for this feature?**

Please tell me:
1. **Deployment target**: Where does this deploy? (Cloud Platform, GitHub Actions, CLI tool, API service, Library, Other)
2. **Validation priorities**: What's most important to verify works correctly?
3. **Any existing validation**: Do you have existing validation infrastructure to leverage?
4. **Real data availability**: Is there real data in the system we can use for validation? (e.g., actual database records, real user scenarios)
5. **E2E scope**: Should validation cover the complete user journey, or just individual components?

**Data Flow Questions:**

Based on the spec, the data flows through these components:
```
[I'll show the data flow diagram here]
```

For each hop:
- Can we verify this step completed?
- What tools could we use? (MCP servers, CLIs, database queries)

---

## Step 3: Propose Validation Requirements

Based on the specification and data flow analysis, I believe you'll need to validate:

### Component-Level Validation
*[After reading the spec, I'll list component validation needs here]*

For example:
- "Health endpoint responds correctly after deployment"
- "CLI command exits with correct codes"
- "GitHub Action workflow completes successfully"

### E2E Validation (True End-to-End)
*[After analyzing data flow, I'll propose E2E scenarios]*

**E2E Philosophy**: Validation should use **real data** and verify **real state changes**:
- Query actual records from the database (not synthetic test data)
- Trigger real user actions (via browser automation if needed)
- Verify actual state changes occurred (database updates, file commits, etc.)

For example (WhatsApp categorization):
- "Query real uncategorized merchants from database"
- "Use Playwright to send WhatsApp message via browser"
- "Verify GitHub Action triggered and completed"
- "Verify new rule committed to repository"
- "Verify transaction category updated in database"

### Verification Points (Per Hop)
*[Based on data flow analysis]*

| Hop | What to Verify | Tool to Use |
|-----|---------------|-------------|
| 1 | [verification] | [tool] |
| 2 | [verification] | [tool] |

**Please review this list:**
- Confirm these are the right validation requirements
- **Is E2E validation appropriate?** (covers full user journey)
- Edit or remove any that aren't needed
- Add any I missed

Once you confirm the requirements, I'll research available tools.

---

## Step 4: Research Validation Tools (Subagent)

After you confirm the validation requirements, I'll invoke the validation-researcher agent to:
- **Discover MCP servers in current session** (not just config files)
- Discover tools already installed in your project
- **Trace the data flow** and identify verification points
- **Design E2E validation scenario** using multiple tools together
- Find tools that could be installed
- Design custom tools if needed

```python
# Subagent invocation pattern
Task(
    description="Research validation options",
    subagent_type="validation-researcher",
    prompt=f"""
    Spec file: {spec_file}
    Deployment type: {deployment_type}

    Data flow:
    {data_flow_diagram}

    Confirmed validation requirements:
    {confirmed_requirements}

    E2E validation needed: {e2e_scope}
    Real data available: {real_data_description}

    Return:
    1. MCP servers available in current session (check for playwright, supabase, etc.)
    2. Project tools (CLIs, test frameworks, etc.)
    3. Data flow analysis with verification points per hop
    4. E2E validation scenario using real data and multiple tools
    5. Tool recommendations for each requirement:
       - Use existing tool (name, how to use)
       - Install tool (name, install command)
       - Build tool (design sketch with inputs/outputs/API)
    """
)
```

The subagent will return a focused report with recommendations including an E2E scenario.

---

## Step 5: Present Recommendations

I'll present the validation-researcher's findings:

### For each validation requirement:

**Option A: Use Existing** (if tool is already available)
- Tool name and how it's already set up
- Usage instructions
- What it validates

**Option B: Install** (if tool can be easily added)
- Tool name
- Installation command
- Usage after install

**Option C: Build Custom** (if custom tool is needed)
- Purpose and design sketch
- Input/output specification
- Suggested API/interface

**Please select your preferred approach for each requirement.**

---

## Step 6: Handle Build Tool (If Needed)

If you select "Build Custom" for any requirement and approve the design:

```bash
# Build the validation tool in vd_workflow
/vd_workflow:spec:build-validation-tool "<tool_name>" "<description>"
```

This will:
1. Create a spec for the tool in vd_workflow
2. Run the execute-workflow to implement it
3. Update the validation-expert skill with the new tool
4. Return here to continue

---

## Step 7: Add Validation Phase to Spec

Once validation approaches are selected, I'll add a validation phase to your spec:

```markdown
## Phase [X]: End-to-End Validation

**Description**: True end-to-end validation using real data, verifying the complete user journey from trigger to final state change.

**Deployment Type**: [identified type]

**Automation Note**: All validation steps should be fully automated. If a step requires manual intervention (e.g., OAuth login, QR code scan), note it explicitly and provide a fallback or skip instruction for automated runs.

**Data Flow**:
```
[Component A] → [Component B] → [Component C] → [Final State]
```

**Validation Approach**:

This validation uses **real data** and verifies **real state changes**:
1. Query real data from the system for test inputs
2. Trigger actual user actions (via browser automation if needed)
3. Verify each hop in the data flow completed
4. Verify final state changes (database, files, etc.)

**For Automated Execution**: Execute all steps sequentially without pausing. If a step fails, log the failure and continue to the next step where possible.

**Validation Steps**:

**Step 1: Get Real Test Data**
```sql
-- Query via [MCP server or CLI]
[Actual query to get real test data]
```

**Step 2: Trigger Action**
- Tool: [Playwright MCP / CLI / etc.]
- Action: [What to do to trigger the flow]

**Step 3: Verify [Hop 1]**
```bash
[Command to verify first hop]
```

**Step 4: Verify [Hop 2]**
```bash
[Command to verify second hop]
```

**Step N: Verify Final State**
```sql
-- Query via [MCP server]
[Query to verify final state change]
```

**Verification Points**:
| Hop | What to Verify | Tool | Expected Result |
|-----|---------------|------|-----------------|
| 1 | [verification] | [tool] | [expected] |
| 2 | [verification] | [tool] | [expected] |

**Tools Used**:
- [MCP Server 1]: [validation purpose]
- [CLI Tool 1]: [validation purpose]
- [MCP Server 2]: [validation purpose]

**Acceptance Criteria**:
- [ ] Real test data obtained from system
- [ ] Action triggered successfully
- [ ] [Hop 1] verified: [what was checked]
- [ ] [Hop 2] verified: [what was checked]
- [ ] Final state change confirmed in [database/files/etc.]
```

I'll edit the spec file to add this phase before the "Clean the House" phase.

---

## Step 8: Update Skill with Learnings

If we discovered new tools or patterns, I'll update the validation-expert skill:

**Project-Specific Discoveries** (added to skill):
```markdown
- **[project-name]**: [tool or pattern discovered]
  - Tool: [name]
  - Usage: [how to use]
  - Discovered: [date]
```

This ensures future specs in this project (or similar projects) benefit from what we learned.

---

## Summary

After completing this command:
- Your spec will have a validation phase with clear steps
- Validation tools will be identified or built
- The validation-expert skill will be updated with any new learnings

The validation phase will be executed during `/implement-phase` along with other spec phases.

---

Ready to design validation for: **$1**
