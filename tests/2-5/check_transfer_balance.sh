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

# Check if Pallet is initialized
if grep -q "let mut.*=.*Pallet::new()" "$BALANCES_FILE"; then
    echo "Pallet is initialized."
else
    echo "Error: Pallet is not initialized in your test."
    exit 1
fi

# Check for core test components:
# 1. At least one failed transfer attempt (any error case)
# 2. At least one successful transfer
# 3. Balance checks after transfers
FAILED_TRANSFER=$(grep -c "assert.*transfer.*Err" "$BALANCES_FILE")
SUCCESSFUL_TRANSFER=$(grep -c "assert.*transfer.*Ok" "$BALANCES_FILE")
BALANCE_CHECKS=$(grep -c "assert.*balance" "$BALANCES_FILE")

if [ $FAILED_TRANSFER -ge 1 ] && [ $SUCCESSFUL_TRANSFER -ge 1 ] && [ $BALANCE_CHECKS -ge 2 ]; then
    echo "Core test cases are implemented:
    - Failed transfer attempt(s)
    - Successful transfer(s)
    - Balance verification"
else
    echo "Error: Test should include:
    - At least one failed transfer attempt (found: $FAILED_TRANSFER)
    - At least one successful transfer (found: $SUCCESSFUL_TRANSFER)
    - Multiple balance checks (found: $BALANCE_CHECKS)"
    exit 1
fi

cargo test transfer_balance

echo "All checks passed for 'transfer_balance' test."