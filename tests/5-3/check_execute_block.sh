#!/bin/bash
./tests/helpers/update_version.sh "0.5.3"

MAIN_FILE="src/main.rs"

# Check for Dispatch trait import
if ! grep -q "use crate::support::Dispatch;" "$MAIN_FILE"; then
    echo "Missing import of Dispatch trait"
    exit 1
fi

# Check execute_block function signature
if ! grep -q "fn execute_block(&mut self, block: types::Block) -> support::DispatchResult" "$MAIN_FILE"; then
    echo "Incorrect execute_block function signature"
    exit 1
fi

# Check for block number increment
if ! grep -q "self\.system\.inc_block_number()" "$MAIN_FILE"; then
    echo "Missing block number increment"
    exit 1
fi

# Check for block number validation
if ! grep -q "block\.header\.block_number.*!=.*self\.system\.block_number()" "$MAIN_FILE"; then
    echo "Missing block number validation"
    exit 1
fi

# Check for proper extrinsic iteration
if ! grep -q "for.*support::Extrinsic.*{.*caller.*call.*}.*in.*block\.extrinsics\.into_iter()" "$MAIN_FILE"; then
    echo "Missing or incorrect extrinsic iteration"
    exit 1
fi

# Check for nonce increment
if ! grep -q "self\.system\.inc_nonce(&caller)" "$MAIN_FILE"; then
    echo "Missing nonce increment in extrinsic processing"
    exit 1
fi

# Check for dispatch call
if ! grep -q "self\.dispatch(caller, call)" "$MAIN_FILE"; then
    echo "Missing dispatch call"
    exit 1
fi

# Check for error handling with block/extrinsic info
if ! grep -q "Extrinsic Error.*Block Number:.*Extrinsic Number:.*Error:" "$MAIN_FILE"; then
    echo "Missing or incorrect error handling"
    exit 1
fi

# Run Rust tests
cargo test test_execute_block_implementation

echo "execute_block implementation is correct!"