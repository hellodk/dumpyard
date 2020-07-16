// smart_pointer2.rs

fn main() {
    let x = 5;
    let y = Box::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);

    println!("{:?}", *y);
    println!("{:?}", y);
}
