use crate::{Runtime, RuntimeCall, support, types};

#[test]
#[version_gate("0.5.5")]
fn test_block_execution() {
    let mut runtime = Runtime::new();
    let alice = "alice".to_string();
    let bob = "bob".to_string();
    
    runtime.balances.set_balance(&alice, 100);
    
    // Test valid block
    let block = types::Block {
        header: support::Header { block_number: 1 },
        extrinsics: vec![
            support::Extrinsic {
                caller: alice.clone(),
                call: RuntimeCall::BalancesTransfer {
                    to: bob.clone(),
                    amount: 50,
                },
            },
        ],
    };
    
    assert!(runtime.execute_block(block).is_ok());
    assert_eq!(runtime.balances.balance(&alice), 50);
    assert_eq!(runtime.balances.balance(&bob), 50);
    
    // Test invalid block number
    let invalid_block = types::Block {
        header: support::Header { block_number: 3 },  // Should be 2
        extrinsics: vec![],
    };
    
    assert!(runtime.execute_block(invalid_block).is_err());
}
