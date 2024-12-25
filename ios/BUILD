load("@rules_apple//apple:ios.bzl", "ios_application")
load("@rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "Sources",
    module_name = "Sources",
    srcs = glob(["Sources/**/*.swift"]),
    deps = ["//core:c_lib"],
    tags = ["manual"],
)

ios_application(
    name = "Dev71",
    bundle_id = "ae.dev71.Dev71",
    families = ["iphone"],
    infoplists = [":Info.plist"],
    minimum_os_version = "15.0",
    deps = [":Sources"],
    visibility = ["//visibility:public"],
)
