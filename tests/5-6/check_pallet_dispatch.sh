#!/bin/bash
./tests/helpers/update_version.sh "0.5.6"

BALANCES_FILE="src/balances.rs"

# Check Call enum definition
if ! grep -q "pub enum Call<T: Config>" "$BALANCES_FILE"; then
    echo "Call enum not found or not generic over T: Config"
    exit 1
fi

# Check Transfer variant
if ! grep -q "Transfer.*{.*to:.*T::AccountId.*amount:.*T::Balance.*}" "$BALANCES_FILE"; then
    echo "Transfer variant not defined correctly"
    exit 1
fi

# Ensure RemoveMe is removed
if grep -q "RemoveMe" "$BALANCES_FILE"; then
    echo "RemoveMe variant should be removed"
    exit 1
fi

# Check Dispatch implementation
if ! grep -q "impl<T: Config>.*support::Dispatch.*for.*Pallet<T>" "$BALANCES_FILE"; then
    echo "Dispatch trait not implemented for Pallet"
    exit 1
fi

# Check associated types
if ! grep -q "type.*Caller.*=.*T::AccountId" "$BALANCES_FILE"; then
    echo "Caller type not correctly defined"
    exit 1
fi

if ! grep -q "type.*Call.*=.*Call<T>" "$BALANCES_FILE"; then
    echo "Call type not correctly defined"
    exit 1
fi

# Check dispatch implementation
if ! grep -q "match.*call.*{" "$BALANCES_FILE"; then
    echo "Match statement not found in dispatch implementation"
    exit 1
fi

if ! grep -q "Call::Transfer.*{.*to.*amount.*}" "$BALANCES_FILE"; then
    echo "Transfer pattern matching not found"
    exit 1
fi

if ! grep -q "self\.transfer(caller,.*to,.*amount)" "$BALANCES_FILE"; then
    echo "Transfer function not called correctly"
    exit 1
fi

# Run the Rust tests
cargo test test_balances_call_definition
cargo test test_balances_dispatch_implementation
cargo test test_dispatch_trait_implementation

echo "Pallet dispatch implementation is correct!"
