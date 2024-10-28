#!/bin/bash
./tests/helpers/update_version.sh "0.3.3"
# Define the file to check
MAIN_FILE="src/main.rs"

# Check if runtime struct is implemented with the correct fields and new() function
if grep -q "pub struct Runtime" "$MAIN_FILE"; then
    if grep -q "system: system::Pallet" "$MAIN_FILE" && grep -q "balances: balances::Pallet" "$MAIN_FILE"; then
        echo "Runtime struct has correct fields."
    else
        echo "Runtime struct is missing either the 'system' or 'balances' field. Please check your implementation."
        exit 1
    fi
else
    echo "Runtime struct is missing. Please check your implementation."
    exit 1
fi

# Check for correct new() function signature
if grep -q "fn new() -> Self" "$MAIN_FILE"; then
    echo "new() function has correct signature."
else
    echo "Error: new() function should have signature 'fn new() -> Self'"
    exit 1
fi

cargo run

echo "All checks passed!"