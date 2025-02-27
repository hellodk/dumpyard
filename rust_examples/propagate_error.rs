use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> { //Result<T, E> - T is String
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

//returns a Result - fail to read even though File::open succeeded
    match f.read_to_string(&mut s) { 
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
