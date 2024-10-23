#!/bin/bash

if [ -f "src/balances.rs" ]; then
    echo "'src/balances.rs' found"
else
    echo "'src/balances.rs' not found in $(pwd)"
    exit 1
fi