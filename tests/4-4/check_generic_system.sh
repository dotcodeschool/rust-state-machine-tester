#!/bin/bash

set -e

# Paths to files
SYSTEM_FILE="src/system.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check if `Pallet` struct is generic over AccountId, BlockNumber, and Nonce, or if it uses a Config trait
if grep -q "pub struct Pallet<.*AccountId.*BlockNumber.*Nonce.*>" "$SYSTEM_FILE" || \
   grep -q "pub struct Pallet<T: Config>" "$SYSTEM_FILE"; then
    echo "Found generics in System Pallet struct, either directly or via Config trait."
else
    echo "Error: Generics not found in System Pallet struct for AccountId, BlockNumber, and Nonce, or missing Config trait."
    exit 1
fi

# Step 2: Check for trait constraints on AccountId, BlockNumber, and Nonce
if (grep -q "impl<AccountId, BlockNumber, Nonce> Pallet<AccountId, BlockNumber, Nonce>" "$SYSTEM_FILE" && \
    grep -q "AccountId: Ord + Clone" "$SYSTEM_FILE" && \
    grep -q "BlockNumber: Zero + One + AddAssign + Copy" "$SYSTEM_FILE" && \
    grep -q "Nonce: Zero + One + Copy" "$SYSTEM_FILE") || \
   (grep -q "pub trait Config" "$SYSTEM_FILE" && \
    grep -q "type AccountId: Ord + Clone" "$SYSTEM_FILE" && \
    grep -q "type BlockNumber: Zero + One + AddAssign + Copy" "$SYSTEM_FILE" && \
    grep -q "type Nonce: Zero + One + Copy" "$SYSTEM_FILE"); then
    echo "Found correct trait constraints for AccountId, BlockNumber, and Nonce in System Pallet."
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

# Run the project to confirm no errors
cargo run

echo "All checks passed: System Pallet correctly implemented as a generic type."