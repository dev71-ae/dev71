load("@rules_rust//rust:defs.bzl", "rust_static_library", "rust_test", "rust_test_suite")
load("@rules_swift//swift:swift_interop_hint.bzl", "swift_interop_hint")
load("//:defs.bzl", "RUST_DEBUG_FLAGS", "RUST_RELEASE_FLAGS")

package(default_visibility = ["//visibility:public"])

rust_static_library(
    name = "lib",
    crate_name = "core71",
    srcs = glob(["src/**/*.rs"]),
    rustc_flags = select({
        "//:release": RUST_RELEASE_FLAGS,
        "//conditions:default": RUST_DEBUG_FLAGS,
    }),
    deps = ["@crates//:mls-rs", "@crates//:libc", "@crates//:mls-rs-crypto-awslc"],
)

rust_test(
    name = "unit_tests",
    crate = ":lib",
)

cc_import(
    name = "clib",
    hdrs = ["include/core71.h"],
    static_library = ":lib",
    aspect_hints = [":swift_hint"],
)

swift_interop_hint(
    name = "swift_hint",
    module_name = "Core71",
    visibility = ["//visibility:private"],
)
