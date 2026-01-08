#!/bin/bash
# Check if project has been initialized for cc_workflow_tools

if [ ! -d "specs" ]; then
    echo "cc_workflow_tools: specs/ directory not found - run /cc_workflow_tools:init to set up the project"
fi
