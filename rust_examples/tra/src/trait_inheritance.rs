// trait_inheritance.rs

trait Vehicle {
    fn get_price(&self) -> u64;
}

trait Car: Vehicle {  // dependent on Vehicle trait
    // convenient type alias for the implementing type within the trait's impl blocks
    fn model(&self) -> String;
}

struct TeslaRoadster { // This is a car
    model: String,
    release_date: u16
}

impl TeslaRoadster {  // method for the struct
    fn new(model: &str, release_date: u16) -> Self { //self as the return type
        Self { model: model.to_string(), release_date }
    }
}

impl Car for TeslaRoadster {
    fn model(&self) -> String {
        "Tesla Roadster I".to_string()
    }
}

// /*
impl Vehicle for TeslaRoadster {
    fn get_price(&self) -> u64 {
        200_000
    }
}
// */

fn main() {
    let my_roadster = TeslaRoadster::new("Tesla Roadster II", 2020);
    println!("{} {} is priced at ${}", my_roadster.release_date, my_roadster.model, my_roadster.get_price());
}
