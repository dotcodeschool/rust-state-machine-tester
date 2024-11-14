#!/bin/bash
set -e

./tests/helpers/update_version.sh "0.6.3"

POE_FILE="src/proof_of_existence.rs"

# Extract Call enum block
CALL_ENUM_BLOCK=$(awk '/pub enum Call<T: Config>/{p=1;print;next} p&&/^}$/{print;p=0} p{print}' "$POE_FILE")

if [ -z "$CALL_ENUM_BLOCK" ]; then
    echo "Call enum not defined correctly"
    exit 1
fi

# Check Call variants within the extracted block
if ! echo "$CALL_ENUM_BLOCK" | grep -q "CreateClaim.*{.*claim:.*T::Content.*}" && \
   ! echo "$CALL_ENUM_BLOCK" | grep -q "RevokeClaim.*{.*claim:.*T::Content.*}"; then
    echo "Call variants not defined correctly"
    exit 1
fi

# Extract Dispatch implementation block
DISPATCH_BLOCK=$(awk '/impl.*<.*T:.*Config>.*support::Dispatch.*for.*Pallet.*<.*T.*>/{p=1;print;next} p&&/^}$/{print;p=0} p{print}' "$POE_FILE")

if [ -z "$DISPATCH_BLOCK" ]; then
    echo "Dispatch trait not implemented correctly"
    exit 1
fi

# Check associated types in dispatch block
if ! echo "$DISPATCH_BLOCK" | grep -q "type.*Caller.*=.*T::AccountId" || \
   ! echo "$DISPATCH_BLOCK" | grep -q "type.*Call.*=.*Call<T>"; then
    echo "Associated types not defined correctly"
    exit 1
fi

# Extract dispatch function block from the DISPATCH_BLOCK
DISPATCH_FN_BLOCK=$(echo "$DISPATCH_BLOCK" | awk '/fn[[:space:]]+dispatch/{p=1} p{print} /Ok\(\)/{p=0}')

if [ -z "$DISPATCH_FN_BLOCK" ]; then
    echo "dispatch function not defined correctly"
    exit 1
fi

# Check for the match statement in the dispatch function
if ! echo "$DISPATCH_FN_BLOCK" | grep -q "match[[:space:]]*call"; then
    echo "Error: match statement not found in dispatch function."
    exit 1
fi

# Check for CreateClaim routing
if ! echo "$DISPATCH_FN_BLOCK" | grep -q "CreateClaim"; then
    echo "Error: CreateClaim not routed correctly."
    exit 1
fi

# Check for RevokeClaim routing
if ! echo "$DISPATCH_FN_BLOCK" | grep -q "RevokeClaim"; then
    echo "Error: RevokeClaim not routed correctly."
    exit 1
fi

# Check error propagation with more flexible pattern
if ! echo "$DISPATCH_FN_BLOCK" | grep -q "[?][[:space:]]*;"; then
    echo "Error propagation missing"
    exit 1
fi

cargo test test_call_variants
cargo test test_dispatch_implementation
cargo test test_dispatch_create_claim
cargo test test_dispatch_revoke_claim

echo "Proof of Existence dispatch implementation is correct!"
