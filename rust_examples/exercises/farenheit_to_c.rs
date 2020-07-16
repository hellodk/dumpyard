enum Temp {
    F(f64),
    C(f64),
}

fn convert_temp(temp: &Temp) -> f64 {
    match temp {
        &Temp::F(degrees) => (degrees - 32.0) / 1.8,
        &Temp::C(degrees) => (degrees * 1.8) + 32.0,
    }
}

fn sample_temps() {
    println!("Sample conversions:");

    let temps = [
        Temp::F(-40.0), // -40
        Temp::F(0.0),   // -18
        Temp::F(32.0),  // 0
        Temp::F(60.0),  // 16
        Temp::F(100.0), // 38
        Temp::F(150.0), // 66
        Temp::F(212.0), // 100
        Temp::C(-40.0), // -40
        Temp::C(0.0),   // 32
        Temp::C(15.0),  // 59
        Temp::C(30.0),  // 86
        Temp::C(60.0),  // 140
        Temp::C(100.0), // 212
        Temp::C(200.0), // 392
    ];

    for temp in temps.iter() {
        print_temp(temp);
    }
}

fn print_temp(temp: &Temp) {
    match temp {
        &Temp::F(degrees) => println!("{}F = {}C", degrees, convert_temp(temp)),
        &Temp::C(degrees) => println!("{}C = {}F", degrees, convert_temp(temp)),
    }
}

fn main() {
    println!("Welcome to temperature converter!\n");

    sample_temps();
}