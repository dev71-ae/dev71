#![no_std]

// SAFETY: There is no other global function of the same name
#[unsafe(no_mangle)]
pub extern "C" fn prelude_init() -> i32 {
    71
}

#[panic_handler]
fn panic(_: &core::panic::PanicInfo) -> ! {
    loop {}
}
