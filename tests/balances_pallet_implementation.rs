#[path = "../src/balances.rs"]
mod balances;

#[test]
#[cfg(not(feature = "early"))]
fn test_balances_pallet_implementation() {

    // Create an instance using the new() method
    let _pallet = balances::Pallet::new();
    assert!(true)
}
