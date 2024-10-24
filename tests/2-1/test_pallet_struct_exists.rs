use version_check_macro::version_range;

#[path = "../../src/balances.rs"]
mod balances;

#[test]
#[version_range("=0.2.1")]
fn test_pallet_struct_exists() {
    // Try to create an instance of the Pallet struct
    let _pallet = balances::Pallet {};
    assert!(true)
}
