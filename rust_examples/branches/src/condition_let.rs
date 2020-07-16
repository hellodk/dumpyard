// Thsi code will not compile

fn main() {
    let condition = true;
    let number = if condition {
        5 // u32 type
    } else {
        "six" // string
    };
    println!("The value of number is: {}", number);
}