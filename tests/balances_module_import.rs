#[test]
fn test_balances_module_import() {
    // This will only compile if `mod balances` is properly imported in main.rs
    let _pallet = crate::balances::Pallet {};
}
