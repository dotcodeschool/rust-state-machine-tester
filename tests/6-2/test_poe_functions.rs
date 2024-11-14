use crate::proof_of_existence::{self, Config};

// Test configuration
struct TestConfig;
impl crate::system::Config for TestConfig {
    type AccountId = String;
    type BlockNumber = u32;
    type Nonce = u32;
}
impl Config for TestConfig {
    type Content = String;
}

#[test]
#[version_gate("0.6.2")]
fn test_get_claim() {
    let mut poe = proof_of_existence::Pallet::<TestConfig>::new();
    let content = "test content".to_string();
    let alice = "alice".to_string();
    
    // Initial state should be empty
    assert_eq!(poe.get_claim(&content), None);
    
    // After creating claim, should return owner
    poe.create_claim(alice.clone(), content.clone()).unwrap();
    assert_eq!(poe.get_claim(&content), Some(&alice));
}

#[test]
#[version_gate("0.6.2")]
fn test_create_claim() {
    let mut poe = proof_of_existence::Pallet::<TestConfig>::new();
    let content = "test content".to_string();
    let alice = "alice".to_string();
    let bob = "bob".to_string();
    
    // First claim should succeed
    assert!(poe.create_claim(alice, content.clone()).is_ok());
    
    // Second claim should fail
    assert!(poe.create_claim(bob, content).is_err());
}

#[test]
#[version_gate("0.6.2")]
fn test_revoke_claim() {
    let mut poe = proof_of_existence::Pallet::<TestConfig>::new();
    let content = "test content".to_string();
    let alice = "alice".to_string();
    let bob = "bob".to_string();
    
    // Revoking non-existent claim should fail
    assert!(poe.revoke_claim(alice.clone(), content.clone()).is_err());
    
    // Create claim
    poe.create_claim(alice.clone(), content.clone()).unwrap();
    
    // Wrong owner should fail to revoke
    assert!(poe.revoke_claim(bob, content.clone()).is_err());
    
    // Correct owner should succeed
    assert!(poe.revoke_claim(alice, content).is_ok());
}

#[test]
#[version_gate("0.6.2")]
fn test_poe_integration() {
    let mut poe = proof_of_existence::Pallet::<TestConfig>::new();
    let content = "test content".to_string();
    let alice = "alice".to_string();
    let bob = "bob".to_string();
    
    // Initial state
    assert_eq!(poe.get_claim(&content), None);
    
    // Create claim
    assert!(poe.create_claim(alice.clone(), content.clone()).is_ok());
    assert_eq!(poe.get_claim(&content), Some(&alice));
    
    // Failed claim attempt
    assert!(poe.create_claim(bob.clone(), content.clone()).is_err());
    
    // Failed revoke attempt
    assert!(poe.revoke_claim(bob, content.clone()).is_err());
    
    // Successful revoke
    assert!(poe.revoke_claim(alice.clone(), content.clone()).is_ok());
    assert_eq!(poe.get_claim(&content), None);
    
    // Can claim again after revoke
    assert!(poe.create_claim(alice, content.clone()).is_ok());
}
