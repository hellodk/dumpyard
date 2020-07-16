fn main() {
    let p = 0 as *const i32;
//    let k = *p; // rust will not allow this
    
    unsafe {
        let k = *p;
        println!("{:?}", k);
    }
}