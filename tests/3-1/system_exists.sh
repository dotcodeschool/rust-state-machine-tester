#!/bin/bash

if [ -f "src/system.rs" ]; then
    echo "'src/system.rs' found"
else
    echo "'src/system.rs' not found in $(pwd)"
    exit 1
fi