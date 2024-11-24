load("@third_party//cbindgen:rule.bzl", "cbindgen")

rust_library(
    name = "core71",
    srcs = ["lib.rs"],
    edition = "2021",
    link_style = "static",
    visibility = ["PUBLIC"],
)

cbindgen(
    name = "core71.h",
    src = "lib.rs",
    config_file = "cbindgen.toml",
    header_name = "core71",
    visibility = ["PUBLIC"],
)
