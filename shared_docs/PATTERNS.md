# Code Patterns Checklist

This checklist codifies development patterns for projects using cc_workflow_tools. Use this during code reviews, specification reviews, and implementation to ensure consistency.

## Architectural Patterns

- [ ] **Direct Integration**: Modify existing files rather than creating parallel systems
- [ ] **No Backward Compatibility**: New features become default behavior (unless explicitly requested)
- [ ] **Module Structure**: Follow project-specific patterns (e.g., `config.py`, `main.py`, `models.py`, `services.py`)
- [ ] **Configuration**: All configuration via environment variables loaded through `config.py`
- [ ] **Layer Separation**:
  - Models Layer: Domain models with validation
  - Provider Layer: External service adapters
  - Processing Layer: Business logic orchestration
  - CLI Layer: User interface

## Development Patterns

- [ ] **TDD Methodology**: Write tests before implementation (red → green → refactor)
- [ ] **Phase-Based Implementation**: Break features into incremental, buildable, testable phases
- [ ] **Makefile Commands**: Use Makefile for ALL dev tasks (never direct `pytest`, `uv run`, or `pip`)
- [ ] **uv Package Manager**: Exclusively use `uv` for dependency management (never `pip`)
- [ ] **Specification-Driven**: Create spec in `specs/` before implementation via `/spec` command
- [ ] **Agent Usage**:
  - Use spec-writer agent for specifications
  - Use tests-writer agent for test generation
  - Follow TDD approach for bug fixes

## Test Patterns

- [ ] **Test Organization**: Organize tests into `tests/unit/`, `tests/integration/`
- [ ] **Test Markers**: Use pytest markers: `@pytest.mark.unit`, `@pytest.mark.slow`, `@pytest.mark.api`
- [ ] **Mock Strategy**: Use `pytest-mock` for mocking external dependencies
- [ ] **Test File Naming**: Mirror source structure: `test_<module_name>.py`
- [ ] **Test Class Naming**: `Test<FeatureName>` or `Test<ClassName>`
- [ ] **Test Method Naming**: `test_should_<expected_behavior>_when_<condition>`

## Code Quality Patterns

- [ ] **Type Annotations**: Use type hints on all function signatures
- [ ] **Dataclasses**: Use `@dataclass` for data models (see `models.py`)
- [ ] **Error Handling**: Structured error messages with component prefixes (e.g., `[Analyzer]`, `[Config]`)
- [ ] **CLI Exit Codes**: Follow convention: 0=success, 1=general error, 2=API error, 3=partial failure
- [ ] **Logging**: Use structured logging with appropriate levels

## Documentation Patterns

- [ ] **CLAUDE.md Updates**: Update repository CLAUDE.md when implementation changes significantly
- [ ] **Docstrings**: Include docstrings for public APIs and complex logic
- [ ] **Inline Comments**: Use sparingly, prefer self-documenting code
- [ ] **Specification Files**: Keep specs in `specs/` with date prefixes: `YYYY-MM-DD_HH-mm_<feature>.md`

## Exception: Pattern Modification

**When existing patterns should be modified:**
- Document the reason clearly in the spec or commit message
- Update this PATTERNS.md file with the new pattern
- Ensure the change improves consistency across the codebase
- Get explicit user approval for pattern-breaking changes

**Consistency Priority:**
> **Codebase consistency is the highest priority.** Make choices and suggestions that follow existing patterns UNLESS those patterns need to be modified given new requirements. Only break patterns when the new requirement necessitates it, and when doing so improves overall consistency.

## Pattern Violation Response

If a proposed change violates these patterns:
1. **Flag the violation** clearly
2. **Explain the conflict** with existing patterns
3. **Suggest alternatives** that maintain consistency
4. **If modification is needed**: Present the case for why the pattern should evolve
5. **Get user decision** before proceeding with pattern-breaking changes

---

*Part of the cc_workflow_tools plugin.*
