#!/bin/bash

# Paths to files
BALANCES_FILE="src/balances.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check if `Pallet` is generic over AccountId and Balance
if grep -q "pub struct Pallet<.*AccountId.*Balance.*>" "$BALANCES_FILE"; then
    echo "Found generics in Pallet struct for AccountId and Balance."
else
    echo "Error: Generics not found in Pallet struct for AccountId and Balance."
    exit 1
fi

# Step 2: Check for necessary trait constraints on AccountId and Balance
if grep -q "impl<AccountId, Balance> Pallet<AccountId, Balance>" "$BALANCES_FILE" && \
   grep -q "AccountId: Ord + Clone" "$BALANCES_FILE" && \
   grep -q "Balance: Zero + CheckedSub + CheckedAdd + Copy" "$BALANCES_FILE"; then
    echo "Found trait constraints on AccountId and Balance in impl block."
else
    echo "Error: Missing or incorrect trait constraints for AccountId and Balance."
    exit 1
fi

# Step 3: Check if AccountId and Balance are defined in main.rs and are public
if grep -q "pub type AccountId = " "$MAIN_FILE" && \
   grep -q "pub type Balance = " "$MAIN_FILE"; then
    echo "Found public definitions for AccountId and Balance in main.rs."
else
    echo "Error: Missing public definitions for AccountId or Balance in main.rs."
    exit 1
fi

# Step 4: Check for explicit use of AccountId and Balance in the Runtime struct or its instantiation
if grep -q "balances: balances::Pallet<types::AccountId, types::Balance>" "$MAIN_FILE" || \
   grep -q "balances::Pallet::<types::AccountId, types::Balance>::new()" "$MAIN_FILE"; then
    echo "Found instantiation of generic Pallet with AccountId and Balance."
else
    echo "Error: Generic Pallet not instantiated with AccountId and Balance in main.rs."
    exit 1
fi

echo "All checks passed: Balances Pallet correctly implemented as a generic type."