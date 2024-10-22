#[path = "../src/balances.rs"]
mod balances;

#[test]
#[cfg(not(feature = "early"))]
fn test_balances_pallet_implementation() {
    use std::collections::BTreeMap;

    // Create an instance using the new() method
    let pallet = balances::Pallet::new();

    // Check if the balances field is correctly initialized as an empty BTreeMap
    assert!(pallet.balances.is_empty(), "Expected 'balances' to be initialized as an empty BTreeMap.");
}
