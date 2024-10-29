use version_check_macro::version_range;

#[path = "../../src/system.rs"]
mod system;

#[test]
#[version_range(">=0.3.1, <0.4.3")]
fn test_system_implementation() {
    let _pallet = system::Pallet::new();
    assert!(true)
}
