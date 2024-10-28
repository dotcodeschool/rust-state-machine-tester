use version_check_macro::version_gate;

#[path = "../../src/system.rs"]
mod system;

#[test]
#[version_gate("0.3.2")]
fn test_system_functionality() {
    // Create a new instance
    let mut pallet = system::Pallet::new();
    
    // Test initial state
    assert_eq!(pallet.block_number(), 0, "Initial block number should be 0");
    
    // Test block number increment
    pallet.inc_block_number();
    assert_eq!(pallet.block_number(), 1, "Block number should be 1 after increment");
    
    // Test nonce increment for new account
    let alice = "alice".to_string();
    pallet.inc_nonce(&alice);
    assert_eq!(pallet.nonce.get(&alice), Some(&1), "Alice's nonce should be 1");
    
    // Test nonce increment for existing account
    pallet.inc_nonce(&alice);
    assert_eq!(pallet.nonce.get(&alice), Some(&2), "Alice's nonce should be 2");
    
    // Test nonce for non-existent account
    let bob = "bob".to_string();
    assert_eq!(pallet.nonce.get(&bob), None, "Bob's nonce should not exist");
}
