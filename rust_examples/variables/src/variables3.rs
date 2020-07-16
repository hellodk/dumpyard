fn main() {

    let guess: i32 = "40".parse().expect("Not a number!");
    // let guess: u32 = 0x4a;
    //let guess: u32 = "42a".parse().expect("Not a number!");
    println!("There are {} spaces", guess);
}