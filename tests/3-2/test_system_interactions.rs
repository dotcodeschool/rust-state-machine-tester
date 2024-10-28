use version_check_macro::version_gate;

#[path = "../../src/system.rs"]
mod system;

#[test]
#[version_gate("0.3.2")]
fn test_system_functionality() {
    // Create a new instance
    let mut pallet = system::Pallet::new();
    
    // Test initial state
    assert_eq!(pallet.block_number(), 0u32, "Initial block number should be 0");
    
    // Test block number increment
    pallet.inc_block_number();
    assert_eq!(pallet.block_number(), 1u32, "Block number should be 1 after increment");
    pallet.inc_block_number();
    assert_eq!(pallet.block_number(), 2u32, "Block number should be 2 after increment");
    pallet.inc_block_number();
    assert_eq!(pallet.block_number(), 3u32, "Block number should be 3 after increment");
    
    // Test nonce increment for new account
    let alice = "alice".to_string();
    pallet.inc_nonce(&alice);
}
