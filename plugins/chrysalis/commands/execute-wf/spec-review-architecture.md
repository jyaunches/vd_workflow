---
description: Review specification through architectural lenses to surface fundamental design gaps
argument-hint: <spec_dir> [--auto-apply]
---

# Spec Review - Architecture

Review a specification through architectural thinking lenses to surface fundamental design gaps before detailed implementation review.

## Arguments

- spec_dir: Path to the spec directory containing spec.md
- --auto-apply: Auto-research questions where possible

**Path Resolution:** `<spec_dir>/spec.md`

## The Seven Architectural Lenses

### Lens 1: Trace the Full Round-Trip
Don't analyze isolated components—trace data flows end-to-end including time and state.
- What happens *before* this step? What state persists between events?
- **Red flag**: Only describes happy path without full cycle

### Lens 2: Who Knows What, When?
Think about information asymmetry. Each actor has different information at different times.
- Are we asking one component to guess what another knows?
- **Red flag**: Pattern matching or inference to determine user intent

### Lens 3: Question the Problem Framing
Before solving, verify you're solving the right problem.
- What's the underlying need? Could reframing open different solutions?
- **Red flag**: Problem statement contains solution hints ("we need to detect X")

### Lens 4: Inventory Existing Capabilities
Platforms often have capabilities that aren't being used.
- What capabilities do platforms provide that aren't mentioned?
- **Red flag**: Building custom logic for common platform features

### Lens 5: Find the Source of Truth
For any information, identify what's authoritative and use it directly.
- Are we inferring something that could be explicit?
- **Red flag**: Inference logic to determine what could be known directly

### Lens 6: Push Decisions to the Edges
Don't build middleware to make decisions that endpoints can make themselves.
- Could the user, client, or LLM make this decision instead?
- **Red flag**: Classification/routing logic that could be implicit

### Lens 7: Follow the Dependency Direction
Dependencies should point toward stable things, not volatile things.
- Which dependencies are volatile (formats, patterns, content)?
- **Red flag**: Regex patterns for routing, string matching on content

## Output Format

```markdown
## Lens X: [Name]

### Observation
[What was observed]

### Potential Gap
[Architectural concern or "None identified"]

### Questions to Investigate
1. [Specific question]

### Investigation Approach
- [ ] Research: [What to look up]
- [ ] Ask user: [What clarification needed]
```

## Summary Format

```markdown
## Summary

### Critical Gaps (address before proceeding)
- [Gap]: [Why critical]

### Questions Requiring Investigation
| # | Question | Lens | Type |
|---|----------|------|------|
| 1 | [Question] | [#] | Research / Ask user |

### Recommended Next Steps
1. [First investigation]
2. [Proceed to: spec-tests]
```

## Process Flow

1. Apply each lens to spec
2. Present findings
3. Prioritize questions by impact
4. User decision: Investigate now / Note for later / Dismiss
5. Update spec's "Architectural Decisions" section
6. Proceed to spec-tests

### Auto-Apply Mode

- **Auto-Research**: Questions answerable by reading platform docs, existing code, CLAUDE.md
- **Needs User Input**: Business decisions, requirements clarification

## Example Finding

```markdown
## Lens 2: Who Knows What, When?

### Observation
Spec proposes parsing request headers to determine which client sent the request.

### Potential Gap
Server is inferring client identity from headers, when the client could
explicitly identify itself in the request payload.

### Questions to Investigate
1. Can the client include an explicit identifier in requests?

### Investigation Approach
- [ ] Research: Check API client SDK for identity options
```
