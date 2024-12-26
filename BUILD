load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "top_level_targets",
    "xcodeproj",
)

xcodeproj(
    name = "xcodeproj",
    project_name = "Dev71",
    tags = ["manual"],
    top_level_targets = [
        top_level_target("//ios:Dev71", target_environments = ["simulator"]),
    ],
)

alias(
    name = "ios",
    actual = "//ios:Dev71",
)

alias(
    name = "rust-project",
    actual = "@rules_rust//tools/rust_analyzer:gen_rust_project",
)
