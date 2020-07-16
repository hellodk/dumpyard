fn main() {

let s = String::from("hello"); // can not be mutated

let mut s = String::from("hello"); // can be mutated

s.push_str(", world!"); // push_str() appends a literal to a String

println!("{}", s); // this will print `hello, world!`

}
