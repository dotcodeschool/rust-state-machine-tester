use version_check_macro::version_range;

#[path = "../../src/balances.rs"]
mod balances;

#[test]
#[version_range(">=0.2.2, <0.4.3")]
fn test_balances_pallet_implementation() {

    // Create an instance using the new() method
    let _pallet: balances::Pallet = balances::Pallet::new();
    assert!(true)
}
