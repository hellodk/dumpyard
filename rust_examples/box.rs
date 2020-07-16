fn main() {
    let b = Box::new(5);
    let s = Box::new("string");
    println!("b = {}", b);
    println!("b = {}", &b);
    println!("b = {}", &s); // type of data
    println!("b = {}", s);
}