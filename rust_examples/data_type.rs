impl_type_info!(i32, i64, f32, f64, str, String, Vec<T>, Result<T,S>)

fn main() {
    println!("{}", type_of!(1));
    println!("{}", type_of!(&1));
    println!("{}", type_of!(&&1));
    println!("{}", type_of!(&mut 1));
    println!("{}", type_of!(&&mut 1));
    println!("{}", type_of!(&mut &1));
    println!("{}", type_of!(1.0));
    println!("{}", type_of!("abc"));
    println!("{}", type_of!(&"abc"));
    println!("{}", type_of!(String::from("abc")));
    println!("{}", type_of!(vec![1,2,3]));

    println!("{}", <Result<String,i64>>::type_name());
    println!("{}", <&i32>::type_name());
    println!("{}", <&str>::type_name());
}