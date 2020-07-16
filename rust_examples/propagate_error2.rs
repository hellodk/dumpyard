use std::io;
use std::io::Read;
use std::fs::File;


fn read_username_from_file() -> Result<String, io::Error> {
// ? operator can only be used in functions that have a return type of Result
// defined to work in the same way as the match expression
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}

fn main() {
	println!("{:?}", read_username_from_file());
}