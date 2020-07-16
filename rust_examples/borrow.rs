fn main()
{
	let mut x = vec!["Hello", "World"];
	let y = &x[0];
	x.push("foo");
	println!("{:?}", x);
}