#![feature(proc_macro_hygiene)]
use version_check_macro::{version_gate, version_range};

#[path = "2-1/test_pallet_struct_exists.rs"]
#[version_range("=0.2.1")]
mod test_pallet_struct_exists;

#[path = "2-2/test_balances_pallet_implementation.rs"]
#[version_gate("0.2.2")]
mod test_balances_pallet_implementation;

#[path = "2-3/test_balances_interactions.rs"]
#[version_gate("0.2.3")]
mod test_balances_interactions;
