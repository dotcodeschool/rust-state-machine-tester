#!/bin/bash

# Function to update the crate version in Cargo.toml
update_crate_version() {
    # Path to the Cargo.toml file
    local CARGO_TOML="Cargo.toml"
    # New version to set
    local NEW_VERSION="$1"

    if [ -z "$NEW_VERSION" ]; then
        echo "Error: Please provide a version number"
        return 1
    fi

    # Check if the file exists
    if [ ! -f "$CARGO_TOML" ]; then
        echo "Error: Cargo.toml not found"
        return 1
    fi

    # Use sed to replace the version line
    if sed -i.bak "s/^version = \".*\"/version = \"$NEW_VERSION\"/" "$CARGO_TOML"; then
        echo "Successfully updated version to $NEW_VERSION"
        # Remove the backup file created by sed
        rm "${CARGO_TOML}.bak"
    else
        echo "Failed to update version"
        return 1
    fi
}

cargo add version-check-macro --path "./version-check-macro"

update_crate_version "$1"