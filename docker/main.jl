using RustToolChain
run(pipeline(`sh -lc "echo 'fn main(){println!(\"Hello, world!\");}' | $(rustc()) -o hello - && ./hello"`))