# Function to add a feature if it doesn't already exist in Cargo.toml
add_feature_if_not_exists() {
    # Path to the Cargo.toml file
    local CARGO_TOML="Cargo.toml"

    # Define the feature section and feature you want to add
    local FEATURES_SECTION="^\[features\]"
    local FEATURE_EARLY="^early = \[\]$"  # Exact match for the feature

    # Check if Cargo.toml contains a [features] section (using regex for exact match)
    if grep -q "$FEATURES_SECTION" "$CARGO_TOML"; then
        echo "Features section already exists in Cargo.toml"
    else
        echo "Adding [features] section to Cargo.toml"
        echo "" >> "$CARGO_TOML"
        echo "[features]" >> "$CARGO_TOML"
    fi

    # Check if the "early" feature is already defined
    if grep -qx "$FEATURE_EARLY" "$CARGO_TOML"; then
        echo "Feature 'early' already exists in Cargo.toml"
    else
        echo "Adding feature 'early' to Cargo.toml"
        echo "early = []" >> "$CARGO_TOML"
    fi
}

add_feature_if_not_exists