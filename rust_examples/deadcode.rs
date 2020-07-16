fn used_function() {}

// `#[allow(dead_code)]` is an attribute that disables the `dead_code` lint
#[allow(dead_code)]
fn unused_function() {}

// #[allow(dead_code)]
fn noisy_unused_function() {}

fn main() {
    used_function();
}