#!/bin/bash

# Path to main.rs
MAIN_FILE="src/main.rs"

# First, find the Runtime variable assignment
RUNTIME_VAR=$(grep -o '[[:alnum:]_]\+\s*=\s*Runtime::new()' "$MAIN_FILE" | grep -o '^[[:alnum:]_]\+' || echo "")

if [ -z "$RUNTIME_VAR" ]; then
    echo "Error: Could not find Runtime variable initialization."
    exit 1
fi

echo "Found Runtime variable named: $RUNTIME_VAR"

# Check if there is a `println!` statement with debug formatting for the runtime variable
if grep -q "println!.*{:#?}.*$RUNTIME_VAR" "$MAIN_FILE"; then
    echo "Found println! statement with debug formatting for Runtime variable '$RUNTIME_VAR'."
else
    echo "Error: Missing println! statement with debug formatting for Runtime variable '$RUNTIME_VAR'."
    exit 1
fi

# Check if `Runtime::new()` is called
if grep -q 'Runtime::new()' "$MAIN_FILE"; then
    echo "Found Runtime::new() initialization."
else
    echo "Error: Missing Runtime::new() initialization."
    exit 1
fi

# Check if `#[derive(Debug)]` is present for `Runtime`
if grep -q '#\[derive(Debug)\]' "$MAIN_FILE"; then
    echo "Found #[derive(Debug)] for Runtime struct."
else
    echo "Error: Missing #[derive(Debug)] for Runtime struct."
    exit 1
fi

echo "All checks passed for deriving and printing Debug for Runtime."
