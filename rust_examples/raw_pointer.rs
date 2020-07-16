fn main() {
    let a = 10;
    
    let b: *const i32 = &a as *const i32;
    println!("{:?}", b);
    
    let b = &a as *const i32;

    println!("{:?}", b);
}