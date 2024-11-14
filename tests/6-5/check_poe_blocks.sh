#!/bin/bash
./tests/helpers/update_version.sh "0.6.5"

MAIN_FILE="src/main.rs"

# Extract main function block - everything between fn main() and its closing brace
MAIN_BLOCK=$(awk '/fn main/{p=1;print;next} p&&/^}$/{print;p=0} p{print}' "$MAIN_FILE")

# Check if we got the main block
if [ -z "$MAIN_BLOCK" ]; then
    echo "Couldn't find main function"
    exit 1
fi

# Count number of block definitions (should be at least 2 - original block_1 and at least one new block)
BLOCK_COUNT=$(echo "$MAIN_BLOCK" | grep -c "Block.*{")
if [ "$BLOCK_COUNT" -lt 2 ]; then
    echo "Need to create at least one new block after block_1"
    exit 1
fi

# Check for ProofOfExistence extrinsics
if ! echo "$MAIN_BLOCK" | grep -q "ProofOfExistence.*Call::CreateClaim"; then
    echo "No CreateClaim extrinsics found"
    exit 1
fi

if ! echo "$MAIN_BLOCK" | grep -q "ProofOfExistence.*Call::RevokeClaim"; then
    echo "No RevokeClaim extrinsics found"
    exit 1
fi

# Extract and check block numbers
BLOCK_NUMBERS=$(echo "$MAIN_BLOCK" | grep -o "block_number:.*[0-9]" | grep -o "[0-9]")

# Verify block numbers are sequential
PREV_NUM=0
for NUM in $BLOCK_NUMBERS; do
    if [ "$NUM" -ne "$((PREV_NUM + 1))" ]; then
        echo "Block numbers must be sequential. Found gap between $PREV_NUM and $NUM"
        exit 1
    fi
    PREV_NUM=$NUM
done

# Check that each block is executed
EXECUTE_COUNT=$(echo "$MAIN_BLOCK" | grep -c "execute_block.*expect")
if [ "$EXECUTE_COUNT" -ne "$BLOCK_COUNT" ]; then
    echo "Number of execute_block calls ($EXECUTE_COUNT) doesn't match number of blocks ($BLOCK_COUNT)"
    exit 1
fi

# Check that blocks are executed in order (should appear after their definition)
BLOCK_DEFS=$(echo "$MAIN_BLOCK" | grep -n "Block.*{" | cut -d: -f1)
BLOCK_EXECS=$(echo "$MAIN_BLOCK" | grep -n "execute_block.*expect" | cut -d: -f1)

# Convert to arrays for comparison
IFS=$'\n' read -d '' -r -a DEFS <<< "$BLOCK_DEFS"
IFS=$'\n' read -d '' -r -a EXECS <<< "$BLOCK_EXECS"

for i in "${!DEFS[@]}"; do
    if [ "${EXECS[$i]}" -lt "${DEFS[$i]}" ]; then
        echo "Block execution must come after block definition"
        exit 1
    fi
done

echo "PoE blocks implementation is correct!"
