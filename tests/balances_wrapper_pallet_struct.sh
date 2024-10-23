#!/bin/bash

# Define the file to check
BALANCES_FILE="src/balances.rs"

# Check if the Pallet struct contains the `balances` field and/or the `new()` method
if grep -q "pub struct Pallet" "$BALANCES_FILE"; then
    if grep -q "balances: " "$BALANCES_FILE"; then
        cargo run
    else
        # Pallet struct exists, but no balances field, run the basic test
        echo "Detected Pallet struct, but no balances field."
        ./tests/add_feature.sh
        cargo test test_pallet_struct_exists --features early
    fi
else
    echo "Pallet struct not found in $BALANCES_FILE. Please check your implementation."
    exit 1
fi