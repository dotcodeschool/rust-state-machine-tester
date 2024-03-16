use std::process::{Command, Child};
use std::time::Duration;
use std::thread::sleep;
use std::env;
use std::process;

const BINARY_PATH_FLAG: &str = "--binary-path=";

fn main() {
    println!("Welcome to the Rust State Machine course!\n");

    let args: Vec<String> = env::args().collect();
    let binary_path = args.iter().find(|arg| arg.starts_with(BINARY_PATH_FLAG));

    let binary_path = match binary_path {
        Some(path) => &path[BINARY_PATH_FLAG.len()..],
        None => {
            println!("The --binary-path flag must be specified");
            process::exit(1);
        }
    };

    println!("Binary Path = {}\n", binary_path);

    let mut cmd = match run_binary(binary_path) {
        Ok(cmd) => cmd,
        Err(err) => {
            println!("Error when starting process: {}", err);
            process::exit(1);
        }
    };

    sleep(Duration::from_secs(1));

    match cmd.kill() {
        Ok(_) => println!("Waiting for process to exit {}", binary_path),
        Err(err) => println!("Error when killing process: {}", err),
    }

    match cmd.wait() {
        Ok(_) => println!("Tests done"),
        Err(err) => println!("Error when waiting for process: {}", err),
    }
}

fn run_binary(binary_path: &str) -> std::io::Result<Child> {
    Command::new(binary_path).spawn()
}