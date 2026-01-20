---
description: Review specification through architectural lenses to surface fundamental design gaps
argument-hint: <spec_path> [--auto-apply]
---

# Spec Review - Architecture

Review a specification through architectural thinking lenses to surface fundamental design gaps before detailed implementation review.

## Arguments

- spec_path: Path to the specification file (use @ for file suggestions)
- --auto-apply: (Optional) Enable intelligent auto-apply mode for automated workflows

## Usage

```bash
# Manual mode - prompts for user decision on each finding
/execute-wf:spec-review-architecture @specs/2025-01-19_feature.md

# Auto-apply mode - researches questions automatically where possible
/execute-wf:spec-review-architecture @specs/2025-01-19_feature.md --auto-apply
```

## Description

This command applies **architectural thinking lenses** to a specification to surface fundamental design gaps. Unlike design review (which asks "is this approach implemented well?"), architectural review asks **"is this the right approach?"**

Run this **before** generating test specifications, as architectural changes often invalidate test cases.

## The Seven Architectural Lenses

### Lens 1: Trace the Full Round-Trip

**Thinking mode:** Don't analyze isolated components - trace data flows end-to-end, including time and state.

**What to examine:**
- Draw the complete cycle: trigger → processing → response → next trigger
- What happens *before* the step being implemented?
- What state needs to persist between events?
- What did *we* send that triggered this incoming request?

**Red flags in specs:**
- Only describes the "happy path" without the full cycle
- Focuses on inbound handling without considering outbound context
- No mention of state that persists between interactions
- Missing "time passes" between steps

**Questions that arise:**
- "What information existed before this request arrived?"
- "How does the previous interaction affect this one?"
- "What context is lost between request and response?"

---

### Lens 2: Who Knows What, When?

**Thinking mode:** Think about information asymmetry across system boundaries. Each actor (user, service, database) has different information at different times.

**What to examine:**
- At each step, what information does each actor have?
- Are we asking one component to guess what another component knows?
- Could the actor with authoritative knowledge simply tell us?

**Red flags in specs:**
- Pattern matching or inference to determine user intent
- Parsing message content to extract structured data
- "Detect" or "determine" language for routing decisions
- Complex classification logic

**Questions that arise:**
- "Who actually knows this information? Can they tell us directly?"
- "Are we inferring something that could be explicit?"
- "Why is component X guessing what component Y knows?"

---

### Lens 3: Question the Problem Framing

**Thinking mode:** Before solving the problem, verify you're solving the right problem. The stated problem often masks the actual need.

**What to examine:**
- What's the stated problem in the spec?
- What's the underlying need that problem serves?
- Does the solution address the stated problem or the underlying need?
- Could the problem be reframed to open different solution spaces?

**Red flags in specs:**
- Solution tightly coupled to problem framing
- Only one approach considered
- Problem statement contains solution hints ("we need to detect X")
- Solving symptoms rather than root cause

**Questions that arise:**
- "What's the actual need underneath this problem statement?"
- "If we reframe this as [alternative framing], what solutions emerge?"
- "Are we solving the symptom or the cause?"

---

### Lens 4: Inventory Existing Capabilities

**Thinking mode:** Platforms, frameworks, and existing systems often have capabilities that aren't being used. Before building, audit what exists.

**What to examine:**
- What platforms/services are involved? (Twilio, Supabase, GitHub Actions, etc.)
- What capabilities do they provide that aren't mentioned in the spec?
- What data is available in webhooks/events that we might be ignoring?
- What existing code in the codebase solves similar problems?

**Red flags in specs:**
- Building custom logic for common platform features
- No mention of platform documentation or capabilities
- Reinventing patterns that exist elsewhere in the codebase
- Complex orchestration when platform has native support

**Questions that arise:**
- "Does [platform] have native support for this?"
- "What fields are available in the [webhook/event] that we're not using?"
- "How did we solve this in [similar existing feature]?"

