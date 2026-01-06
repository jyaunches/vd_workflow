---
description: Post-feature due diligence check for documentation and deployment configuration
---

# Post-Feature Due Diligence Check

Perform comprehensive validation after implementing a feature to ensure documentation and deployment configurations are up-to-date.

## Objectives

1. **Documentation Validation**: Audit all project documentation for accuracy and completeness
2. **Deployment Configuration**: Verify GitHub workflows and deployment configuration have necessary environment variables and settings

## Documentation Audit

### Scope
Review the following documentation files:
- `README.md` - Service overview, quick start, API endpoints, configuration
- `CLAUDE.md` - Development instructions, architecture patterns, service-specific notes
- `docs/**/*.md` - Any additional documentation in docs directory (if exists)
- `INTEGRATION.md` - Integration examples and client code (if exists)
- `.env.example` - Environment variable templates

### Audit Process

For each documentation file, evaluate:

1. **Accuracy Check**
   - Does documentation reflect current implementation?
   - Are there outdated references to removed features?
   - Are new features/capabilities documented?
   - Do code examples still work?
   - Are API endpoint descriptions current?

2. **Completeness Check**
   - Are new environment variables documented?
   - Are new configuration options explained?
   - Are new API endpoints listed?
   - Are integration points with other services documented?
   - Are new dependencies mentioned?

3. **Removal Recommendations**
   - Identify outdated sections that should be removed
   - Flag deprecated instructions
   - Highlight stale examples

4. **Addition Recommendations**
   - Suggest new sections needed for recent features
   - Recommend clarifications for complex changes
   - Propose examples for new functionality

### Output Format

For each file, provide:

```markdown
## Documentation Audit: [filename]

### Current State
- Brief description of file's current content

### Issues Found
- [ ] **Outdated**: [Description of outdated content]
- [ ] **Missing**: [Description of missing documentation]
- [ ] **Incorrect**: [Description of incorrect information]

### Recommendations
1. **Remove**: [Specific sections/content to remove]
2. **Update**: [Specific sections to update with proposed changes]
3. **Add**: [New sections to add with brief outline]

### Priority: [High/Medium/Low]
```

## Deployment Configuration Audit

### Scope
Review deployment-related files:
- `.github/workflows/*.yml` - All GitHub Actions workflows
- Deployment configuration files (e.g., `fly.toml`, `render.yaml`, `railway.json`)
- Staging/production environment configs (if separate files exist)
- `Dockerfile` - Container build configuration
- `.env.example` - Environment variable template

### Audit Process

1. **Environment Variables Check**
   - Compare `.env.example` with deployment workflows
   - Identify new environment variables from recent code changes
   - Verify all required variables are set in deployment workflows
   - Check for hardcoded values that should be secrets

2. **GitHub Workflow Analysis**
   For each workflow (`docker-publish.yml`, `deploy-fly.yml`, etc.):
   - Are new secrets needed for recent features?
   - Do build steps account for new dependencies?
   - Are test commands updated for new test files?
   - Do deployment steps set all necessary environment variables?

   **Critical Dependency Check**:
   - Check `pyproject.toml` for dependencies that require extras (e.g., `httpx[http2]`, `uvicorn[standard]`)
   - Verify optional features used in code are included in main `dependencies` (not just `dev`)
   - Common issue: Using `http2=True`, `h2=True`, or other optional features without installing the extra packages
   - Example: If code uses `httpx.AsyncClient(http2=True)`, ensure `httpx[http2]` is in dependencies

3. **Deployment Platform Configuration**
   - Does the deployment config include new environment variables?
   - Are new internal service dependencies configured?
   - Do health checks account for new endpoints?
   - Are resource limits appropriate for new features?

4. **Docker Configuration**
   - Does Dockerfile copy new configuration files?
   - Are new system dependencies installed?
   - Are new Python packages in requirements reflected?

### Output Format

