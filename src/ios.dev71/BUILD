load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "sources",
    module_name = "Sources",
    srcs = glob(["Sources/**/*.swift"]),
    deps = ["//src/lib.core71:clib"],
    tags = ["manual"],
    target_compatible_with = ["@platforms//os:ios"],
)

ios_application(
    name = "app",
    bundle_id = "ae.dev71.Dev71",
    families = ["iphone"],
    infoplists = [":Info.plist"],
    minimum_os_version = "15.0",
    deps = [":sources"],
    visibility = ["//visibility:public"],
)
