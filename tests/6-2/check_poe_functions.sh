#!/bin/bash
./tests/helpers/update_version.sh "0.6.2"

POE_FILE="src/proof_of_existence.rs"

# Check get_claim implementation
if ! grep -q "pub fn get_claim.*(&self, claim:.*&T::Content).*->.*Option<&T::AccountId>" "$POE_FILE"; then
    echo "get_claim function not defined correctly"
    exit 1
fi

# Check create_claim implementation
if ! grep -q "pub fn create_claim.*(&mut self,.*caller:.*T::AccountId,.*claim:.*T::Content).*->.*DispatchResult" "$POE_FILE"; then
    echo "create_claim function not defined correctly"
    exit 1
fi

if ! grep -q "contains_key(&claim)" "$POE_FILE"; then
    echo "create_claim should check if claim already exists"
    exit 1
fi

if ! grep -q "insert(claim,.*caller)" "$POE_FILE"; then
    echo "create_claim should insert the new claim"
    exit 1
fi

# Check revoke_claim implementation
if ! grep -q "pub fn revoke_claim.*(&mut self,.*caller:.*T::AccountId,.*claim:.*T::Content).*->.*DispatchResult" "$POE_FILE"; then
    echo "revoke_claim function not defined correctly"
    exit 1
fi

if ! grep -q "get_claim(&claim)" "$POE_FILE"; then
    echo "revoke_claim should check claim existence"
    exit 1
fi

if ! grep -q "remove(&claim)" "$POE_FILE"; then
    echo "revoke_claim should remove the claim"
    exit 1
fi

# First extract the test module block
TEST_BLOCK=$(awk '/#\[cfg\(test\)\]/{p=1;print;next} p&&/^}$/{print;p=0;exit} p{print}' "$POE_FILE")

# Check if we found the test module
if [ -z "$TEST_BLOCK" ]; then
    echo "Test module not found"
    exit 1
fi

# Then check for test function using more flexible pattern
if ! echo "$TEST_BLOCK" | grep -q "#\[test\]" || ! echo "$TEST_BLOCK" | grep -q "fn.*basic_proof_of_existence"; then
    echo "basic_proof_of_existence test not found in test module"
    exit 1
fi

# Check test content within the extracted block (more flexible patterns)
if ! echo "$TEST_BLOCK" | grep -q "create_claim.*Ok" || \
   ! echo "$TEST_BLOCK" | grep -q "get_claim.*Some" || \
   ! echo "$TEST_BLOCK" | grep -q "revoke_claim.*Ok"; then
    echo "basic_proof_of_existence test doesn't contain required assertions"
    exit 1
fi

# Run the tests
cargo test test_get_claim
cargo test test_create_claim
cargo test test_revoke_claim
cargo test test_poe_integration

echo "Proof of Existence functions implemented correctly!"
