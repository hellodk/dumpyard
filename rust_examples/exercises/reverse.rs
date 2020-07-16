#[deriving(Show)]
enum Direction {
North,
East,
South,
West
}
fn reverse(dir: Direction) -> Direction {
match dir {
North => South,
East => West,
South => North,
West => East,
}
}
fn main() {
println!("You should head: {}", reverse(North));
}