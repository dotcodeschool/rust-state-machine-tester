#!/bin/bash

set -e

# Paths to files
BALANCES_FILE="src/balances.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check if `Config` trait in balances.rs inherits from system::Config
if grep -q "pub trait Config: crate::system::Config" "$BALANCES_FILE"; then
    echo "Found inheritance of system::Config in balances::Config trait."
    
    # Step 1a: Ensure `AccountId` is not defined within the `Config` trait in balances.rs
    # This check captures only the `Config` trait block to verify `AccountId` isn't defined there.
    if awk '/pub trait Config: crate::system::Config/,/}/' "$BALANCES_FILE" | grep -q "type AccountId"; then
        echo "Error: type AccountId should be removed from balances::Config when inherited from system::Config."
        exit 1
    else
        echo "Confirmed: AccountId is inherited from system::Config in balances::Config and not redefined."
    fi
else
    echo "Error: Config trait in balances.rs does not inherit from system::Config."
    exit 1
fi

# Step 2: Check if TestConfig implements system::Config in balances.rs tests
if grep -q "impl crate::system::Config for TestConfig" "$BALANCES_FILE"; then
    echo "Found implementation of system::Config for TestConfig in balances.rs tests."
else
    echo "Error: TestConfig does not implement system::Config in balances.rs tests."
    exit 1
fi

# Step 3: Confirm that AccountId is not redefined within balances::Config for Runtime in main.rs
# Scope check within `impl balances::Config for Runtime` only
if grep -q "impl balances::Config for Runtime" "$MAIN_FILE"; then
    if awk '/impl balances::Config for Runtime/,/}/' "$MAIN_FILE" | grep -q "type AccountId"; then
        echo "Error: AccountId should not be redefined in balances::Config for Runtime in main.rs."
        exit 1
    else
        echo "Confirmed: AccountId is not redefined in balances::Config implementation for Runtime in main.rs."
    fi
else
    echo "Error: balances::Config implementation for Runtime not found in main.rs."
    exit 1
fi

# Step 4: Verify successful compilation and test execution
cargo test --quiet

echo "All checks passed: Tight coupling of Balances to System successfully implemented."