#!/bin/bash
./tests/helpers/update_version.sh "0.5.7"

MAIN_FILE="src/main.rs"

# Check RuntimeCall enum structure
if ! grep -q "pub enum RuntimeCall.*{" "$MAIN_FILE"; then
    echo "RuntimeCall enum not found"
    exit 1
fi

if ! grep -q "Balances(balances::Call<Runtime>)" "$MAIN_FILE"; then
    echo "Balances variant not correctly defined with nested Call"
    exit 1
fi

# Ensure old variant is removed
if grep -q "BalancesTransfer.*{.*to:.*amount:.*}" "$MAIN_FILE"; then
    echo "Old BalancesTransfer variant should be removed"
    exit 1
fi

# Check dispatch implementation
if ! grep -q "match.*runtime_call.*{" "$MAIN_FILE"; then
    echo "Match statement not found in dispatch implementation"
    exit 1
fi

if ! grep -q "RuntimeCall::Balances(call).*=>" "$MAIN_FILE"; then
    echo "Pattern matching for nested call not found"
    exit 1
fi

if ! grep -q "self\.balances\.dispatch(caller,.*call)" "$MAIN_FILE"; then
    echo "Nested dispatch not implemented correctly"
    exit 1
fi

# Check block construction
if ! grep -q "RuntimeCall::Balances(balances::Call::Transfer.*{" "$MAIN_FILE"; then
    echo "Block construction not using nested calls"
    exit 1
fi

# Run Rust tests
cargo test test_nested_call_structure
cargo test test_nested_dispatch_execution

echo "Nested dispatch implementation is correct!"
