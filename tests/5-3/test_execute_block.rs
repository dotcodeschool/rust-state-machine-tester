use crate::{support, system, Runtime, RuntimeCall};

#[test]
#[version_gate("0.5.3")]
fn test_execute_block_implementation() {
    // Check that Runtime implements Dispatch
    fn assert_implements_dispatch<T: support::Dispatch>() {}
    assert_implements_dispatch::<Runtime>();
    
    let mut runtime = Runtime::new();
    
    // Create a block with incorrect block number
    let wrong_block = support::Block {
        header: support::Header { block_number: 2 },
        extrinsics: vec![],
    };
    
    // Should fail due to incorrect block number
    assert!(runtime.execute_block(wrong_block).is_err());
    
    // Create a valid block
    let valid_block = support::Block {
        header: support::Header { block_number: 1 },
        extrinsics: vec![
            support::Extrinsic {
                caller: "alice".to_string(),
                call: RuntimeCall {},
            },
        ],
    };
    
    // Should succeed with valid block
    assert!(runtime.execute_block(valid_block).is_ok());
}