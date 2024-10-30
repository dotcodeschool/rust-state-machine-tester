#!/bin/bash

set -e

# Paths to files
SYSTEM_FILE="src/system.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check if `Pallet` is generic over AccountId, BlockNumber, and Nonce
if grep -q "pub struct Pallet<.*AccountId.*BlockNumber.*Nonce.*>" "$SYSTEM_FILE"; then
    echo "Found generics in System Pallet struct for AccountId, BlockNumber, and Nonce."
else
    echo "Error: Generics not found in System Pallet struct for AccountId, BlockNumber, and Nonce."
    exit 1
fi

# Step 2: Check for necessary trait constraints in the impl block for System Pallet
if grep -q "impl<AccountId, BlockNumber, Nonce> Pallet<AccountId, BlockNumber, Nonce>" "$SYSTEM_FILE" && \
   grep -q "AccountId: Ord + Clone" "$SYSTEM_FILE" && \
   grep -q "BlockNumber: Zero + One + AddAssign + Copy" "$SYSTEM_FILE" && \
   grep -q "Nonce: Zero + One + Copy" "$SYSTEM_FILE"; then
    echo "Found trait constraints on AccountId, BlockNumber, and Nonce in impl block."
else
    echo "Error: Missing or incorrect trait constraints for AccountId, BlockNumber, or Nonce."
    exit 1
fi

# Step 3: Check if AccountId, BlockNumber, and Nonce are defined in main.rs and are public
if grep -q "pub type AccountId = " "$MAIN_FILE" && \
   grep -q "pub type BlockNumber = " "$MAIN_FILE" && \
   grep -q "pub type Nonce = " "$MAIN_FILE"; then
    echo "Found public definitions for AccountId, BlockNumber, and Nonce in main.rs."
else
    echo "Error: Missing public definitions for AccountId, BlockNumber, or Nonce in main.rs."
    exit 1
fi

# Step 4: Check for explicit use of AccountId, BlockNumber, and Nonce in the Runtime struct or its instantiation
if grep -q "system: system::Pallet<types::AccountId, types::BlockNumber, types::Nonce>" "$MAIN_FILE" || \
   grep -q "system::Pallet::<types::AccountId, types::BlockNumber, types::Nonce>::new()" "$MAIN_FILE"; then
    echo "Found instantiation of generic System Pallet with AccountId, BlockNumber, and Nonce."
else
    echo "Error: Generic System Pallet not instantiated with AccountId, BlockNumber, and Nonce in main.rs."
    exit 1
fi

cargo run

echo "All checks passed: System Pallet correctly implemented as a generic type."