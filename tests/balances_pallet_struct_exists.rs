#[path = "../src/balances.rs"]
mod balances;

#[test]
fn test_pallet_struct_exists() {
    // Try to create an instance of the Pallet struct
    let _pallet = balances::Pallet {};
}