---

### Lens 5: Find the Source of Truth

**Thinking mode:** For any piece of information, identify what's authoritative. Design the system to use the authoritative source directly, not inferences or copies.

**What to examine:**
- For each key decision/data point, what's the authoritative source?
- Are we using the authoritative source, or inferring/copying?
- Could the source of truth be queried directly?
- Are we building caches or copies that could drift from truth?

**Red flags in specs:**
- Inference logic to determine what could be known directly
- Storing derived data instead of querying source
- Multiple places where the same information is maintained
- "Sync" or "update" logic to keep copies consistent

**Questions that arise:**
- "What's the authoritative source for [this information]?"
- "Why are we inferring X when [source] knows it directly?"
- "Can we query the source of truth instead of maintaining a copy?"

---

### Lens 6: Push Decisions to the Edges

**Thinking mode:** Don't build middleware to make decisions that endpoints can make themselves. If an intelligent agent (user, LLM, smart client) is at the edge, let it decide.

**What to examine:**
- What decisions are being made in middle layers?
- Could the endpoint (user, client, LLM) make this decision instead?
- Are we building classification/routing logic that could be implicit?
- What structured data are we creating that raw data would suffice for?

**Red flags in specs:**
- Enum types for classification that an LLM could infer
- Routing tables for decisions an intelligent agent could make
- Parsing to extract structure from text that will be read by an LLM anyway
- Metadata fields that duplicate information in the payload

**Questions that arise:**
- "Why are we classifying this in middleware instead of letting [edge] decide?"
- "Does this structured data add value, or could [agent] work from raw input?"
- "Can we eliminate this routing logic by letting [endpoint] handle it?"

---

### Lens 7: Follow the Dependency Direction

**Thinking mode:** Dependencies should point toward stable things, not volatile things. If A depends on B, changes to B break A. Make sure dependencies flow toward things that change slowly.

**What to examine:**
- What does the routing/processing logic depend on?
- Which of those dependencies are volatile (formats, patterns, content)?
- Which are stable (IDs, protocols, contracts)?
- Could we restructure so dependencies point toward stable things?

**Red flags in specs:**
- Regex patterns for routing (volatile: message format)
- String matching on content (volatile: phrasing)
- Position-based parsing (volatile: output format)
- Feature detection by content inspection (volatile: feature implementation)

**Questions that arise:**
- "What happens when [this format] changes?"
- "Can we depend on [stable identifier] instead of [volatile content]?"
- "Which way do the dependencies point? Toward stable or volatile?"

---

## Output Format

For each lens, present findings in this structure:

```markdown
## Lens X: [Lens Name]

### Observation
[What was observed when viewing the spec through this lens]

### Potential Gap
[The architectural concern this raises - or "None identified" if the spec handles this well]

### Questions to Investigate
1. [Specific question arising from this lens]
2. [Another question if applicable]

### Investigation Approach
- [ ] Research: [What to look up - platform docs, existing code, etc.]
- [ ] Experiment: [What to try to validate assumptions]
- [ ] Ask user: [What clarification is needed]
```

After all lenses, provide:

```markdown
## Summary

### Critical Gaps (address before proceeding)
- [Gap 1]: [Why it's critical]
- [Gap 2]: [Why it's critical]

### Questions Requiring Investigation
| # | Question | Lens | Investigation Type |
|---|----------|------|-------------------|
| 1 | [Question] | [Lens #] | Research / Experiment / Ask user |
| 2 | [Question] | [Lens #] | Research / Experiment / Ask user |

### Recommended Next Steps
1. [First thing to investigate/clarify]
2. [Second thing]
3. [Then proceed to: spec-tests / design review / etc.]
```

## Process Flow

### Manual Mode (Default)

