#!/bin/bash
output=$(cargo run)
if [ $? -ne 0 ]; then
echo "Test Failed: The program did not exit successfully."
exit 1
elif [[ $output == *"Hello, world!"* ]] && [[ $output != *"panic"* ]]; then
echo "Congrats! You've successfully initialized your Rust Project."
else
echo "Looks like `cargo run` is failing to execute. Maybe there's a bug in your code?"
exit 1
fi
