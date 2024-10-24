#!/bin/bash

# Path to the balances.rs file
BALANCES_FILE="src/balances.rs"

# Check if the init_balances test is defined
if grep -q "@\[test\]" "$BALANCES_FILE" && grep -q "fn init_balances()" "$BALANCES_FILE"; then
    echo "Test 'init_balances' is defined."
else
    echo "Error: Test 'init_balances' is not defined."
    exit 1
fi

# Check if Pallet is initialized in the test
if grep -q "let mut balances = super::Pallet::new();" "$BALANCES_FILE"; then
    echo "Pallet is initialized correctly."
else
    echo "Error: Pallet is not initialized correctly."
    exit 1
fi

# Check if the balance and set_balance methods are called
if grep -q "balances.balance" "$BALANCES_FILE" && grep -q "balances.set_balance" "$BALANCES_FILE"; then
    echo "balance and set_balance methods are used."
else
    echo "Error: balance or set_balance methods are not used correctly."
    exit 1
fi

# Check for correct assertions
if grep -q "assert_eq!(balances.balance(&\"alice\".to_string()), 0);" "$BALANCES_FILE" && \
   grep -q "assert_eq!(balances.balance(&\"alice\".to_string()), 100);" "$BALANCES_FILE" && \
   grep -q "assert_eq!(balances.balance(&\"bob\".to_string()), 0);" "$BALANCES_FILE"; then
    echo "Assertions are correct."
else
    echo "Error: Assertions are incorrect or missing."
    exit 1
fi

cargo test init_balances

echo "All checks passed for 'init_balances' test."