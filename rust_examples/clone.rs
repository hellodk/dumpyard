fn main()
{
	let mut x = vec!["Hello", "World"];
	let y = x[0].clone();
	x.push("foo");
	println!("{:#?}", x);
	println!("{:?}", y);
}