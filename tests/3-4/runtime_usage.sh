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

# Check block simulation steps - allow both approaches
# Old approach: direct increment and assert
# New approach: through execute_block
if ! (grep -q "\.inc_block_number()" "$MAIN_FILE" || grep -q "execute_block.*expect" "$MAIN_FILE"); then
    echo "Error: Must either increment block number directly or execute a block"
    exit 1
fi

if ! (grep -q "assert_eq!.*block_number()" "$MAIN_FILE" || 
      grep -q "header:.*block_number:.*1" "$MAIN_FILE"); then
    echo "Error: Must verify block number (either through assert or block header)"
    exit 1
fi

# Check transaction patterns - allow both approaches
# Old approach: manual nonce increment
# New approach: through extrinsics
NONCE_COUNT=$(grep -c "\.inc_nonce(&" "$MAIN_FILE" || echo "0")
EXTRINSIC_COUNT=$(grep -c "support::Extrinsic.*{" "$MAIN_FILE" || echo "0")

if (( NONCE_COUNT < 2 )) && (( EXTRINSIC_COUNT < 2 )); then
    echo "Error: Must include at least two transactions (either through manual nonce increments or extrinsics)"
    exit 1
fi

# Check transfer pattern with error handling - allow both approaches
# Old approach: direct transfer with map_err
# New approach: through RuntimeCall::BalancesTransfer
TRANSFER_COUNT=$(grep -A2 "transfer" "$MAIN_FILE" | grep -c "map_err" || echo "0")
BALANCES_TRANSFER_COUNT=$(grep -c "RuntimeCall::BalancesTransfer" "$MAIN_FILE" || echo "0")

if (( TRANSFER_COUNT < 2 )) && (( BALANCES_TRANSFER_COUNT < 2 )); then
    echo "Error: Must include at least two transfers (either direct or through RuntimeCall)"
    exit 1
fi

# Run the program
cargo run

echo "All checks passed!"