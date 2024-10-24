use version_check_macro::version_gate;

#[path = "../../src/balances.rs"]
mod balances;

#[test]
#[version_gate("0.2.2")]
fn test_balances_pallet_implementation() {

    // Create an instance using the new() method
    let _pallet: balances::Pallet = balances::Pallet::new();
    assert!(true)
}
