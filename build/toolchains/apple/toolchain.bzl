_DEFAULT_ARCHITECTURE = select({
    "config//cpu:arm64": "arm64",
    "config//cpu:x86_64": "x86_64",
})

def _xcode_apple_toolchain_impl(ctx: AnalysisContext) -> list[Providers]:
    return [
        DefaultInfo(),
        AppleToolchainInfo(),
    ]

xcode_apple_toolchain = rule(
    impl = xcode_apple_toolchain_impl,
    attrs = {},
)
