use crate::{Runtime, RuntimeCall, support, types};

#[test]
#[version_gate("0.5.4")]
fn test_runtime_dispatch() {
    let mut runtime = Runtime::new();
    let alice = "alice".to_string();
    let bob = "bob".to_string();
    
    // Set up initial balance
    runtime.balances.set_balance(&alice, 100);
    
    // Test successful dispatch
    let call = RuntimeCall::BalancesTransfer {
        to: bob.clone(),
        amount: 50,
    };
    
    assert!(runtime.dispatch(alice.clone(), call).is_ok());
    assert_eq!(runtime.balances.balance(&alice), 50);
    assert_eq!(runtime.balances.balance(&bob), 50);
    
    // Test failed dispatch (insufficient funds)
    let call = RuntimeCall::BalancesTransfer {
        to: bob,
        amount: 100,
    };
    
    assert!(runtime.dispatch(alice.clone(), call).is_err());
}

#[test]
#[version_gate("0.5.4")]
fn test_runtime_call_definition() {
    // This test will fail to compile if RuntimeCall is not defined correctly
    let _call = RuntimeCall::BalancesTransfer {
        to: "bob".to_string(),
        amount: 100u128,
    };
}
