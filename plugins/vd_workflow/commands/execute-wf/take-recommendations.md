---
description: Apply specific recommendations from spec-review by section number
argument-hint: sections: <comma-separated list>
---

# Take Recommendations

Apply specific recommendations from a spec-review session by section number, updating both spec and test spec files incrementally.

## Arguments

- sections: Comma-separated list of section numbers to apply (e.g., "1, 2, 4" or "1,3,5")

## Usage

```bash
/execute-wf:take-recommendations sections: 1, 2, 4
/execute-wf:take-recommendations sections: 1,3,5
/execute-wf:take-recommendations sections: 2
```

This command is designed to work during an active `/spec_review` session where numbered sections have been presented.

## Description

This command applies recommendations from specific sections of a spec review session in an iterative fashion:

1. **Parse Section Numbers**: Extract the section numbers from the user input
2. **Process Each Section**: For each specified section number:
   - Apply the recommendation to the spec file
   - Apply corresponding changes to the test spec file
   - Commit the changes with a descriptive message
   - Move to the next section
3. **Report Progress**: Show which sections have been processed

## Process Flow

For each section number specified:

1. **Apply to Spec File**: Update the main specification file based on the recommendation for that section
2. **Apply to Test Spec File**: Update the test specification file with corresponding changes
3. **Commit Changes**: Create a git commit with message: `Apply spec review recommendation from section X`
4. **Continue**: Move to the next section in the list

## Requirements

- Must be used during an active spec review session
- Both spec and test spec file paths must be available from the current review context
- Section numbers must correspond to numbered sections from the most recent spec review output
- Git repository must be in a clean state or have only the spec files staged

## Error Handling

- **Invalid Section Numbers**: If a section number doesn't exist in the current review, skip it and report the issue
- **Missing Files**: If spec or test spec files cannot be found, report the error and stop processing
- **Git Issues**: If commits fail, report the issue and stop processing to avoid inconsistent state

## Output Format

For each processed section:
```
Processing Section X...
✓ Updated spec file: [brief description of change]
✓ Updated test spec file: [brief description of change]  
✓ Committed changes: Apply spec review recommendation from section X

Processing Section Y...
[continues for each section]

Summary:
- Processed sections: X, Y, Z
- Total commits: 3
- Files updated: spec_file.md, test_spec_file.md
```

## Integration with spec-review

This command is specifically designed to work with the updated `/spec_review` command that now outputs numbered sections. The section numbers reference:

**Phase 1 Sections:**
- Section 1 - Simplification Opportunities
- Section 2 - Pythonic Improvements  
- Section 3 - Reuse Opportunities
- Section 4 - Recommended Libraries

**Phase 2 Sections:**
- Section 5+ - Implementation Questions (numbered sequentially)

## Example Workflow

```bash
# Start a spec review
/execute-wf:spec-review-design @specs/feature.md @specs/tests_feature.md

# Review presents numbered sections 1-7 with recommendations
# User decides to take recommendations for sections 1, 3, and 5

/execute-wf:take-recommendations sections: 1, 3, 5

# Command processes each section, updates files, and commits
# User can then continue with remaining sections or finish review
```

## Implementation Notes

- Section numbers are parsed from comma-separated input with flexible whitespace handling
- Each section creates a separate git commit for granular change tracking
- The command maintains context from the active spec review session
- Files are updated using the same patterns as the spec-review command
- All changes are committed before processing the next section to ensure clean state