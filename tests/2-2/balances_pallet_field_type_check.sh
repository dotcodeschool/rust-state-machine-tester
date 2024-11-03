#!/bin/bash
./tests/helpers/update_version.sh "0.2.2"
# Define the file to check
BALANCES_FILE="src/balances.rs"

source ./tests/helpers/check_struct_and_update_version.sh
check_struct_and_update_version "$BALANCES_FILE" "pub struct Pallet<AccountId, Balance>" "0.4.3"
check_struct_and_update_version "$BALANCES_FILE" "pub struct Pallet<T: Config>" "0.4.6"

# Step 1: Check if `Pallet` struct is implemented with either direct generics or a Config trait
if grep -q "pub struct Pallet<.*AccountId.*Balance.*>" "$BALANCES_FILE" || \
   grep -q "pub struct Pallet<T: Config>" "$BALANCES_FILE"; then
    echo "Found Pallet struct with generics for AccountId and Balance, or with Config trait."
else
    echo "Error: Pallet struct not found or missing generics for AccountId and Balance, or missing Config trait."
    exit 1
fi

# Step 2: Check if `Pallet` has the `balances` field with either direct types or Config trait-associated types
if (grep -q "balances: BTreeMap<String, u128>" "$BALANCES_FILE" || \
    grep -q "balances: BTreeMap<AccountId, Balance>" "$BALANCES_FILE" || \
    grep -q "balances: BTreeMap<T::AccountId, T::Balance>" "$BALANCES_FILE"); then
    echo "Found balances field with correct type in Pallet struct."
else
    echo "Error: Pallet struct does not contain the 'balances' field with the correct type. Please check your implementation."
    exit 1
fi

# Run test to validate the implementation if all checks pass
cargo test test_balances_pallet_implementation