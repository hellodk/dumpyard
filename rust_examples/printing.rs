fn main() {
    println!("{}, {}!", "Hello", "world"); // Hello, world!
    println!("{0}, {1}!", "Hello", "world"); // Hello, world!
    println!("{greeting}, {name}!", greeting="Hello", name="world"); // Hello, world!

    println!("{:?}", [1,2,3]); // [1, 2, 3]
    println!("{:#?}", [1,2,3]);
    /*
        [
            1,
            2,
            3
        ]
    */

    // 🔎 format! macro is used to store the formatted STRING
    let x = format!("{}, {}!", "Hello", "world");
    println!("{}", x); // Hello, world!

    let y = String::from("Hello, ") + "world!";
    println!("{}", y); // Hello, world!
    println!("{:#06x}", 0x0001u16); //
}
