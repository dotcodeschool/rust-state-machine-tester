BALANCES_FILE="src/balances.rs"

# Extract the impl block - modified to handle generic impl blocks
IMPL_BLOCK=$(awk '/impl.*Pallet/,/^}/' "$BALANCES_FILE")

# Extract and check transfer function
TRANSFER_FN=$(echo "$IMPL_BLOCK" | awk '/pub fn transfer/,/\}/')
if [ -z "$TRANSFER_FN" ]; then
    echo "Missing transfer function"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "&mut self"; then
    echo "transfer function must take &mut self as first parameter"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "caller:.*,"; then
    echo "transfer function must take caller parameter"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "to:.*,"; then
    echo "transfer function must take to parameter"
    exit 1
fi
if ! echo "$TRANSFER_FN" | grep -q "amount:.*"; then
    echo "transfer function must take amount parameter"
    exit 1
fi
RETURN_TYPE=$(echo "$TRANSFER_FN" | grep -o "\->.*{" | sed 's/{$//' | tr -d '\n')
if echo "$RETURN_TYPE" | grep -q "\-> *\([[:alnum:]_]*::\)*DispatchResult"; then
    echo "Transfer function has valid return type"
else
    echo "transfer function must return Result or DispatchResult"
    exit 1
fi