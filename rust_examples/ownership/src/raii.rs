// raii.rs
fn create_box() {
    // Allocate an integer on the heap
    let _box1 = Box::new(3);
    // `_box1` is destroyed here, and memory gets freed
}

fn main() {
    // Allocate an integer on the heap
    let _box2 = Box::new(5);
    // A nested scope:
    {
        // Allocate an integer on the heap
        let _box3 = Box::new(4);
        println!("{:?}", _box3);
        // `_box3` is destroyed here, and memory gets freed
    }
        println!("{:?}", _box3);
    // Creating lots of boxes just for fun
    // There's no need to manually free memory!
    for _ in 0..1000 {
        create_box();
    }
    // `_box2` is destroyed here, and memory gets freed
}