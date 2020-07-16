fn main() {
    let a = [10, 20, 30, 40, 50];
    let mut index = 0;
    while index < 5 {
        println!("the value is: {}", a[index]);
        println!("the value at index {} is: {}", index, a[index]);
        index = index + 1;
    }
}
