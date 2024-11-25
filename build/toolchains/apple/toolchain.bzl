load("@prelude//apple:apple_toolchain_types.bzl", "AppleToolchainInfo")
load("@prelude//apple/swift:swift_toolchain_types.bzl", "SwiftToolchainInfo")
load("@prelude//cxx:cxx_toolchain_types.bzl", "CxxPlatformInfo", "CxxToolchainInfo")

_DEFAULT_ARCHITECTURE = select({
    "config//cpu:arm64": "arm64",
    "config//cpu:x86_64": "x86_64",
})

def _xcode_apple_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    return [
        DefaultInfo(),
        AppleToolchainInfo(
            actool = ctx.attrs.actool[RunInfo],
            architecture = ctx.attrs.architecture,
            codesign = ctx.attrs.codesign[RunInfo],
            codesign_allocate = ctx.attrs.codesign_allocate[RunInfo],
            codesign_identities_command = ctx.attrs.codesign_identities_command[RunInfo] if ctx.attrs.codesign_identities_command else None,
            compile_resources_locally = ctx.attrs.compile_resources_locally,
            copy_scene_kit_assets = ctx.attrs.copy_scene_kit_assets[RunInfo],
            cxx_platform_info = ctx.attrs.cxx_toolchain[CxxPlatformInfo],
            cxx_toolchain_info = ctx.attrs.cxx_toolchain[CxxToolchainInfo],
            dsymutil = ctx.attrs.dsymutil[RunInfo],
            dwarfdump = ctx.attrs.dwarfdump[RunInfo] if ctx.attrs.dwarfdump else None,
            extra_linker_outputs = ctx.attrs.extra_linker_outputs,
            ibtool = ctx.attrs.ibtool[RunInfo],
            installer = ctx.attrs.installer,
            libtool = ctx.attrs.libtool[RunInfo],
            lipo = ctx.attrs.lipo[RunInfo],
            mapc = ctx.attrs.mapc[RunInfo] if ctx.attrs.mapc else None,
            merge_index_store = ctx.attrs.merge_index_store[RunInfo],
            momc = ctx.attrs.momc[RunInfo],
            objdump = ctx.attrs.objdump[RunInfo] if ctx.attrs.objdump else None,
            platform_path = platform_path,
            sdk_build_version = ctx.attrs.build_version,
            sdk_name = ctx.attrs.sdk_name,
            sdk_path = sdk_path,
            sdk_version = ctx.attrs.version,
            swift_toolchain_info = ctx.attrs.swift_toolchain[SwiftToolchainInfo] if ctx.attrs.swift_toolchain else None,
            xcode_build_version = ctx.attrs.xcode_build_version,
            xcode_version = ctx.attrs.xcode_version,
            xctest = ctx.attrs.xctest[RunInfo],
        ),
    ]

xcode_apple_toolchain = rule(
    impl = _xcode_apple_toolchain_impl,
    attrs = {},
)
