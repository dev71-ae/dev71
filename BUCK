load("@third_party//tools/cbindgen:rule.bzl", "cbindgen")

rust_library(
    name = "core71",
    srcs = ["src/lib.rs"],
    edition = "2021",
    link_style = "static",
    visibility = ["PUBLIC"],
)

cbindgen(
    name = "core71.h",
    src = "src/lib.rs",
    cbindgen_toml = "d71_config//core71:cbindgen.toml",
    header_name = "core71",
    visibility = ["PUBLIC"],
)
