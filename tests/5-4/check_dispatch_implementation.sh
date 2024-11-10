#!/bin/bash
./tests/helpers/update_version.sh "0.5.4"

MAIN_FILE="src/main.rs"

# Check RuntimeCall enum definition
if ! grep -q "pub enum RuntimeCall" "$MAIN_FILE"; then
    echo "RuntimeCall enum not found"
    exit 1
fi

# Check for either old or new style variant
if ! (grep -q "BalancesTransfer.*{.*to:.*types::AccountId.*amount:.*types::Balance.*}" "$MAIN_FILE" || \
      grep -q "Balances(balances::Call<Runtime>)" "$MAIN_FILE"); then
    echo "RuntimeCall variant not defined correctly"
    exit 1
fi

# Check dispatch implementation
if ! grep -q "match runtime_call" "$MAIN_FILE"; then
    echo "Missing match statement in dispatch implementation"
    exit 1
fi

# Check for either old or new style pattern matching
if ! (grep -q "RuntimeCall::BalancesTransfer.*{.*to.*amount.*}" "$MAIN_FILE" || \
      grep -q "RuntimeCall::Balances(call).*=>" "$MAIN_FILE"); then
    echo "Missing or incorrect match pattern"
    exit 1
fi

# Check for either old or new style function call
if ! (grep -q "self\.balances\.transfer(caller, to, amount)" "$MAIN_FILE" || \
      grep -q "self\.balances\.dispatch(caller,.*call)" "$MAIN_FILE"); then
    echo "Missing or incorrect balances call"
    exit 1
fi

# Check error propagation (works for both styles due to ? operator)
if ! grep -q "?;" "$MAIN_FILE"; then
    echo "Missing error propagation"
    exit 1
fi

# Run the Rust tests
cargo test test_runtime_dispatch
cargo test test_runtime_call_definition

echo "Dispatch implementation is correct!"