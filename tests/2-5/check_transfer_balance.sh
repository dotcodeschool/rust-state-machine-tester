#!/bin/bash

# Path to the balances.rs file
BALANCES_FILE="src/balances.rs"

# Check if the transfer_balance test is defined
if grep -q "#\[test\]" "$BALANCES_FILE" && grep -q "fn transfer_balance()" "$BALANCES_FILE"; then
    echo "Test 'transfer_balance' is defined."
else
    echo "Error: Test 'transfer_balance' is not defined."
    exit 1
fi

# Extract the transfer_balance function content
TEST_CONTENT=$(sed -n '/fn transfer_balance/,/^    }$/p' "$BALANCES_FILE")

# Check if Pallet is initialized in transfer_balance
if echo "$TEST_CONTENT" | grep -q "let mut.*=.*Pallet::new()"; then
    echo "Pallet is initialized."
else
    echo "Error: Pallet is not initialized in your test."
    exit 1
fi

# More flexible patterns for transfer assertions
FAILED_TRANSFER=$(echo "$TEST_CONTENT" | grep -c "Err(.*\".*\")")
SUCCESSFUL_TRANSFER=$(echo "$TEST_CONTENT" | grep -c "Ok(())")
BALANCE_CHECKS=$(echo "$TEST_CONTENT" | grep -c "assert_eq.*balance")

echo "Debug counts:
- Failed transfers: $FAILED_TRANSFER
- Successful transfers: $SUCCESSFUL_TRANSFER
- Balance checks: $BALANCE_CHECKS"

if [ $FAILED_TRANSFER -ge 1 ] && [ $SUCCESSFUL_TRANSFER -ge 1 ] && [ $BALANCE_CHECKS -ge 2 ]; then
    echo "Core test cases are implemented:
    - Failed transfer attempt(s): $FAILED_TRANSFER
    - Successful transfer(s): $SUCCESSFUL_TRANSFER
    - Balance verification: $BALANCE_CHECKS"
else
    echo "Error: Test should include:
    - At least one failed transfer attempt (found: $FAILED_TRANSFER)
    - At least one successful transfer (found: $SUCCESSFUL_TRANSFER)
    - Multiple balance checks (found: $BALANCE_CHECKS)"
    exit 1
fi

cargo test transfer_balance

echo "All checks passed for 'transfer_balance' test."