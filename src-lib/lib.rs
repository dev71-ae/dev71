// SAFETY: There is no other global function of the same name
#[unsafe(no_mangle)]
pub fn init() -> i32 {
    return 1;
}
