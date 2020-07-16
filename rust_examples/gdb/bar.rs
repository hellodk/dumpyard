extern crate quux;

fn main() {
    let mut y = 2;
    {
        let x = || {
            7 + y
        };
        let retval = quux::quux00(x);
        println!("retval: {:?}", retval);
    }
    y = 5;
    println!("y     : {:?}", y);
}
