#!/bin/bash

set -e

# Paths to files
BALANCES_FILE="src/balances.rs"
MAIN_FILE="src/main.rs"

# Step 1: Check if `Config` trait is defined in balances.rs
if grep -q "pub trait Config" "$BALANCES_FILE"; then
    echo "Found Config trait in balances.rs."
else
    echo "Error: Config trait not found in balances.rs."
    exit 1
fi

# Step 2: Check if `Config` trait inherits from `system::Config` and defines `Balance`
if grep -q "pub trait Config: crate::system::Config" "$BALANCES_FILE"; then
    echo "Config trait inherits from system::Config."
    
    # Step 2a: Ensure that `AccountId` is not defined within the balances::Config trait block.
    # Extract only the `Config` trait definition block and check for `type AccountId` within that scope.
    if awk '/pub trait Config: crate::system::Config/,/}/' "$BALANCES_FILE" | grep -q "type AccountId"; then
        echo "Error: type AccountId should be removed from balances::Config when inherited from system::Config."
        exit 1
    else
        echo "Confirmed: AccountId is inherited from system::Config in balances::Config and is not redefined."
    fi
else
    # Alternative: Check if `AccountId` and `Balance` are defined directly in Config
    if grep -q "type AccountId: Ord + Clone" "$BALANCES_FILE" && \
       grep -q "type Balance: Zero + CheckedSub + CheckedAdd + Copy" "$BALANCES_FILE"; then
        echo "Config trait defines AccountId and Balance directly."
    else
        echo "Error: Config trait must either inherit system::Config or define AccountId and Balance directly."
        exit 1
    fi
fi

# Step 3: Check if Pallet struct is defined with a single generic parameter T implementing Config
if grep -q "pub struct Pallet<T: Config>" "$BALANCES_FILE"; then
    echo "Found Pallet struct with generic type T implementing Config."
else
    echo "Error: Pallet struct not defined with generic type T implementing Config."
    exit 1
fi

# Step 4: Check for usage of associated types with T:: syntax in functions
if grep -q "balances: BTreeMap<T::AccountId, T::Balance>" "$BALANCES_FILE" && \
   grep -q "self.balances.get(who).unwrap_or(&T::Balance::zero())" "$BALANCES_FILE" && \
   grep -q "self.balances.insert(caller, new_caller_balance)" "$BALANCES_FILE" && \
   grep -q "self.balances.insert(to, new_to_balance)" "$BALANCES_FILE"; then
    echo "Found usage of associated types with T:: syntax in functions."
else
    echo "Error: Incorrect or missing usage of associated types (T::AccountId, T::Balance) in functions."
    exit 1
fi

# Step 5: Check if Runtime implements Config trait for balances in main.rs and uses Self for balances instantiation
if grep -q "impl balances::Config for Runtime" "$MAIN_FILE" && \
   grep -q "balances: balances::Pallet<Self>" "$MAIN_FILE"; then
    # Scoped check for `type AccountId` only within `impl balances::Config for Runtime` block if inherited
    if grep -q "pub trait Config: crate::system::Config" "$BALANCES_FILE"; then
        if awk '/impl balances::Config for Runtime/,/}/' "$MAIN_FILE" | grep -q "type AccountId"; then
            echo "Error: AccountId should not be redefined in balances::Config for Runtime when inherited."
            exit 1
        else
            echo "Confirmed: AccountId is not redefined in balances::Config implementation for Runtime in inherited setup."
        fi
    else
        echo "Found implementation of balances::Config for Runtime with direct AccountId definition."
    fi
else
    echo "Error: Runtime does not implement balances::Config trait, or balances field does not use Pallet<Self>."
    exit 1
fi

# Run tests to confirm setup
cargo test --quiet

echo "All checks passed: Balances Pallet correctly implemented with Config trait."