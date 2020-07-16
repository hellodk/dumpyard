extern crate sync;

use sync::{Arc, Mutex};

fn main() {
    let x1 = Arc::new(Mutex::new(0));
    let y1 = Arc::new(Mutex::new(0));

    let x2 = x1.clone();
    let y2 = y1.clone();

    spawn(proc() {
        for _ in range(0u, 100) {
            let i = x2.lock();
            let j = y2.lock();
            let _ = *i + *j;
        }
    });

    for _ in range(0u, 100) {
        let j = y1.lock();
        let i = x1.lock();
        let _ = *i + *j;
    }
}