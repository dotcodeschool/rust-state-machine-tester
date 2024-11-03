#!/bin/bash
./tests/helpers/update_version.sh "0.3.1"

# Define the file to check
BALANCES_FILE="src/balances.rs"
SYSTEM_FILE="src/system.rs"

source ./tests/helpers/check_struct_and_update_version.sh
check_struct_and_update_version "$BALANCES_FILE" "pub struct Pallet<AccountId, Balance>" "0.4.3"
check_struct_and_update_version "$BALANCES_FILE" "pub struct Pallet<T: Config>" "0.4.6"

# Check if the Pallet struct and Config trait are implemented correctly
if grep -q "pub struct Pallet" "$SYSTEM_FILE"; then
    # Check if `Pallet` has fields for block_number and nonce with either direct types or Config trait-associated types
    if (grep -q "block_number: u32" "$SYSTEM_FILE" || grep -q "block_number: BlockNumber" "$SYSTEM_FILE" || grep -q "block_number: T::BlockNumber" "$SYSTEM_FILE") && \
       (grep -q "nonce: BTreeMap<String, u32>" "$SYSTEM_FILE" || grep -q "nonce: BTreeMap<AccountId, Nonce>" "$SYSTEM_FILE" || grep -q "nonce: BTreeMap<T::AccountId, T::Nonce>" "$SYSTEM_FILE"); then
        echo "Found Pallet struct with correct fields for block_number and nonce."
    else
        echo "Error: Pallet struct found in $SYSTEM_FILE, but either 'block_number' or 'nonce' fields are missing or incorrectly implemented. Please check your implementation."
        exit 1
    fi

    # Run test to validate the implementation if all checks pass
    cargo test test_system_implementation
else
    echo "Error: Pallet struct not found in $SYSTEM_FILE. Please check your implementation."
    exit 1
fi