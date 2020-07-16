pub trait Playable {
    fn play(&self); // type alias to Self - refers to the type on which the trait is being implemented
    fn pause() {
        println!("Paused");
    }
}
