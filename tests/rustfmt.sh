#!/bin/bash
echo "Current working directory: $(pwd)"
if [ -e rustfmt.toml ]; then
    echo '`rustfmt.toml` found';
else
    echo '`rustfmt.toml` not found'
    exit 1
fi