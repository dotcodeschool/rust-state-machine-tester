#!/bin/bash
./tests/helpers/update_version.sh "0.3.2"

source ./tests/helpers/check_struct_and_update_version.sh
check_struct_and_update_version "src/balances.rs" "pub struct Pallet<AccountId, Balance>" "0.4.3"

cargo test test_system_interactions