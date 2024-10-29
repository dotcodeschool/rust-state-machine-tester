#!/bin/bash

# Define file paths
BALANCES_FILE="src/balances.rs"
SYSTEM_FILE="src/system.rs"
MAIN_FILE="src/main.rs"

# Check for `#[derive(Debug)]` in `balances.rs`
if grep -q "#\[derive(Debug)\]" "$BALANCES_FILE"; then
    echo "'#[derive(Debug)]' is correctly implemented in balances.rs."
else
    echo "Error: #[derive(Debug)] is missing in balances.rs."
    exit 1
fi

# Check for `#[derive(Debug)]` in `system.rs`
if grep -q "#\[derive(Debug)\]" "$SYSTEM_FILE"; then
    echo "'#[derive(Debug)]' is correctly implemented in system.rs."
else
    echo "Error: #[derive(Debug)] is missing in system.rs."
    exit 1
fi

# Check for `#[derive(Debug)]` in `main.rs`
if grep -q "#\[derive(Debug)\]" "$MAIN_FILE"; then
    echo "'#[derive(Debug)]' is correctly implemented in main.rs."
else
    echo "Error: #[derive(Debug)] is missing in main.rs."
    exit 1
fi

echo "All required structs derive Debug."