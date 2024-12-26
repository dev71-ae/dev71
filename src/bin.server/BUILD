load("@rules_rust//rust:defs.bzl", "rust_binary")
load("//:defs.bzl", "RUST_DEBUG_FLAGS", "RUST_RELEASE_FLAGS")

rust_binary(
    name = "bin",
    crate_name = "dev71_server",
    srcs = glob(["src/**/*.rs"]),
    rustc_flags = select({
        "//:release": RUST_RELEASE_FLAGS,
        "//conditions:default": RUST_DEBUG_FLAGS,
    }),
    deps = ["@crates//:mls-rs"],
)
