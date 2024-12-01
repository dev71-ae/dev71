load("@prelude//apple:apple_toolchain_types.bzl", "AppleToolchainInfo")
load("@prelude//apple/swift:swift_toolchain_types.bzl", "SwiftObjectFormat", "SwiftToolchainInfo")
load("@prelude//cxx:cxx_toolchain_types.bzl", "CxxPlatformInfo", "CxxToolchainInfo")

_APPLE_SDKS = [
    "appletvos",
    "appletvsimulator",
    "iphoneos",
    "iphonesimulator",
    "maccatalyst",
    "macosx",
    "visionos",
    "visionsimulator",
    "watchos",
    "watchsimulator",
]

_DEFAULT_ARCH = select({
    "config//cpu:arm64": "arm64",
    "config//cpu:x86_64": "x86_64",
})

def _xcode_apple_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    xcode_bin_path = "{}/Contents/Developer/usr/bin".format(ctx.attrs.xcode_app)
    sdk_path = "{}/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk".format(ctx.attrs.xcode_app)

    return [
        DefaultInfo(),
        AppleToolchainInfo(
            actool = RunInfo(args = ["actool"]),
            architecture = ctx.attrs._architecture,
            codesign = RunInfo(args = ["codesign"]),
            codesign_allocate = RunInfo(args = ["codesign_allocate"]),
            codesign_identities_command = None,
            compile_resources_locally = True,
            copy_scene_kit_assets = RunInfo(args = ["{}/copySceneKitAssets".format(xcode_bin_path)]),
            cxx_platform_info = CxxPlatformInfo(name = "macosx-arm64"),
            cxx_toolchain_info = ctx.attrs._cxx_toolchain[CxxToolchainInfo],
            dsymutil = RunInfo(args = ["dsymutil"]),
            dwarfdump = RunInfo(args = ["dwarfdump"]),
            extra_linker_outputs = ctx.attrs.extra_linker_outputs,
            ibtool = RunInfo(args = ["ibtool"]),
            installer = ctx.attrs.installer,
            libtool = RunInfo(args = ["libtool"]),
            lipo = RunInfo(args = ["lipo"]),
            mapc = RunInfo(args = ["{}/mapc".format(xcode_bin_path)]),
            merge_index_store = ctx.attrs._merge_index_store[RunInfo],
            momc = RunInfo(args = ["{}/momc".format(xcode_bin_path)]),
            objdump = RunInfo(args = ["objdump"]),
            platform_path = "/",
            sdk_build_version = "15.1",
            sdk_name = ctx.attrs.sdk_name,
            sdk_path = sdk_path,
            sdk_version = "15.1",
            swift_toolchain_info = SwiftToolchainInfo(
                sdk_path = sdk_path,
                compiler = RunInfo(args = ["swiftc"]),
                compiler_flags = [],
                object_format = SwiftObjectFormat("object"),
                mk_swift_comp_db = ctx.attrs._mk_swift_comp_db,
            ),
            xcode_build_version = "16B40",
            xcode_version = "16.1",
            xctest = RunInfo(args = ["{}/xctest".format(xcode_bin_path)]),
        ),
    ]

xcode_apple_toolchain = rule(
    impl = _xcode_apple_toolchain_impl,
    attrs = {
        "xcode_app": attrs.string(default = "/Applications/Xcode.app"),
        "extra_linker_outputs": attrs.list(attrs.string(), default = []),
        "sdk_name": attrs.enum(_APPLE_SDKS, default = "macosx"),
        "installer": attrs.default_only(attrs.label(default = "buck//src/com/facebook/buck/installer/apple:apple_installer")),
        "_mk_swift_comp_db": attrs.exec_dep(default = "prelude//apple/tools:make_swift_comp_db", providers = [RunInfo]),
        "_merge_index_store": attrs.exec_dep(default = "prelude//apple/tools/index:merge_index_store", providers = [RunInfo]),
        "_architecture": attrs.string(default = _DEFAULT_ARCH),
        "_cxx_toolchain": attrs.toolchain_dep(default = "toolchains//:cxx", providers = [CxxToolchainInfo, CxxPlatformInfo]),
    },
    is_toolchain_rule = True,
)
