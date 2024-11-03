#!/bin/bash

set -e

# Paths to files
BALANCES_FILE="src/balances.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check for Config trait with associated types and constraints in balances.rs
if grep -q "pub trait Config" "$BALANCES_FILE" && \
   grep -q "type AccountId: Ord + Clone" "$BALANCES_FILE" && \
   grep -q "type Balance: Zero + CheckedSub + CheckedAdd + Copy" "$BALANCES_FILE"; then
    echo "Found Config trait with associated types and constraints in balances pallet."
else
    echo "Error: Missing or incorrect Config trait with required associated types and constraints in balances pallet."
    exit 1
fi

# Step 2: Check if Pallet struct is defined with a single generic parameter T implementing Config
if grep -q "pub struct Pallet<T: Config>" "$BALANCES_FILE"; then
    echo "Found Pallet struct with generic type T implementing Config."
else
    echo "Error: Pallet struct not defined with generic type T implementing Config."
    exit 1
fi

# Step 3: Check for usage of associated types with T:: syntax in functions
if grep -q "balances: BTreeMap<T::AccountId, T::Balance>" "$BALANCES_FILE" && \
   grep -q "self.balances.get(who).unwrap_or(&T::Balance::zero())" "$BALANCES_FILE" && \
   grep -q "self.balances.insert(caller, new_caller_balance)" "$BALANCES_FILE" && \
   grep -q "self.balances.insert(to, new_to_balance)" "$BALANCES_FILE"; then
    echo "Found usage of associated types with T:: syntax in functions."
else
    echo "Error: Incorrect or missing usage of associated types (T::AccountId, T::Balance) in functions."
    exit 1
fi

# Step 4: Check if Runtime implements Config trait for balances in main.rs and uses Self for balances instantiation
if grep -q "impl balances::Config for Runtime" "$MAIN_FILE" && \
   grep -q "balances: balances::Pallet<Self>" "$MAIN_FILE"; then
    echo "Found implementation of Config trait on Runtime and use of Pallet<Self> for balances in Runtime."
else
    echo "Error: Runtime does not implement balances::Config trait, or balances field does not use Pallet<Self>."
    exit 1
fi

# Run the project to confirm no errors
cargo run

echo "All checks passed: Balances Pallet correctly implemented with Config trait."