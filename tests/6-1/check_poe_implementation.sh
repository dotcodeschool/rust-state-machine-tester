#!/bin/bash
./tests/helpers/update_version.sh "0.6.1"

POE_FILE="src/proof_of_existence.rs"
MAIN_FILE="src/main.rs"

# Check if proof_of_existence.rs exists
if [ ! -f "$POE_FILE" ]; then
    echo "proof_of_existence.rs file not found"
    exit 1
fi

# Check if module is imported in main.rs
if ! grep -q "mod proof_of_existence;" "$MAIN_FILE"; then
    echo "proof_of_existence module not imported in main.rs"
    exit 1
fi

# Check Config trait definition
if ! grep -q "pub trait Config: crate::system::Config" "$POE_FILE"; then
    echo "Config trait not defined correctly"
    exit 1
fi

if ! grep -q "type Content: Debug + Ord" "$POE_FILE"; then
    echo "Content type not defined with correct bounds"
    exit 1
fi

# Check Pallet struct definition
if ! grep -q "#\[derive(Debug)\]" "$POE_FILE"; then
    echo "Debug derive missing for Pallet"
    exit 1
fi

if ! grep -q "pub struct Pallet<T: Config>" "$POE_FILE"; then
    echo "Pallet struct not defined correctly"
    exit 1
fi

# Check claims field
if ! grep -q "claims:.*BTreeMap<T::Content,.*T::AccountId>" "$POE_FILE"; then
    echo "claims field not defined correctly"
    exit 1
fi

# Check new() implementation
if ! grep -q "pub fn new().*->.*Self" "$POE_FILE"; then
    echo "new() function not defined correctly"
    exit 1
fi

if ! grep -q "Self.*{.*claims:.*BTreeMap::new().*}" "$POE_FILE"; then
    echo "new() function not implemented correctly"
    exit 1
fi

# Run Rust tests
cargo test test_pallet_creation
cargo test test_config_bounds

echo "Proof of Existence pallet implementation is correct!"
