use std::io;

fn get_user_temp() {
    println!("\nType \"quit\" to end the program");

    loop {
        let mut temp_input = String::new();

        println!("\nPlease input a temperature you want to convert (Format: 100F or -40C):");

        io::stdin()
            .read_line(&mut temp_input)
            .expect("Failed to read line");

        let trimmed = temp_input.trim();

        if trimmed == "quit" {
            break;
        }

        let (temp, scale) = trimmed.split_at(trimmed.len() - 1);

        let temp: f64 = match temp.parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        let temp: Temp = match scale {
            "C" => Temp::C(temp),
            "F" => Temp::F(temp),
            _ => continue,
        };

        print_temp(&temp);
    }
}