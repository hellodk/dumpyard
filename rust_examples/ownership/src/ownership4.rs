fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);
    println!("Value fo s1 is {}", s1);
    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize { // The pointer-sized unsigned integer type
    s.len()
}
