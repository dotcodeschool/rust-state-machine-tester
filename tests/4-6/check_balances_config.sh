#!/bin/bash

set -e

# Paths to files
BALANCES_FILE="src/balances.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check for Config trait with Balance type constraints in balances.rs, and optional system::Config inheritance
if grep -q "pub trait Config" "$BALANCES_FILE" && \
   grep -q "type Balance: Zero + CheckedSub + CheckedAdd + Copy" "$BALANCES_FILE"; then
    if grep -q "pub trait Config: crate::system::Config" "$BALANCES_FILE"; then
        echo "Found Config trait inheriting from system::Config with associated Balance type and constraints."
    else
        echo "Found Config trait without system::Config inheritance, with associated Balance type and constraints."
    fi
else
    echo "Error: Missing or incorrect Config trait with required Balance type constraints in balances pallet."
    exit 1
fi

# Step 2: Confirm Pallet struct is defined with a single generic parameter T implementing Config
if grep -q "pub struct Pallet<T: Config>" "$BALANCES_FILE"; then
    echo "Found Pallet struct with generic type T implementing Config."
else
    echo "Error: Pallet struct not defined with generic type T implementing Config."
    exit 1
fi

# Step 3: Check for usage of associated types with T:: syntax in balances.rs functions
if grep -q "balances: BTreeMap<T::AccountId, T::Balance>" "$BALANCES_FILE" && \
   grep -q "self.balances.get(who).unwrap_or(&T::Balance::zero())" "$BALANCES_FILE" && \
   grep -q "self.balances.insert(caller, new_caller_balance)" "$BALANCES_FILE" && \
   grep -q "self.balances.insert(to, new_to_balance)" "$BALANCES_FILE"; then
    echo "Found usage of associated types with T:: syntax in functions."
else
    echo "Error: Incorrect or missing usage of associated types (T::AccountId, T::Balance) in functions."
    exit 1
fi

# Step 4: Check if Runtime implements balances::Config in main.rs, with or without inheriting AccountId
if grep -q "impl balances::Config for Runtime" "$MAIN_FILE"; then
    echo "Found implementation of balances::Config on Runtime."
else
    echo "Error: Runtime does not implement balances::Config trait."
    exit 1
fi

# Optional check for system inheritance of AccountId, if Config does not define it independently
if grep -q "type AccountId" "$MAIN_FILE"; then
    echo "Notice: AccountId explicitly defined in balances::Config for Runtime."
else
    echo "AccountId not defined directly in balances::Config, assuming inherited from system::Config if present."
fi

# Step 5: Check if Runtime struct uses Self for balances instantiation
if grep -q "balances: balances::Pallet<Self>" "$MAIN_FILE"; then
    echo "Found use of Pallet<Self> for balances instantiation in Runtime."
else
    echo "Error: balances field does not use Pallet<Self> in Runtime."
    exit 1
fi

# Run the project to confirm no errors
cargo run

echo "All checks passed: Balances Pallet correctly implemented with Config trait."