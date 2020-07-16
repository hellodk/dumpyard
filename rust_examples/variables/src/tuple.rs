fn main() {
	let tup:(u32, i64, f64, char, bool) = (128, -127, 345.789, 'D', false);
    println!("(x, y, z, d) = {:?}", tup);

    let (_x,_y,_z,_d, _b) = tup; // see that b is non appended with a under score
    
    println!("value for char data-type is : {}", _d);
    
    println!("value at 3rd position : {}", tup.3); // printing the value at 3rd position
    
    println!("value for bool is : {}", tup.4); // printing the boolean variable

    println!("Printing the whole tuple {:?}", tup);
}