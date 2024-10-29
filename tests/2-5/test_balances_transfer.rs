use version_check_macro::version_range;

#[path = "../../src/balances.rs"]
mod balances;

#[test]
#[version_range(">=0.2.5, <0.4.3")]
fn test_balances_transfer() {
    let mut pallet = balances::Pallet::new();
    
    // Set up initial balance
    pallet.set_balance(&"Alice".to_string(), 100);
    assert_eq!(pallet.balance(&"Alice".to_string()), 100);
    assert_eq!(pallet.balance(&"Bob".to_string()), 0);
    
    // Test transfer with insufficient funds (underflow condition)
    let result = pallet.transfer("Alice".to_string(), "Bob".to_string(), 150);
    assert!(result.is_err());
    
    // Balances should remain unchanged after failed transfer
    assert_eq!(pallet.balance(&"Alice".to_string()), 100);
    assert_eq!(pallet.balance(&"Bob".to_string()), 0);
    
    // Test successful transfer
    let result = pallet.transfer("Alice".to_string(), "Bob".to_string(), 50);
    assert!(result.is_ok());
    
    // Verify balances are updated correctly
    assert_eq!(pallet.balance(&"Alice".to_string()), 50);
    assert_eq!(pallet.balance(&"Bob".to_string()), 50);

    // Test overflow condition
    pallet.set_balance(&"Alice".to_string(), u128::MAX);
    let result = pallet.transfer("Bob".to_string(), "Alice".to_string(), 1);
    assert!(result.is_err());
    
    // Balances should remain unchanged after overflow attempt
    assert_eq!(pallet.balance(&"Alice".to_string()), u128::MAX);
    assert_eq!(pallet.balance(&"Bob".to_string()), 50);
}