fn main() {
    let s1 = String::from("hello");

    let (s2, len) = calculate_length(s1);
    println!("Value fo s1 is {}", s1);
    println!("The length of '{}' is {}.", s2, len);
}

   //   fn calculate_length(s: String) -> (String, usize) {
    fn calculate_length(s: String) -> (String, u32) {
    let length = s.len(); // len() returns the length of a String

    (s, length)
}
