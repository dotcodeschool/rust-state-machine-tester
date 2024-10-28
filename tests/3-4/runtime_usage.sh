#!/bin/bash

MAIN_FILE="src/main.rs"

# Check Runtime creation
if ! grep -q "let mut.*=.*Runtime::new()" "$MAIN_FILE"; then
    echo "Error: Must create a mutable runtime instance"
    exit 1
fi

# Check account setup and genesis state
if ! grep -q "\.set_balance(&.*,.*[0-9])" "$MAIN_FILE"; then
    echo "Error: Must set an initial balance for at least one account"
    exit 1
fi

# Check block simulation steps
if ! grep -q "\.inc_block_number()" "$MAIN_FILE"; then
    echo "Error: Must increment block number"
    exit 1
fi

if ! grep -q "assert_eq!.*block_number()" "$MAIN_FILE"; then
    echo "Error: Must verify block number after increment"
    exit 1
fi

# Check transaction patterns
NONCE_COUNT=$(grep -c "\.inc_nonce(&" "$MAIN_FILE" || echo "0")
if (( NONCE_COUNT < 2 )); then
    echo "Error: Must increment nonce at least twice"
    exit 1
fi

# Check transfer pattern with error handling
TRANSFER_COUNT=$(grep -A2 "transfer" "$MAIN_FILE" | grep -c "map_err" || echo "0")
if (( TRANSFER_COUNT < 2 )); then
    echo "Error: Must include at least two transfers with proper error handling"
    exit 1
fi

# Run the program
cargo run

echo "All checks passed!"