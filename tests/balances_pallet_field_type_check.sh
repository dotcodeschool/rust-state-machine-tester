#!/bin/bash

# Define the file to check
BALANCES_FILE="src/balances.rs"

# Check if the Pallet struct contains the `balances` field and/or the `new()` method
if grep -q "pub struct Pallet" "$BALANCES_FILE"; then
    if grep -q "balances: BTreeMap<String, u128>" "$BALANCES_FILE"; then
        ./add_feature.sh
        cargo test test_balances_pallet_implementation
    else
        echo "Pallet struct does not contain the `balances` field with the correct type. Please check your implementation."
        exit 1
    fi
else
    echo "Pallet struct not found in $BALANCES_FILE. Please check your implementation."
    exit 1
fi