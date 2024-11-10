#![feature(proc_macro_hygiene)]
use version_check_macro::{version_range, version_gate};

// --------------------------------
// Declare modules for 5-1
// --------------------------------
#[cfg(test)]
#[path = "../src/support.rs"]
pub mod support;

#[cfg(test)]
#[path = "../src/system.rs"]
pub mod system;

#[cfg(test)]
#[path = "../src/balances.rs"]
pub mod balances;

// --------------------------------
// End of 5-1 modules
// --------------------------------

#[path = "2-1/test_pallet_struct_exists.rs"]
#[version_range("=0.2.1")]
mod test_pallet_struct_exists;

#[path = "2-2/test_balances_pallet_implementation.rs"]
#[version_range(">=0.2.2, <0.4.3")]
mod test_balances_pallet_implementation;

#[path = "2-3/test_balances_interactions.rs"]
#[version_range(">=0.2.3, <0.4.3")]
mod test_balances_interactions;

#[path = "2-5/test_balances_transfer.rs"]
#[version_range(">=0.2.5, <0.4.3")]
mod test_balances_transfer;

#[path = "3-1/test_system_implementation.rs"]
#[version_range(">=0.3.1, <0.4.3")]
mod test_system_implementation;

#[path = "3-2/test_system_interactions.rs"]
#[version_range(">=0.3.2, <0.4.3")]
mod test_system_interactions;

#[path = "5-1/support_tests.rs"]
#[version_gate("0.5.1")]
mod support_tests;

#[path = "5-2/test_block_types.rs"]
#[version_gate("0.5.2")]
mod block_types_tests;