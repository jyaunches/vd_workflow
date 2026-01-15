---
description: Create test guides aligned with specification phases for TDD
argument-hint: <spec_file> [instructions]
---

# spec-tests

Create comprehensive test guides aligned with specification phases for incremental TDD implementation.

## Usage

```
/execute-wf:spec-tests @<spec-file> [instructions]
```

## Purpose

This command creates test guides for ALL phases in a specification file to support the `/implement_phase` workflow, which implements phases incrementally: write tests → write code → commit → next phase.

## Process

1. **Analyze Specification**: Read spec file and extract all implementation phases
2. **Review Existing Tests**: Scan `tests/` directory for current test patterns
3. **Create Complete Test Guide**: Generate test specifications for every spec phase
4. **Save Test Specification**: Output as `specs/tests_YYYY-MM-DD_<feature_name>.md`

## Output Format

Generate a comprehensive test guide with sections for each spec phase:

### Phase X: [Phase Name] - Test Guide

**Existing Tests to Modify:**
- `test_existing_function_name` in `tests/test_module.py`
  - Current behavior: What it currently tests  
  - Required changes: What needs to be updated for this phase

**New Tests to Create:**

1. `test_should_create_baseline_calculator_with_config`
   - **Input**: Config with window_minutes=10
   - **Expected**: Calculator instance with window=10
   - **Covers**: [Acceptance criteria reference]

2. `test_should_validate_phase_functionality`
   - **Input**: [test scenario]
   - **Expected**: [expected outcome] 
   - **Covers**: [Acceptance criteria reference]

**Test Implementation Notes:**
- Required mocks and fixtures
- Dependencies on previous phase functionality
- Integration test requirements

