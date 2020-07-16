fn main()
{
	let mut x = vec!["Hello", "World"];
	{
	let y = &x[0];
	println!("{:#?}", y);
}
	x.push("foo");
	println!("{:#?}", x);

}