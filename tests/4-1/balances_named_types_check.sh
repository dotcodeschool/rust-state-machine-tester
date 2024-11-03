#!/bin/bash
./tests/helpers/update_version.sh "0.4.1"
BALANCES_FILE="src/balances.rs"
MAIN_FILE="src/main.rs"

source ./tests/helpers/check_struct_and_update_version.sh
check_struct_and_update_version "$BALANCES_FILE" "pub struct Pallet<AccountId, Balance>" "0.4.3"
check_struct_and_update_version "$BALANCES_FILE" "pub struct Pallet<T: Config>" "0.4.6"

# Check type definitions exist
if (! grep -q "type AccountId = String;" "$BALANCES_FILE" || ! grep -q "type Balance = u128;" "$BALANCES_FILE") && (! grep -q "pub type AccountId = String;" "$MAIN_FILE" || ! grep -q "pub type Balance = u128;" "$MAIN_FILE"); then
    echo "Missing required type definitions. Need 'type AccountId = String;' and 'type Balance = u128;'"
    exit 1
fi

# Check if the Pallet struct contains the `balances` field and/or the `new()` method
if grep -q "pub struct Pallet" "$BALANCES_FILE"; then
    if grep -q "balances: *BTreeMap<.*,.*>" "$BALANCES_FILE"; then
        echo "Pallet struct contains the 'balances' field with a BTreeMap type."
    else
        echo "Pallet struct does not contain the 'balances' field with a BTreeMap type."
        exit 1
    fi
else
    echo "Pallet struct not found in $BALANCES_FILE. Please check your implementation."
    exit 1
fi

# Extract the impl block - modified to handle generic impl blocks
IMPL_BLOCK=$(awk '/impl.*Pallet/,/^}/' "$BALANCES_FILE")

# Extract and check transfer function
TRANSFER_FN=$(echo "$IMPL_BLOCK" | awk '/pub fn transfer/,/\}/')
if [ -z "$TRANSFER_FN" ]; then
    echo "Missing transfer function"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "&mut self"; then
    echo "transfer function must take &mut self as first parameter"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "caller:.*,"; then
    echo "transfer function must take caller parameter"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "to:.*,"; then
    echo "transfer function must take to parameter"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "amount:.*"; then
    echo "transfer function must take amount parameter"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "\-> *Result"; then
    echo "transfer function must return Result"
    exit 1
fi

# Extract and check balance function
BALANCE_FN=$(echo "$IMPL_BLOCK" | awk '/pub fn balance/,/\}/')
if [ -z "$BALANCE_FN" ]; then
    echo "Missing balance function"
    exit 1
fi
if ! echo "$BALANCE_FN" | grep -q "&self"; then
    echo "balance function must take &self as parameter"
    exit 1
fi
if ! echo "$BALANCE_FN" | grep -q "who:.*&"; then
    echo "balance function must take who parameter as a reference"
    exit 1
fi

# Extract and check set_balance function
SET_BALANCE_FN=$(echo "$IMPL_BLOCK" | awk '/pub fn set_balance/,/\}/')
if [ -z "$SET_BALANCE_FN" ]; then
    echo "Missing set_balance function"
    exit 1
fi
if ! echo "$SET_BALANCE_FN" | grep -q "&mut self"; then
    echo "set_balance function must take &mut self as first parameter"
    exit 1
fi
if ! echo "$SET_BALANCE_FN" | grep -q "who:.*&"; then
    echo "set_balance function must take who parameter as a reference"
    exit 1
fi
if ! echo "$SET_BALANCE_FN" | grep -q "amount:.*"; then
    echo "set_balance function must take amount parameter"
    exit 1
fi

# If we get here, run the tests
cargo test test_balances_pallet_implementation
