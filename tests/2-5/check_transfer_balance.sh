#!/bin/bash

# Path to the balances.rs file
BALANCES_FILE="src/balances.rs"

# Step 1: Check if the transfer_balance test is defined
if grep -q "#\[test\]" "$BALANCES_FILE" && grep -q "fn transfer_balance()" "$BALANCES_FILE"; then
    echo "Test 'transfer_balance' is defined."
else
    echo "Error: Test 'transfer_balance' is not defined."
    exit 1
fi

# Extract the transfer_balance function content for more specific checks
TEST_CONTENT=$(sed -n '/fn transfer_balance/,/^    }$/p' "$BALANCES_FILE")

# Step 2: Check if Pallet is initialized in transfer_balance with either direct generics or a Config trait
if echo "$TEST_CONTENT" | grep -q "let mut.*=.*Pallet::new()" || \
   echo "$TEST_CONTENT" | grep -q "let mut.*=.*Pallet::<String, u128>::new()" || \
   echo "$TEST_CONTENT" | grep -q "let mut.*=.*Pallet::<TestConfig>::new()"; then
    echo "Pallet is initialized correctly in transfer_balance."
else
    echo "Error: Pallet is not initialized correctly in your test. Ensure you're using direct generics or a Config trait."
    exit 1
fi

# Step 3: Check for transfer assertions
FAILED_TRANSFER=$(echo "$TEST_CONTENT" | grep -c "Err(.*\".*\")")
SUCCESSFUL_TRANSFER=$(echo "$TEST_CONTENT" | grep -c "Ok(())")
BALANCE_CHECKS=$(echo "$TEST_CONTENT" | grep -c "assert_eq.*balance")

echo "Debug counts:
- Failed transfers: $FAILED_TRANSFER
- Successful transfers: $SUCCESSFUL_TRANSFER
- Balance checks: $BALANCE_CHECKS"

# Step 4: Ensure required assertions are present
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

# Run the test to validate functionality
cargo test transfer_balance

echo "All checks passed for 'transfer_balance' test."