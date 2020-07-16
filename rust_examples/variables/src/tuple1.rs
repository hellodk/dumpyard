fn main() {
    let tup = (500, 6.4, 1);
    let (_x, _y, _z) = tup;
    println!("The value of y is: {}", _y);
    println!("The value of y is: {}", tup.2);
}
