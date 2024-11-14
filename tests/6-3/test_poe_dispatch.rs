use version_check_macro::version_gate;
use crate::proof_of_existence::{self, Call, Config};
use crate::support::Dispatch;

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
#[version_gate("0.6.3")]
fn test_call_variants() {
    // This will fail to compile if Call variants are not defined correctly
    let _create = Call::<TestConfig>::CreateClaim {
        claim: "test".to_string(),
    };
    let _revoke = Call::<TestConfig>::RevokeClaim {
        claim: "test".to_string(),
    };
}

#[test]
#[version_gate("0.6.3")]
fn test_dispatch_implementation() {
    // Verify Dispatch trait implementation
    fn assert_dispatch<T: Dispatch>() {}
    assert_dispatch::<proof_of_existence::Pallet<TestConfig>>();
}

#[test]
#[version_gate("0.6.3")]
fn test_dispatch_create_claim() {
    let mut poe = proof_of_existence::Pallet::<TestConfig>::new();
    let alice = "alice".to_string();
    let content = "test content".to_string();
    
    // Test successful create claim
    let call = Call::CreateClaim {
        claim: content.clone(),
    };
    
    assert!(poe.dispatch(alice.clone(), call).is_ok());
    assert_eq!(poe.get_claim(&content), Some(&alice));
    
    // Test duplicate claim
    let call = Call::CreateClaim {
        claim: content.clone(),
    };
    
    assert!(poe.dispatch(alice, call).is_err());
}

#[test]
#[version_gate("0.6.3")]
fn test_dispatch_revoke_claim() {
    let mut poe = proof_of_existence::Pallet::<TestConfig>::new();
    let alice = "alice".to_string();
    let bob = "bob".to_string();
    let content = "test content".to_string();
    
    // Create initial claim
    poe.create_claim(alice.clone(), content.clone()).unwrap();
    
    // Test wrong owner revoke
    let call = Call::RevokeClaim {
        claim: content.clone(),
    };
    assert!(poe.dispatch(bob, call).is_err());
    
    // Test successful revoke
    let call = Call::RevokeClaim {
        claim: content.clone(),
    };
    assert!(poe.dispatch(alice, call).is_ok());
    assert_eq!(poe.get_claim(&content), None);
}
