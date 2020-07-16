fn main() {
    println!("Hello, world!");

    another_function();
    some_function(43);
    some_function(-7);
    a_function(7, 3);

    // Return values
    let x = five();
    println!("The value of x is: {}", x);

    let x = plus_one(x);
    println!("The value of x is: {}", x);
}

fn another_function() {
    println!("Another function.");
}

fn some_function(x: i32) {
    println!("The value of x is: {}", x);
}

fn a_function(x: i32, y: i32) {
    println!("The value of x is: {}", x);
    println!("The value of y is: {}", y);
    println!("{} + {} = {}", x, y, x + y);
}

fn five() -> i32 {
    5
}

fn plus_one(x: i32) -> i32 {
    x + 1
}
