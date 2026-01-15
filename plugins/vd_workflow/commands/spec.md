---
description: Create a new specification file for the project
argument-hint: <feature_name> "<description>"
---

# spec

Create a new specification file for the project.

**Usage**: `/vd_workflow:spec <feature_name> "<brief_description>"`

## Create New Specification: $ARGUMENTS

I'll create a comprehensive specification for this feature following this project's standards.

Let me analyze the existing codebase structure and create a specification that integrates directly with the current implementation:

```bash
find specs/ -name "*.md" -type f | head -3
```

```bash
ls -la src/
```

Based on the project's integration philosophy, I'll create a specification that:

## Direct Integration Approach
- **Enhance Existing Code**: Modify current files rather than creating parallel systems
- **No Backward Compatibility**: Unless explicitly requested, new features become default behavior
- **Follow Existing Patterns**: Integrate with current architecture and conventions

## Specification Structure
The specification will include:

1. **Overview & Objectives**: Clear problem statement and goals
2. **Current State Analysis**: What exists vs. what's needed
3. **Architecture Design**: Brief, but thorough description of implementation approach (no code, mermaid charts where appropriate)
4. **Configuration & Deployment Changes**: What configuration and deployment files need updating
   - **Environment Variables**: New variables needed, with descriptions and default values
   - **Dependencies**: New packages in `pyproject.toml`, including extras (e.g., `httpx[http2]`)
   - **Deployment Files to Update**:
     - `.env.example` - Document new variables for other developers
     - `.github/workflows/*.yml` - Add new secrets/env vars to CI/CD
     - Deployment platform config (e.g., `fly.toml`, `render.yaml`, k8s manifests) - Production env vars
     - `Dockerfile` - New system dependencies if needed
   - **Secrets**: New secrets needed in CI/CD or deployment platform
5. **Implementation Phases**: Incremental development phases with integrated acceptance criteria

## Implementation Phases Structure
Each phase must follow this incremental design:

### Phase Design Principles
1. **Incremental**: Phase 1 should be the smallest buildable core functionality
2. **Buildable**: Each phase builds on previous phases
3. **Testable**: Each phase includes comprehensive unit test requirements
4. **Measurable**: Each phase has specific acceptance criteria

### Phase Naming and Formatting Requirements

**CRITICAL**: For `/implement_phase` command compatibility, phases MUST follow this exact format:

#### Phase Headers
- Use markdown headers (# ## ### ####) followed immediately by "Phase" and a colon
- Format: `## Phase 1: [Descriptive Name]` or `### Phase 2: [Descriptive Name]`
- The word "Phase" MUST be present in the header
- Use consistent header levels (recommend ## or ###)

#### Completion Marking
- When completed, append `[COMPLETED: git-sha]` to the phase header
- Example: `## Phase 1: Core Data Structure [COMPLETED: a1b2c3d]`
- The `/implement_phase` command will automatically add this when phases finish

#### Example Phase Headers
```markdown
## Phase 1: Basic Configuration Loading
## Phase 2: Data Validation Layer
## Phase 3: Error Handling and Logging [COMPLETED: f4e5d6c]
```

### Phase Template
For each phase, include:

**Phase X: [Phase Name]**
- **Description**: Brief overview of what this phase accomplishes
- **Core Functionality**: The minimal viable feature set for this phase
- **Dependencies**: What previous phases or existing code this builds on
- **Unit Test Requirements**:

  Tests to Write:

  1. **test_should_create_baseline_calculator_with_config**
     - Input: Config with window_minutes=10
     - Expected: Calculator instance with window=10

- **Acceptance Criteria**:
  - Measurable success conditions
  - Performance requirements (if applicable)
  - User-facing behavior validation

**Note on Testing**: Throughout the spec, mark testable components and behaviors with clear annotations (e.g., "This component should validate...", "Edge case: when X happens..."). These will be used by the test writer agent later. Do NOT include test implementation details or test code - focus only on identifying what needs to be tested.

## Implementation Guidelines
- All code changes integrate directly into existing files
- Follow the project's dataclass and type annotation patterns
- Maintain configurability through environment variables
- Include comprehensive error handling and logging

## Final Phase: Clean the House

Every specification MUST include a final "Clean the House" phase with the following structure:

**Phase [X]: Clean the House**
- **Description**: Post-implementation cleanup and documentation maintenance
- **Tasks**:
  1. **Remove Dead Code**: Identify and remove any code that became obsolete during implementation
  2. **Update README.md**: Update user-facing documentation affected by changes
  3. **Update CLAUDE.md**: Update architecture, patterns, and development commands
  4. **Resolve TODOs**: Address or document any TODOs from implementation
- **Acceptance Criteria**:
  - No commented-out code blocks remain (unless they serve as examples)
  - Documentation reflects current state of implementation
  - All TODOs from implementation are either resolved or documented

**Note**: This phase ensures documentation stays current with code changes.

## File Creation
I'll create the specification file in `specs/` following the naming convention: `YYYY-MM-DD_HH-mm_<feature_name>.md`
- The date prefix uses today's date in YYYY-MM-DD_HH-mm format
- This ensures specs are chronologically ordered by creation date

## Validation Design Phase

After creating the specification file, I'll invoke the validation design command to help you define how to validate this feature works correctly:

```bash
/vd_workflow:spec:design-validation <spec_file_path>
```

This Q&A-driven phase will:
1. Ask about deployment and validation needs
2. Propose validation requirements based on the spec
3. Research available validation tools (MCP servers, CLIs, SDKs)
4. Add a validation phase to your spec

The validation phase ensures your feature can be verified after implementation.

---

Ready to proceed with creating the detailed specification for: **$ARGUMENTS**
