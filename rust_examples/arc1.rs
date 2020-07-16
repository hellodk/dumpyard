use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let v = Arc::new(Mutex::new(vec![1,2,3]));

    for i in 0..3 {
      let cloned_v = v.clone();
      thread::spawn(move || {
         cloned_v.lock().unwrap().push(i);
      });
    }
    println!("{:?}", v);

}