fn main() {
// A simple integer calculator:
// + or - means add or subtract by 1
// * or / means multiply or divide by 2
let program = "+ + * - /";
let mut accumulator = 0i;
for token in program.chars() {
match token {
'+' => accumulator += 1,
'-' => accumulator -= 1,
'*' => accumulator *= 2,
'/' => accumulator /= 2,
_ => { /* ignore everything else */ }
}
}
}