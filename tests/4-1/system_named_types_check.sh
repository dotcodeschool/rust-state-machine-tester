#!/bin/bash
./tests/helpers/update_version.sh "0.4.1"
SYSTEM_FILE="src/system.rs"

# Check type definitions exist
if ! grep -q "type AccountId = String;" "$SYSTEM_FILE"; then
    echo "Missing AccountId type definition"
    exit 1
fi
if ! grep -q "type BlockNumber = u32;" "$SYSTEM_FILE"; then
    echo "Missing BlockNumber type definition"
    exit 1
fi
if ! grep -q "type Nonce = u32;" "$SYSTEM_FILE"; then
    echo "Missing Nonce type definition"
    exit 1
fi

# Check if the Pallet struct contains the `block_number`, 'nonce' fields
if grep -q "pub struct Pallet" "$SYSTEM_FILE"; then
    if grep -q "[[:space:]]*block_number[[:space:]]*:[[:space:]]*BlockNumber" "$SYSTEM_FILE" && \
       grep -q "[[:space:]]*nonce[[:space:]]*:[[:space:]]*BTreeMap[[:space:]]*<[[:space:]]*AccountId[[:space:]]*,[[:space:]]*Nonce[[:space:]]*>" "$SYSTEM_FILE"; then
        echo "Pallet struct found in $SYSTEM_FILE and 'block_number' and 'nonce' fields are implemented correctly."
    else
        echo "Pallet struct found in $SYSTEM_FILE, but either 'block_number' or 'nonce' fields are missing or not implemented correctly. Please check your implementation. Type of 'block_number' should be 'BlockNumber' and type of 'nonce' should be 'BTreeMap<AccountId, Nonce>'."
        exit 1
    fi
else
    echo "Pallet struct not found in $SYSTEM_FILE. Please check your implementation."
    exit 1
fi

# Extract the impl block
IMPL_BLOCK=$(awk '/impl Pallet/,/^}/' "$SYSTEM_FILE")

# Extract and check block_number function
BLOCK_NUMBER_FN=$(echo "$IMPL_BLOCK" | awk '/pub fn block_number/,/\}/')
if [ -z "$BLOCK_NUMBER_FN" ]; then
    echo "Missing block_number function"
    exit 1
fi
if ! echo "$BLOCK_NUMBER_FN" | grep -q "&self"; then
    echo "block_number function must take &self as parameter"
    exit 1
fi
if ! echo "$BLOCK_NUMBER_FN" | grep -q "\-> *BlockNumber"; then
    echo "block_number function must return BlockNumber"
    exit 1
fi

# Extract and check inc_nonce function
INC_NONCE_FN=$(echo "$IMPL_BLOCK" | awk '/pub fn inc_nonce/,/\}/')
if [ -z "$INC_NONCE_FN" ]; then
    echo "Missing inc_nonce function"
    exit 1
fi
if ! echo "$INC_NONCE_FN" | grep -q "&mut self"; then
    echo "inc_nonce function must take &mut self as first parameter"
    exit 1
fi
if ! echo "$INC_NONCE_FN" | grep -q "who: *&AccountId"; then
    echo "inc_nonce function must take who parameter of type &AccountId"
    exit 1
fi

# If we get here, run the tests
cargo test test_system_implementation