```markdown
## Deployment Configuration Audit

### GitHub Workflows
**File**: `.github/workflows/[workflow-name].yml`

Issues:
- [ ] **Missing Secret**: `[SECRET_NAME]` needed for [feature]
- [ ] **Missing Env Var**: `[VAR_NAME]` not set in deployment step
- [ ] **Outdated Command**: [Description of command that needs update]

Recommendations:
1. Add to secrets sync section (lines X-Y):
   ```yaml
   [SECRET_NAME]="${{ secrets.[SECRET_NAME] }}" \
   ```

### Deployment Platform Configuration
**File**: Deployment config (e.g., `fly.toml`, `render.yaml`, etc.)

Issues:
- [ ] **Missing Env Var**: `[VAR_NAME]` should be in environment section
- [ ] **Missing Service Link**: New dependency on internal service

Recommendations:
1. Add to environment configuration:
   ```
   [VAR_NAME] = "[default_value]"
   ```

### Environment Template
**File**: `.env.example`

Issues:
- [ ] **Missing Variable**: `[VAR_NAME]` used in code but not documented
- [ ] **Outdated Comment**: [Description]

Recommendations:
1. Add new variables with documentation comments
```

## Recent Feature Context

**Important**: Before starting the audit, I will:

1. Review recent git commits to understand what changed:
   ```bash
   git log --oneline -10
   git diff HEAD~5..HEAD --stat
   ```

2. Search for new environment variables in code:
   ```bash
   grep -r "os.getenv\|Settings\(\)" src/ --include="*.py"
   ```

3. Check for new service integrations:
   ```bash
   grep -r "httpx\|requests\|AsyncClient" src/ --include="*.py"
   ```

4. Check for optional dependency usage that needs extras in pyproject.toml:
   ```bash
   # Check for HTTP/2 usage
   grep -r "http2=True" src/ --include="*.py"

   # Check for other common optional features
   grep -r "h2=True\|websockets=True\|brotli=True" src/ --include="*.py"

   # Verify pyproject.toml has the extras
   grep "httpx\[" pyproject.toml
   ```

## Review Repository Skill (Optional)

After a feature implementation, consider whether the repository's expert skill file should be updated to reflect new architectural patterns, features, or integrations.

### Repository-Skill Detection

Skills are located in `.claude/skills/` with naming convention `*-expert.md`. The post-feature command will automatically detect skill files in the current repository by checking for files matching this pattern.

### When to Update Skill

Consider updating the skill file if the feature:
- Added new major features or subsystems
- Changed core architecture or patterns
- Added new API endpoints or interfaces
- Modified key algorithms or calculations
- Changed data models or database schema
- Added new external integrations
- Introduced new processing pipelines or workflows

### When to Skip

Skip skill updates for:
- Minor bug fixes
- Internal refactoring without API changes
- Test-only changes
- Documentation updates only
- Configuration changes
- Performance optimizations that don't change behavior

### Skill Review Process

1. **Detect Repository**: Identify the current repository from working directory
2. **Locate Skill File**: Use mapping above to find the relevant skill file
3. **Present Option**: Ask user if they want to review the skill
4. **If Yes**:
   - Open the skill file for review
   - Provide context on what changed in this feature
   - Guide user through sections that may need updates
   - Focus on:
     - Architecture overview if structure changed
     - Key algorithms if logic updated
     - Integration points if new services added
     - Data flow if pipeline modified
5. **If No/Later**: Continue with post-feature audit (this is optional)

### Implementation

When executing this step:

```bash
# Find skill files in the repository
SKILL_FILES=$(find .claude/skills -name "*-expert.md" 2>/dev/null)

# If skill files exist, prompt user
if [ -n "$SKILL_FILES" ]; then
  echo "This repository has skill files documenting system architecture:"
  echo "$SKILL_FILES"
  echo ""
  echo "Based on your recent changes, consider reviewing the skill if you:"
  # List the "When to Update" criteria

  # Ask user for decision
  # If yes: Open file and provide update guidance
  # If no/later: Continue with audit
fi
```

**Note**: This step is optional and should not block the post-feature audit from completing. The skill review is a best practice but not required for every feature.

## Execution Plan

I will:

1. **Review Repository Skill (Optional)**: Check if skill file should be updated
2. **Gather Context**: Review recent commits and code changes
3. **Audit Documentation**: Systematically review each documentation file
4. **Audit Deployment**: Check all deployment configuration files
5. **Generate Report**: Provide comprehensive findings with specific recommendations
6. **Await Approval**: Present findings and wait for approval before making any changes

## Notes

- This command is **read-only by default** - it identifies issues but doesn't fix them
- After reviewing the report, you can ask me to implement specific recommendations
- Focus on practical, high-impact issues rather than minor formatting
- Prioritize deployment configuration issues as they can break production

---

Ready to perform post-feature due diligence check.
