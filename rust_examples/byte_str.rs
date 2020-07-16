use std::str;

fn main() {
    // Note that this is not actually a &str
    let bytestring: &[u8; 20] = b"this is a bytestring";

    // Byte arrays don't have Display so printing them is a bit limited
    println!("A bytestring: {:?}", bytestring);

    // Bytestrings can have byte escapes...
    let escaped = b"\x52\x75\x73\x74 as bytes";
    // ...but no unicode escapes
    // let escaped = b"\u{211D} is not allowed";
    println!("Some escaped bytes: {:?}", escaped);


    // Raw bytestrings work just like raw strings
    let raw_bytestring = br"\u{211D} is not escaped here";
    println!("{:?}", raw_bytestring);

    // Converting a byte array to str can fail
    if let Ok(my_str) = str::from_utf8(raw_bytestring) {
        println!("And the same as text: '{}'", my_str);
    }

    let quotes = br#"You can also use "fancier" formatting, \
                    like with normal raw strings"#;

    // Bytestrings don't have to be UTF-8
    let shift_jis = b"\x82\xe6\x82\xa8\x82\xb1\x82"; // "ようこそ" in SHIFT-JIS

    // But then they can't always be converted to str
    match str::from_utf8(shift_jis) {
        Ok(my_str) => println!("Conversion successful: '{}'", my_str),
        Err(e) => println!("Conversion failed: {:?}", e),
    };
}