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
if grep -q "let mut .* = super::Pallet::new();" "$SYSTEM_FILE"; then
    echo "Pallet is initialized correctly."
else
    echo "Error: Pallet is not initialized correctly in your test."
    exit 1
fi

# Check implementation of inc_nonce
if ! grep -q "self\.nonce\.insert" "$SYSTEM_FILE"; then
    echo "Error: inc_nonce implementation should use nonce.insert"
    exit 1
fi

if ! grep -q "self\.nonce\.get" "$SYSTEM_FILE"; then
    echo "Error: inc_nonce implementation should use nonce.get"
    exit 1
fi

# Check if required methods are called in the test
if grep -q "\.inc_block_number()" "$SYSTEM_FILE" && \
   grep -q "\.inc_nonce(" "$SYSTEM_FILE" && \
   grep -q "\.block_number()" "$SYSTEM_FILE"; then
    echo "Required methods are called."
else
    echo "Error: Not all required methods (inc_block_number, inc_nonce, block_number) are used."
    exit 1
fi

# Check for correct assertion patterns
if grep -q "assert_eq!.*block_number().*1" "$SYSTEM_FILE" && \
   grep -q "assert_eq!.*nonce.*get.*Some(&1)" "$SYSTEM_FILE"; then
    echo "Assertions are correct."
else
    echo "Error: Test should include:
    - Assert block number is 1 after increment
    - Assert nonce is 1 after increment"
    exit 1
fi

cargo test init_system

echo "All checks passed for 'init_system' test."