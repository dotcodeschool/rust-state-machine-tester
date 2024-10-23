#[path = "../src/balances.rs"]
mod balances;

let output = Command::new("./tests/add_feature.sh").output();

#[test]
#[cfg(not(feature = "early"))]
fn test_balances_interactions() {
    // Create an instance using the new() method
    let mut pallet: balances::Pallet = balances::Pallet::new();
    // Set the balance of an account `who` to some `amount`.
    pallet.set_balance(&"Alice".to_string(), 100);
    // Get the balance of an account `who`.
    let balance = pallet.balance(&"Alice".to_string());
    // Assert that the balance is correct
    assert_eq!(balance, 100);
    // Code should not panic if we try to get the balance of an account that does not exist
    let balance = pallet.balance(&"Bob".to_string());
}