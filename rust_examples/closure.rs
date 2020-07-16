use std::thread;

fn main() {
    let v = vec![1, 2, 3];
//  let handle = thread::spawn(move || {//ownership of v transferred to thread
     let handle = thread::spawn(|| {
        println!("Here's a vector: {:?}", v);
    });
 //   drop(v);
    handle.join().unwrap();
}