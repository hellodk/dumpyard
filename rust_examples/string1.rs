fn main() {
let mut s = String::from("Hello from Rust!");
println!("Capacity Initial {}", s.capacity()); // prints 16
println!("Initial Length {}", s.len());
s.push_str("Here I come!");
println!("New Length {}", s.len()); // prints 28
println!("New Capacity {}", s.capacity());

let s = "Hello from Rust!";
// println!("{}", s.capacity()); // compile error
println!("{}", s.len()); // prints 16

    let mut s = String::from("Hello from Rust!");
    foo(&mut s);
    println!("{:?}", s);
}

fn foo(s: &mut String) {
    s.push_str("appending foo..");
    println!("from the new function: {}", s);
}