1. **Apply Each Lens**: Analyze spec through all 7 lenses
2. **Present Findings**: Show observations, gaps, and questions for each lens
3. **Prioritize Questions**: Rank by impact on architecture
4. **User Decision**: For each question:
   - Investigate now (research, experiment, clarify)
   - Note for later (add to spec as open question)
   - Dismiss (not relevant for this feature)
5. **Update Spec**: Add findings to spec's "Architectural Decisions" section
6. **Proceed**: Move to spec-tests once critical gaps addressed

### Auto-Apply Mode (`--auto-apply` flag)

1. **Apply Each Lens**: Analyze spec through all 7 lenses
2. **Categorize Questions**:
   - **Auto-Research**: Questions answerable by reading platform docs, existing code, or CLAUDE.md
   - **Needs User Input**: Questions requiring user clarification or business decisions
3. **Investigate Auto-Research Questions**:
   - Read relevant platform documentation (WebFetch if needed)
   - Search existing codebase for similar patterns
   - Check CLAUDE.md for established approaches
4. **Present Findings**: Show results of auto-research and remaining questions
5. **User Decision**: Address remaining questions requiring input
6. **Update Spec**: Add architectural decisions based on findings
7. **Proceed**: Move to spec-tests

## When to Use This Review

**Always run before `spec-tests`** for specs that involve:
- Integration with external platforms (APIs, webhooks, third-party services)
- Multi-step workflows with state between steps
- Message routing or classification logic
- User interaction patterns (conversational, request/response)
- Data synchronization between systems

**Can skip for specs that are:**
- Pure refactoring with no new data flows
- Adding fields to existing, well-understood models
- Simple CRUD operations on established patterns
- Bug fixes with clear, localized scope

## Integration with Review Pipeline

```
spec-simplify → spec-review-architecture → spec-tests → spec-review-design → spec-review-implementation
                        ↑
                   YOU ARE HERE
```

**Why this position?**
- After simplify: Work with a lean spec, not over-engineered cruft
- Before tests: Architectural changes invalidate test specifications
- Before design: No point optimizing implementation of wrong approach

## Example Findings

### Example: Lens 2 Finding (Who Knows What, When?)

```markdown
## Lens 2: Who Knows What, When?

### Observation
The spec proposes pattern matching on message content to determine if the user
is categorizing a special merchant: "Router detects date+amount pattern like
'Jan 14 $20 is dining'"

### Potential Gap
The router is being asked to **infer** what the user is responding to, when the
user actually **knows** what they're responding to (they're looking at the
original message on their screen).

### Questions to Investigate
1. Can the user explicitly indicate what message they're responding to?
2. Does the messaging platform (Twilio/WhatsApp) provide reply context?
3. What data is available in the incoming webhook that indicates reply relationships?

### Investigation Approach
- [ ] Research: Check Twilio webhook documentation for reply-related fields
- [ ] Research: Search codebase for existing WhatsApp reply handling
- [ ] Experiment: Send a reply in WhatsApp and inspect the webhook payload
```

### Example: Lens 4 Finding (Inventory Existing Capabilities)

```markdown
## Lens 4: Inventory Existing Capabilities

### Observation
The spec builds custom context storage with structured JSON:
`{message_type: "special_merchant", context: {transactions: [...]}}`

### Potential Gap
We may be building context management that the platform provides natively, or
over-structuring data that could be simpler.

### Questions to Investigate
1. Does Twilio maintain conversation history we could query?
2. Does WhatsApp's reply feature provide the original message content?
3. Could we store just the message text and let Claude infer the structure?

### Investigation Approach
- [ ] Research: Twilio conversation history API
- [ ] Research: WhatsApp Business API reply context documentation
- [ ] Ask user: Is there a reason we need structured context vs. raw message text?
```

## Change Tracking

Architectural decisions discovered through this review should be:
1. Added to the spec's "Architectural Decisions" section (if it exists)
2. Or added as a new section documenting key decisions and rationale
3. Committed with message: "Add architectural review findings to spec"

This creates a record of *why* architectural choices were made, not just what they are.
