// This function takes ownership of the heap allocated memory
fn destroy_box(c: Box<i32>) {
    println!("Destroying a box that contains {}", c);
}

fn main() {
    // _Stack_ allocated integer
    let x = 5u32;
    // *Copy* `x` into `y` - no resources are moved
    let y = x;
    // Both values can be independently used
    println!("x is {}, and y is {}", x, y);
    // `a` is a pointer to a _heap_ allocated integer
    let a = Box::new(5i32); // Using Box we create known sized data on the heap
    println!("a contains: {}", a);
    // *Move* `a` into `b`
    let b = a;
    // The pointer address of `a` is copied (not the data) into `b`.
    // Both are now pointers to the same heap allocated data, but
    // `b` now owns it.

    // Error! `a` can no longer access the data, because it no longer owns the
    // heap memory
    println!("a contains: {}", a);
    destroy_box(b);
    println!("b contains: {}", b);
}
