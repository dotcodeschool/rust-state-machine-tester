use std::process::Command;

use version_check_macro::version_gate;

#[path = "../../src/balances.rs"]
mod balances;

#[test]
#[version_gate("0.2.5")]
fn test_balances_transfer() {
    let mut pallet = balances::Pallet::new();
    
    // Set up initial balance
    pallet.set_balance(&"Alice".to_string(), 100);
    assert_eq!(pallet.balance(&"Alice".to_string()), 100);
    assert_eq!(pallet.balance(&"Bob".to_string()), 0);
    
    // Test transfer with insufficient funds (should return some kind of error)
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
}