#!/bin/bash
./tests/helpers/update_version.sh "0.5.2"

MAIN_FILE="src/main.rs"

# Check if RuntimeCall enum exists
if ! grep -q "pub enum RuntimeCall" "$MAIN_FILE"; then
    echo "RuntimeCall enum not found"
    exit 1
fi

# Check type definitions in types module
if ! grep -q "pub type Extrinsic = crate::support::Extrinsic<AccountId, crate::RuntimeCall>" "$MAIN_FILE"; then
    if ! grep -q "pub type Extrinsic = crate::support::Extrinsic<.*AccountId.*RuntimeCall.*>" "$MAIN_FILE"; then
        echo "Extrinsic type not defined correctly"
        exit 1
    fi
fi

if ! grep -q "pub type Header = crate::support::Header<BlockNumber>" "$MAIN_FILE"; then
    if ! grep -q "pub type Header = crate::support::Header<.*BlockNumber.*>" "$MAIN_FILE"; then
        echo "Header type not defined correctly"
        exit 1
    fi
fi

if ! grep -q "pub type Block = crate::support::Block<Header, Extrinsic>" "$MAIN_FILE"; then
    if ! grep -q "pub type Block = crate::support::Block<.*Header.*Extrinsic.*>" "$MAIN_FILE"; then
        echo "Block type not defined correctly"
        exit 1
    fi
fi

echo "All type definitions are correct!"