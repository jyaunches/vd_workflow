---
description: Resume workflow execution after gap resolution
---

# Continue Workflow Execution

I'll resume the automated workflow from where it was paused due to gap detection.

## Workflow State Analysis

Let me check for blocked or in-progress tasks in beads:

```bash
# Set environment for beads
export BD_ACTOR="claude-code"

# Check for blocked tasks
echo "=== Checking for Blocked Tasks ==="
bd list --status blocked --json

# Check for in-progress tasks
echo "=== Checking for In-Progress Tasks ==="
bd list --status in_progress --json
```

## Prerequisites Check

Before resuming, I'll verify the required components exist:

```bash
# Check if beads is initialized
if [ ! -d ".beads" ]; then
    echo "❌ ERROR: Beads not initialized in this repository"
    echo "Cannot resume workflow without beads tracking"
    exit 1
fi

# Check for PATTERNS.md
if [ -f ".claude/PATTERNS.md" ]; then
    echo "✓ PATTERNS.md found - pattern enforcement enabled"
else
    echo "⚠️  PATTERNS.md not found - run /cc_workflow_tools:init to create starter template"
    echo "   (workflow will continue but may ask about more recommendations)"
fi

# Note: Workflow agents are provided by the cc_workflow_tools plugin
echo "✓ Workflow agents provided by cc_workflow_tools plugin"

# Legacy check removed - agents no longer need to be local files
if false; then
    echo "⚠️  WARNING: Workflow agents not found"
    echo "Expected: .claude/agents/review-executor.md and .claude/agents/feature-writer.md"
    echo "Workflow automation may not function correctly"
fi
```

## Resume Logic

Based on the current workflow state, I will:

### If Blocked Task Found

```bash
# Get blocked task details
BLOCKED_TASK=$(bd list --status blocked --json | jq -r '.[0]')
TASK_ID=$(echo $BLOCKED_TASK | jq -r '.id')
TASK_TITLE=$(echo $BLOCKED_TASK | jq -r '.title')
TASK_NOTES=$(echo $BLOCKED_TASK | jq -r '.notes')

echo "📋 Blocked Task Found"
echo "Task: $TASK_TITLE ($TASK_ID)"
echo "Reason: $TASK_NOTES"
echo ""
echo "Has the gap been resolved? If yes, I'll update the task status and resume."
```

**User Confirmation Required**: Before resuming, I need confirmation that the gap has been resolved.

If confirmed:
1. Update task status from `blocked` → `in_progress`
2. Find associated epic to get spec file path
3. Re-invoke appropriate workflow agent (review-executor or feature-writer) to continue from this task

### If In-Progress Task Found

```bash
# Get in-progress task details
IN_PROGRESS=$(bd list --status in_progress --json | jq -r '.[0]')
TASK_ID=$(echo $IN_PROGRESS | jq -r '.id')
TASK_TITLE=$(echo $IN_PROGRESS | jq -r '.title')

echo "🔄 Workflow Already In Progress"
echo "Task: $TASK_TITLE ($TASK_ID)"
echo ""
echo "Resuming from current task..."
```

Resume immediately by invoking the appropriate workflow agent (review-executor or feature-writer based on current task stage).

### If No Active Workflow

```bash
echo "ℹ️  No Active Workflow Found"
echo ""
echo "No blocked or in-progress tasks detected."
echo "Either:"
echo "  - Workflow has completed (all tasks closed)"
echo "  - No workflow has been started"
echo ""
echo "To start a new workflow, use:"
echo "  /spec <feature_name> \"<description>\" --auto-workflow"
```

## Workflow Agent Invocation

Once I've identified the current task and loaded the spec file, I'll invoke the appropriate workflow agent:

```bash
# Get epic associated with the task
EPIC_ID=$(bd show $TASK_ID --json | jq -r '.parent_id // .epic_id')

# Get spec file from epic external_ref
SPEC_FILE=$(bd show $EPIC_ID --json | jq -r '.external_ref')

if [ -z "$SPEC_FILE" ] || [ "$SPEC_FILE" == "null" ]; then
    echo "❌ ERROR: Spec file not found in epic external_ref"
    echo "Cannot resume workflow without specification file"
    exit 1
fi

echo "📄 Specification: $SPEC_FILE"
echo ""
echo "Determining appropriate workflow agent based on task stage..."

# Determine which agent to use based on task title/stage
if echo "$TASK_TITLE" | grep -iq "review\|simplify\|spec"; then
    AGENT="review-executor"
    echo "Using review-executor agent for spec review/simplification stage"
else
    AGENT="feature-writer"
    echo "Using feature-writer agent for implementation stage"
fi

echo "Invoking $AGENT agent to resume..."
```

I will then use the Task tool to invoke the appropriate workflow agent with context:

```python
# Determine agent based on task stage
if "review" in task_title.lower() or "simplify" in task_title.lower() or "spec" in task_title.lower():
    agent = "review-executor"
else:
    agent = "feature-writer"

Task(
    description="Resume workflow execution",
    subagent_type=agent,
    prompt=f"""
    Resume automated workflow execution from current state.

    Current Task: {task_id} - {task_title}
    Specification: {spec_file}
    Epic: {epic_id}

    Instructions:
    - Start from the current task (already marked in_progress)
    - Execute the stage corresponding to the task title
    - Detect gaps and block if found
    - On success, close task and move to next ready task
    - Continue until all tasks complete or gap detected

    Context:
    - Task was previously blocked: {was_blocked}
    - Gap resolution: {gap_resolution_notes}
    """
)
```

## Output Summary

After resuming, I'll provide status updates:

```
✅ Workflow Resumed

Current Stage: {stage_name}
Progress: {completed_tasks}/{total_tasks} tasks complete
Next Steps: {next_task_title}

Workflow will continue automatically and pause if gaps are detected.
```

## Error Handling

If errors occur during resume:

- **Beads not initialized**: Cannot resume, instruct user to initialize beads
- **No active tasks**: No workflow to resume, suggest starting new workflow
- **Spec file missing**: Cannot proceed, request spec file location
- **Prerequisites missing**: Warn but attempt to continue with limited functionality

---

**Note**: This command requires:
- Beads MCP server available and initialized in repository
- Active workflow (blocked or in-progress tasks)
- Epic `external_ref` contains valid spec file path

If these conditions are not met, the command will provide guidance on next steps.
