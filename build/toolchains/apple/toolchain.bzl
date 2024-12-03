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

xcode_toolchain = rule(
    impl = _xcode_toolchain_impl,
)

def _xcode_platform_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    xctoolchain = ctx.attrs.xctoolchain[AppleToolchainInfo]

    xcbin = "{}/Contents/Developer/usr/bin".format(ctx.attrs.xcode_app)

    XCodeRunInfo = lambda cli: RunInfo(args = [xcode_bin_path + "/" + cli])

    platform_path = "{}/Contents/Developer/Platforms/{}.platform".format(ctx.attrs.xcode_app, ctx.attrs.sdk_name)
    sdk_path = "{}/Developer/SDKs/{}.sdk".format(platform_path, ctx.attrs.sdk_name)

    sdk_version_json_file = ctx.actions.declare_output("sdk_{}_version.json".format(ctx.attrs.sdk_name))
    sdk_version_cmd = cmd_args([
        xcode_bin_path + "/xcodebuild",
        "-version",
        "-sdk",
        ctx.attrs.sdk_name,
        "-json",
        "|",
        "tail",
        "-n",
        "+2",
        ">",
        sdk_version_json_file.as_output(),
    ])

    ctx.actions.run(sdk_version_cmd)

    def f(ctx, artifacts, outputs, a, b):
        deps = artifacts[sdk_version_json_file].read_json()

    ctx.actions.dynamic_output(dynamic = [sdk_version_json_file], inputs = [], outputs = [])

    return [
        DefaultInfo(),
        AppleToolchainInfo(
            platform_path,
            sdk_path,
            actool = XCodeRunInfo("actool"),
            architecture = ctx.attrs._architecture,
            codesign = XCodeRunInfo("codesign"),
            codesign_allocate = XCodeRunInfo("codesign_allocate"),
            codesign_identities_command = None,
            compile_resources_locally = True,
            copy_scene_kit_assets = XCodeRunInfo("copySceneKitAssets"),
            # FIXME(@huwaireb): The arch shouldn't be fixed, and I doubt it should be manually defined like this.
            cxx_platform_info = CxxPlatformInfo(name = "{}-arm64".format(ctx.attrs.sdk_name)),
            cxx_toolchain_info = ctx.attrs._cxx_toolchain[CxxToolchainInfo],
            dsymutil = None,
            dwarfdump = None,
            extra_linker_outputs = ctx.attrs.extra_linker_outputs,
            ibtool = XCodeRunInfo("ibtool"),
            installer = ctx.attrs.installer,
            mapc = XCodeRunInfo("mapc"),
            merge_index_store = ctx.attrs._merge_index_store[RunInfo],
            momc = XCodeRunInfo("momc"),
            objdump = None,
            sdk_build_version = ctx.attrs.sdk_build_version,
            sdk_name = ctx.attrs.sdk_name,
            sdk_version = ctx.attrs.sdk_version,
            swift_toolchain_info = xctoolchain.swift_toolchain_info,
            xcode_build_version = ctx.attrs.xcode_build_version,
            xcode_version = ctx.attrs.xcode_version,
            xctest = XCodeRunInfo("xctest"),
        ),
    ]

xcode_platform_toolchain = rule(
    impl = _xcode_platform_toolchain_impl,
    attrs = {
        "xcode_app": attrs.string(default = "/Applications/Xcode.app"),
        "_overide_xcode_version": attrs.option(attrs.string, default = None),
        "_override_xcode_build_version": attrs.option(attrs.string, default = None),
        "extra_linker_outputs": attrs.list(attrs.string(), default = []),
        "sdk_name": attrs.enum(_APPLE_SDKS),
        "sdk_version": attrs.option(attrs.string, default = None),
        "sdk_build_version": attrs.option(attrs.string, default = None),
        # FIXME(@huwaireb): Not a single clue what this is.
        "installer": attrs.default_only(attrs.label(default = "buck//src/com/facebook/buck/installer/apple:apple_installer")),
        "swift_object_format": attrs.enum(SwiftObjectFormat.values(), default = "object"),
        "_mk_swift_comp_db": attrs.exec_dep(default = "prelude//apple/tools:make_swift_comp_db", providers = [RunInfo]),
        "_merge_index_store": attrs.exec_dep(default = "prelude//apple/tools/index:merge_index_store", providers = [RunInfo]),
        "_architecture": attrs.string(default = _DEFAULT_ARCH),
        "_cxx_toolchain": attrs.toolchain_dep(default = "toolchains//:cxx", providers = [CxxToolchainInfo, CxxPlatformInfo]),
    },
    is_toolchain_rule = True,
)
