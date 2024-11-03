#!/bin/bash

set -e

# Paths to files
SYSTEM_FILE="src/system.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check for Config trait with associated types and constraints
if grep -q "pub trait Config" "$SYSTEM_FILE" && \
   grep -q "type AccountId: Ord + Clone" "$SYSTEM_FILE" && \
   grep -q "type BlockNumber: Zero + One + AddAssign + Copy" "$SYSTEM_FILE" && \
   grep -q "type Nonce: Zero + One + Copy" "$SYSTEM_FILE"; then
    echo "Found Config trait with associated types and constraints in system pallet."
else
    echo "Error: Missing or incorrect Config trait with required associated types and constraints in system pallet."
    exit 1
fi

# Step 2: Check if `Pallet` struct is defined with a single generic parameter T implementing Config
if grep -q "pub struct Pallet<T: Config>" "$SYSTEM_FILE"; then
    echo "Found Pallet struct with generic type T implementing Config."
else
    echo "Error: Pallet struct not defined with generic type T implementing Config."
    exit 1
fi

# Step 3: Check for usage of associated types with T:: syntax in functions
if grep -q "block_number: T::BlockNumber" "$SYSTEM_FILE" && \
   grep -q "nonce: BTreeMap<T::AccountId, T::Nonce>" "$SYSTEM_FILE" && \
   grep -q "self.block_number += T::BlockNumber::one()" "$SYSTEM_FILE" && \
   grep -q "self.nonce.insert(who.clone(), new_nonce);" "$SYSTEM_FILE"; then
    echo "Found usage of associated types with T:: syntax in functions."
else
    echo "Error: Incorrect or missing usage of associated types (T::AccountId, T::BlockNumber, T::Nonce) in functions."
    exit 1
fi

# Step 4: Check if Runtime implements Config trait in main.rs and uses Self for system
if grep -q "impl system::Config for Runtime" "$MAIN_FILE" && \
   grep -q "system: system::Pallet<Self>" "$MAIN_FILE"; then
    echo "Found implementation of Config trait on Runtime and use of Pallet<Self> in Runtime."
else
    echo "Error: Runtime does not implement Config trait, or system field does not use Pallet<Self>."
    exit 1
fi

# Run the project to confirm no errors
cargo run

echo "All checks passed: System Pallet correctly implemented with Config trait."