load("@rules_rust//rust:defs.bzl", "rust_static_library")
load("@rules_swift//swift:swift_interop_hint.bzl", "swift_interop_hint")

package(default_visibility = ["//visibility:public"])

rust_static_library(
    name = "lib",
    srcs = glob(["src/**/*.rs"]),
)

cc_import(
    name = "c_lib",
    hdrs = ["include/core71.h"],
    static_library = ":lib",
    aspect_hints = [":swift_hint"],
)

swift_interop_hint(
    name = "swift_hint",
    module_name = "Core71",
    visibility = ["//visibility:private"],
)
