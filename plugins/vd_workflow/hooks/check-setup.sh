#!/bin/bash
# Check if project has been initialized for vd_workflow

if [ ! -d "specs" ]; then
    echo "vd_workflow: specs/ directory not found - run /vd_workflow:init to set up the project"
fi
