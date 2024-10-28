use version_check_macro::version_gate;

#[path = "../../src/system.rs"]
mod system;

#[test]
#[version_gate("0.3.1")]
fn test_system_implementation() {
    let _pallet = system::Pallet::new();
    assert!(true)
}
