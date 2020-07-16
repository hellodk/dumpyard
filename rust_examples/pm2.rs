fn main() {
	let x = 1;

match x {
    1 | 2 => println!("one or two"),
    3 => println!("three"),
    _ => println!("anything"),
}

let x = 5;
// matching range of values
match x {
    1 ... 5 => println!("one through five"),
    _ => println!("something else"),
}

// range of char values
let x = 'c';
match x {
    'a' ... 'j' => println!("early ASCII letter"),
    'k' ... 'z' => println!("late ASCII letter"),
    _ => println!("something else"),
}


}