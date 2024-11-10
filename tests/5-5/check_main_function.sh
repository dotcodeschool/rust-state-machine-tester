#!/bin/bash
./tests/helpers/update_version.sh "0.5.5"

MAIN_FILE="src/main.rs"

# Check that old transaction code is removed
if grep -q "runtime\.system\.inc_block_number();" "$MAIN_FILE" || \
   grep -q "runtime\.system\.inc_nonce(&alice);" "$MAIN_FILE" || \
   grep -q "runtime\.balances\.transfer(" "$MAIN_FILE"; then
    echo "Old transaction code should be removed"
    exit 1
fi

# Check block creation
if ! grep -q "types::Block.*{" "$MAIN_FILE"; then
    echo "Block creation not found"
    exit 1
fi

if ! grep -q "header:.*support::Header.*{.*block_number:.*1.*}" "$MAIN_FILE"; then
    echo "Header with block number 1 not found"
    exit 1
fi

if ! grep -q "extrinsics:.*vec!\[" "$MAIN_FILE"; then
    echo "Extrinsics vector not found"
    exit 1
fi

# Check for proper extrinsic structure - make pattern more flexible
if ! awk '/Extrinsic.*{/,/}/' "$MAIN_FILE" | grep -q "caller.*:.*" && \
   awk '/Extrinsic.*{/,/}/' "$MAIN_FILE" | grep -q "call.*:.*RuntimeCall::BalancesTransfer"; then
    echo "Extrinsic structure not correct"
    exit 1
fi

# Check execute_block usage with expect
if ! grep -q "runtime\.execute_block.*\.expect" "$MAIN_FILE"; then
    echo "execute_block with expect not found"
    exit 1
fi

# Run the Rust test
cargo test test_block_execution

echo "Main function updated correctly!"
