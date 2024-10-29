#!/bin/bash
./tests/helpers/update_version.sh "0.2.2"
# Define the file to check
BALANCES_FILE="src/balances.rs"

source ./tests/helpers/check_struct_and_update_version.sh
check_struct_and_update_version "$BALANCES_FILE" "pub struct Pallet<AccountId, Balance>" "0.4.3"

# Check if the Pallet struct contains the `balances` field and/or the `new()` method
if grep -q "pub struct Pallet" "$BALANCES_FILE"; then
    if grep -q "balances: BTreeMap<String, u128>" "$BALANCES_FILE" || grep -q "balances: BTreeMap<AccountId, Balance>" "$BALANCES_FILE"; then
        cargo test test_balances_pallet_implementation
    else
        echo "Pallet struct does not contain the 'balances' field with the correct type. Please check your implementation."
        exit 1
    fi
else
    echo "Pallet struct not found in $BALANCES_FILE. Please check your implementation."
    exit 1
fi