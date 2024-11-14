#!/bin/bash
./tests/helpers/update_version.sh "0.6.4"

MAIN_FILE="src/main.rs"

# Extract types module block
TYPES_BLOCK=$(awk '/mod types/{p=1;print;next} p&&/^}$/{print;p=0} p{print}' "$MAIN_FILE")

# Check Content type definition
if ! echo "$TYPES_BLOCK" | grep -q "pub.*type.*Content.*=.*&'static.*str"; then
    echo "Content type not defined correctly"
    exit 1
fi

# Check RuntimeCall enum
if ! grep -q "ProofOfExistence(proof_of_existence::Call<Runtime>)" "$MAIN_FILE"; then
    echo "ProofOfExistence variant not added to RuntimeCall"
    exit 1
fi

# Check Runtime struct
if ! grep -q "proof_of_existence:.*proof_of_existence::Pallet<Self>" "$MAIN_FILE"; then
    echo "proof_of_existence field not added to Runtime"
    exit 1
fi

# Check Config implementation
if ! grep -q "impl.*proof_of_existence::Config.*for.*Runtime" "$MAIN_FILE"; then
    echo "proof_of_existence::Config not implemented for Runtime"
    exit 1
fi

if ! grep -q "type.*Content.*=.*types::Content" "$MAIN_FILE"; then
    echo "Content type not set in Config implementation"
    exit 1
fi

# Check initialization in new()
if ! grep -q "proof_of_existence:.*Pallet::new()" "$MAIN_FILE"; then
    echo "proof_of_existence not initialized in new()"
    exit 1
fi

# Check dispatch implementation
DISPATCH_BLOCK=$(awk '/impl.*support::Dispatch.*for.*Runtime/{p=1;print;next} p&&/^}$/{print;p=0} p{print}' "$MAIN_FILE")

if ! echo "$DISPATCH_BLOCK" | grep "ProofOfExistence(.*call.*)"; then
    echo "ProofOfExistence dispatch not implemented"
    exit 1
fi

echo "Proof of Existence integration is correct!"
