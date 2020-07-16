mod fibonacci;
mod sayhi;

use fibonacci::fibonacci;
// use say hi;

fn main() {
    println!("Hello, world!");
    println!("{}", fibonacci(5));
    sayhi::printing();
}
