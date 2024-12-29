#![no_std]

// NOTE: Since we are not using the standard library,
// we need to provide our own panic handler and allocator.
#[cfg(not(test))]
use core::panic::PanicInfo;
/// This function is called on panic.
#[cfg(not(test))]
#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {}
}

use core::alloc::{GlobalAlloc, Layout};
pub struct Allocator;
unsafe impl GlobalAlloc for Allocator {
    unsafe fn alloc(&self, _layout: Layout) -> *mut u8 {
        core::ptr::null_mut::<u8>()
    }
    unsafe fn dealloc(&self, _ptr: *mut u8, _layout: Layout) {
        unreachable!(); // since we never allocate
    }
}

#[global_allocator]
static GLOBAL_ALLOCATOR: Allocator = Allocator;

#[unsafe(no_mangle)]
extern "C" fn rust_eh_personality() {}

#[unsafe(no_mangle)]
extern "C" fn _Unwind_Resume() {}

// extern crate alloc;
// use alloc::vec;
use mls_rs::CipherSuite;
const CIPHERSUITE: CipherSuite = CipherSuite::CURVE25519_AES128;

// SAFETY: There is no other global function of the same name
#[unsafe(no_mangle)]
pub extern "C" fn core71_init() -> i32 {
    // FIX: uncomment the following line
    // let _ = mls_rs_crypto_awslc::AwsLcCryptoProvider::with_enabled_cipher_suites(vec![CIPHERSUITE]);
    unsafe {
        libc::printf(c"CipherSuite: %d\n".as_ptr(), CIPHERSUITE);
    }

    CipherSuite::all()
        .enumerate()
        .for_each(|(i, ciphersuite)| unsafe {
            libc::printf(c"CipherSuite[%d]: %d\n".as_ptr(), i, ciphersuite);
        });

    71
}
