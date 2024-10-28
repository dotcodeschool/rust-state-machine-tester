#!/bin/bash
./tests/helpers/update_version.sh "0.3.1"
# Define the file to check
SYSTEM_FILE="src/system.rs"

# Check if the Pallet struct contains the `balances` field and/or the `new()` method
if grep -q "pub struct Pallet" "$SYSTEM_FILE"; then
    if grep -q "block_number: u32" "$SYSTEM_FILE" && grep -q "nonce: BTreeMap<String, u32>" "$SYSTEM_FILE"; then
        cargo test test_system_implementation
    else
        # Pallet struct exists, but either `block_number` or `nonce` fields are missing or not implemented correctly
        echo "Pallet struct found in $SYSTEM_FILE, but either `block_number` or `nonce` fields are missing or not implemented correctly. Please check your implementation."
        exit 1
    fi
else
    echo "Pallet struct not found in $SYSTEM_FILE. Please check your implementation."
    exit 1
fi