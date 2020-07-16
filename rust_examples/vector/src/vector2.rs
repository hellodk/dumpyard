fn main() {
	let v = vec![1, 2, 3, 4, 5];
	let third: &i32 = &v[2];
	let third: Option<&i32> = v.get(2);
	let v1 = vec![1, 2, 3, 4, 5];
//	let does_not_exist = &v1[100]; //panics
	let does_not_exist = v1.get(100);
	println!("{:?}", third);
}