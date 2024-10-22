#[path = "../src/balances.rs"]
mod balances;

#[test]
#[cfg(not(feature = "early"))]
fn test_pallet_contains_balances_field() {
    use std::collections::BTreeMap;

    // Create an instance of Pallet with the balances field
    let pallet = balances::Pallet {
        balances: BTreeMap::new(),
    };

    // Ensure the balances field is of type BTreeMap<String, u128>
    let _balances: &BTreeMap<String, u128> = &pallet.balances;
}
