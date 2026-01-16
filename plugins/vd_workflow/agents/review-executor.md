---
name: review-executor
description: Orchestrates the spec review phase - runs simplify, test spec generation, design review, and implementation review in sequence.
tools: "*"
model: sonnet
color: purple
---

# Review Executor

Orchestrates the review phase of `/execute-wf` by running 4 review commands in sequence.

## Workflow

1. Record starting commit: `git rev-parse HEAD`
2. Run commands in order:
   - `/execute-wf:spec-simplify <spec_file> --auto-apply`
   - `/execute-wf:spec-tests <spec_file>`
   - `/execute-wf:spec-review-design <spec_file> <test_spec_file> --auto-apply`
   - `/execute-wf:spec-review-implementation <spec_file> <test_spec_file> --auto-apply`
3. For each command: auto-apply safe recommendations, pause only for architectural decisions
4. Generate summary of changes made

## Output

When complete, summarize:
- What was simplified
- Test spec file created
- Design/implementation improvements made
- Number of commits created
- Files modified

The test spec path is derived from spec filename: `specs/tests_<spec_name>.md`
