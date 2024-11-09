#!/bin/bash

SUPPORT_FILE="src/support.rs"

if [ -f "$SUPPORT_FILE" ]; then
    echo "'$SUPPORT_FILE' found"
else
    echo "'$SUPPORT_FILE' not found in $(pwd)"
    exit 1
fi