use crate::{Runtime, RuntimeCall, balances, support};

#[test]
#[version_gate("0.5.7")]
fn test_nested_call_structure() {
    // This will fail to compile if RuntimeCall is not structured correctly
    let _call = RuntimeCall::Balances(
        balances::Call::Transfer {
            to: "bob".to_string(),
            amount: 100,
        }
    );
}

#[test]
#[version_gate("0.5.7")]
fn test_nested_dispatch_execution() {
    let mut runtime = Runtime::new();
    let alice = "alice".to_string();
    let bob = "bob".to_string();
    
    runtime.balances.set_balance(&alice, 100);
    
    // Test successful nested dispatch
    let call = RuntimeCall::Balances(
        balances::Call::Transfer {
            to: bob.clone(),
            amount: 50,
        }
    );
    
    assert!(runtime.dispatch(alice.clone(), call).is_ok());
    assert_eq!(runtime.balances.balance(&alice), 50);
    assert_eq!(runtime.balances.balance(&bob), 50);
    
    // Test failed nested dispatch
    let call = RuntimeCall::Balances(
        balances::Call::Transfer {
            to: bob,
            amount: 100,
        }
    );
    
    assert!(runtime.dispatch(alice.clone(), call).is_err());
}
