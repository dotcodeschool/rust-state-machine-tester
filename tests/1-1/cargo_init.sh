#!/bin/bash
./tests/helpers/update_version.sh "0.1.1"
output=$(cargo run)
status=$?

echo $output

if [ $status -ne 0 ]; then    
    echo "Error: command \`cargo run\` exited with code $status"
    exit $status
fi
