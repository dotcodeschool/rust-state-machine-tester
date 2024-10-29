#!/bin/bash

# Function to check for struct in file and update version if found
# Parameters:
#   $1: File path to check
#   $2: Struct definition to search for
#   $3: Version to update to
check_struct_and_update_version() {
    local file_path="$1"
    local struct_definition="$2"
    local version="$3"

    # Check if file exists
    if [ ! -f "$file_path" ]; then
        echo "Error: File $file_path not found"
        return 1
    fi

    # Check if struct exists in file
    if grep -q "$struct_definition" "$file_path"; then
        "./tests/helpers/update_version.sh" "$version"
        return 0
    fi
    
    return 1
}

# Execute the function if script is called directly (not sourced)
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Usage: $0 <file_path> <struct_definition> <version>"
        exit 1
    fi
    
    check_struct_and_update_version "$1" "$2" "$3"
fi