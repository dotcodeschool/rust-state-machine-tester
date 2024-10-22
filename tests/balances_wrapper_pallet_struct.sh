#!/bin/bash

# Define the file to check
BALANCES_FILE="src/balances.rs"

# Function to add a feature if it doesn't already exist in Cargo.toml
add_feature_if_not_exists() {
    # Path to the Cargo.toml file
    local CARGO_TOML="Cargo.toml"

    # Define the feature section and feature you want to add
    local FEATURES_SECTION="^\[features\]"
    local FEATURE_EARLY="^early = \[\]$"  # Exact match for the feature

    # Check if Cargo.toml contains a [features] section (using regex for exact match)
    if grep -q "$FEATURES_SECTION" "$CARGO_TOML"; then
        echo "Features section already exists in Cargo.toml"
    else
        echo "Adding [features] section to Cargo.toml"
        echo "" >> "$CARGO_TOML"
        echo "[features]" >> "$CARGO_TOML"
    fi

    # Check if the "early" feature is already defined
    if grep -qx "$FEATURE_EARLY" "$CARGO_TOML"; then
        echo "Feature 'early' already exists in Cargo.toml"
    else
        echo "Adding feature 'early' to Cargo.toml"
        echo "early = []" >> "$CARGO_TOML"
    fi
}

# Check if the Pallet struct contains the `balances` field and/or the `new()` method
if grep -q "pub struct Pallet" "$BALANCES_FILE"; then
    if grep -q "balances: " "$BALANCES_FILE"; then
        cargo run
    else
        # Pallet struct exists, but no balances field, run the basic test
        echo "Detected Pallet struct, but no balances field."
        add_feature_if_not_exists
        cargo test test_pallet_struct_exists --features early
    fi
else
    echo "Pallet struct not found in $BALANCES_FILE. Please check your implementation."
    exit 1
fi