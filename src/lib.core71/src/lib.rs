// SAFETY: There is no other global function of the same name
#[unsafe(no_mangle)]
pub extern "C" fn core71_init() -> i32 {
    // print to stdout using libc's printf
    unsafe {
        libc::printf("[RUST libc::printf] hello world\n\0".as_ptr() as *const i8);
    }
    // return 5 seconds
    core::time::Duration::from_secs(5).as_millis() as i32
}

#[cfg(test)]
mod test {
    use crate::core71_init;

    #[test]
    fn test_init() {
        assert_eq!(core71_init(), 1)
    }
}
