extern {
    // Our C function definitions!
    pub fn strcpy(dest: *mut u8, src: *const u8) -> *mut u8;
    pub fn puts(s: *const u8) -> i32;
}

fn main() {
    let x = b"Hello, world!\0"; // our string to copy
    let mut y = [0u8; 32]; // declare some space on the stack to copy the string into
    unsafe {
      // calling C code is definitely unsafe. it could be doing ANYTHING
      strcpy(y.as_mut_ptr(), x.as_ptr()); // we need to call .as_ptr() to get a pointer for C to use
      puts(y.as_ptr());
    }
}
