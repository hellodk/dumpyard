#[derive(Debug)] //adding debug annotation

struct Rectangle {
  width: u32,
  height: u32,
   }

   fn main() {
    let rect1 = Rectangle { width: 30, height: 50 };

    println!("rect1 is {:?}", rect1);

    println!("rect1 is {:#?}", rect1); // pretty printing

    println!(
            "The area of the rectangle is {} square pixels.",
            area(&rect1) // don’t want to take ownership, want to read the data in the struct, not write to it
        );
   }

fn area(rectangle: &Rectangle) -> u32 {

  rectangle.width * rectangle.height

   }