#[test]
fn foo() {
    std::thread::sleep(std::time::Duration::from_millis(500));
    assert_eq!(1, 1);
}
