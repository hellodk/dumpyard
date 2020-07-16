fn main() {
    let p = 10 as *const i32; // stored 0 in a raw pointer
    println!("{:p}", p);
}