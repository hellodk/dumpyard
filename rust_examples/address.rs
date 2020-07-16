fn main() {
    let a = 10;
    let b = &a;

    println!("{:?}", b as *const i32);
    println!("{:p}", &a);
    println!("{}", &a);
    println!("{}", a);
}