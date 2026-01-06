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

## Step 1: Read the Specification

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

---

## Step 2: Ask About Deployment/Validation

**What does deployment/validation look like for this feature?**

Please tell me:
1. **Deployment target**: Where does this deploy? (Cloud Platform, GitHub Actions, CLI tool, API service, Library, Other)
2. **Validation priorities**: What's most important to verify works correctly?
3. **Any existing validation**: Do you have existing validation infrastructure to leverage?

---

## Step 3: Propose Validation Requirements

Based on the specification, I believe you'll need to validate:

*[After reading the spec, I'll list inferred validation needs here]*

For example:
- "Health endpoint responds correctly after deployment"
- "CLI command exits with correct codes"
- "GitHub Action workflow completes successfully"
- "API returns expected responses for key endpoints"
- "Web interface displays correct data"

**Please review this list:**
- Confirm these are the right validation requirements
- Edit or remove any that aren't needed
- Add any I missed

Once you confirm the requirements, I'll research available tools.

---

## Step 4: Research Validation Tools (Subagent)

After you confirm the validation requirements, I'll invoke the validation-researcher agent to:
- Discover tools already installed in your project
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

    Confirmed validation requirements:
    {confirmed_requirements}

    Return ONLY:
    1. Discovered tools (MCP servers, CLIs, SDKs found in project)
    2. Validation recommendations for each requirement:
       - Use existing tool (name, how to use)
       - Install tool (name, install command)
       - Build tool (design sketch with inputs/outputs/API)
    """
)
```

The subagent will return a focused report with recommendations.

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
# Build the validation tool in cc_workflow_tools
/cc_workflow_tools:feature_wf:build-validation-tool "<tool_name>" "<description>"
```

This will:
1. Create a spec for the tool in cc_workflow_tools
2. Run the execute-workflow to implement it
3. Update the validation-expert skill with the new tool
4. Return here to continue

---

## Step 7: Add Validation Phase to Spec

Once validation approaches are selected, I'll add a validation phase to your spec:

```markdown
## Phase [X]: Validation

**Description**: Verify the implementation works correctly in deployment.

**Deployment Type**: [identified type]

**Validation Approach**: [selected approach(es)]

**Validation Steps**:
1. [Step based on selected approach]
2. [Step based on selected approach]
3. [Additional steps as needed]

**Acceptance Criteria**:
- [ ] [Criterion based on validation requirement 1]
- [ ] [Criterion based on validation requirement 2]
- [ ] [Additional criteria as needed]

**Tools Used**:
- [Tool 1]: [purpose]
- [Tool 2]: [purpose]
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
