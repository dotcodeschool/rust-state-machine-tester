#!/bin/bash

# Path to the system.rs file
SYSTEM_FILE="src/system.rs"

# Check if the init_system test is defined
if grep -q "#\[test\]" "$SYSTEM_FILE" && grep -q "fn init_system()" "$SYSTEM_FILE"; then
    echo "Test 'init_system' is defined."
else
    echo "Error: Test 'init_system' is not defined."
    exit 1
fi

# Check if Pallet is initialized in the test
if grep -q "let mut system = super::Pallet::new();" "$SYSTEM_FILE"; then
    echo "Pallet is initialized correctly."
else
    echo "Error: Pallet is not initialized correctly in your test."
    exit 1
fi

# Check if required methods are called
if grep -q "inc_block_number()" "$SYSTEM_FILE" && \
   grep -q "inc_nonce(" "$SYSTEM_FILE" && \
   grep -q "block_number()" "$SYSTEM_FILE"; then
    echo "Required methods are called."
else
    echo "Error: Not all required methods (inc_block_number, inc_nonce, block_number) are used."
    exit 1
fi

# Check for assertions
if grep -q "assert_eq!(system\.block_number()" "$SYSTEM_FILE" && \
   grep -q "assert_eq!(system\.nonce\.get" "$SYSTEM_FILE" && \
   [ $(grep -c "assert_eq!" "$SYSTEM_FILE") -ge 2 ]; then
    echo "Assertions are correct."
else
    echo "Error: Test should include:
    - Assert for block number
    - Assert for nonce
    - At least two assertions total"
    exit 1
fi

cargo test init_system

echo "All checks passed for 'init_system' test."
