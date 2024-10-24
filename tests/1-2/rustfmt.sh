#!/bin/bash
./tests/helpers/update_version.sh "0.1.2"
if [ -e rustfmt.toml ]; then
    echo '`rustfmt.toml` found'
else
    echo "\`rustfmt.toml\` not found in $(pwd)"
    exit 1
fi
