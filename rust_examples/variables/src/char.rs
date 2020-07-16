static mut LEVELS: u32 = 450;

fn main() {
   let c = 'z';
   println!("c is : {}", c);
   println!("static is : {}", LEVELS)
   let s = String::from("hello");
   println!("String is : {}", s);
   let mut s1 = String::from(s);
   s1.push_str(", world!"); // push_str() appends a literal to a String
   println!("{}", s1); // this will print `hello, world!`
}