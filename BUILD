load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "top_level_targets",
    "xcodeproj",
)

alias(
    name = "ios_dev71",
    actual = "//src/ios.dev71:app",
)

alias(
    name = "rust_project",
    actual = "@rules_rust//tools/rust_analyzer:gen_rust_project",
)

config_setting(
    name = "release",
    values = {
        "compilation_mode": "opt",
    },
)

xcodeproj(
    name = "xcodeproj",
    project_name = "Dev71",
    tags = ["manual"],
    top_level_targets = [
        top_level_target(":ios_dev71", target_environments = ["simulator"]),
    ],
)
