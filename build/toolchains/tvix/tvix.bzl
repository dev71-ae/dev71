TvixToolchainInfo = provider(
    fields = {
        # Evaluator, Store, and Build Service
        "bvix": provider_field(RunInfo),
        "nixpkgs": provider_field(str | Artifact),
    },
)

def _tvix_toolchain_impl(ctx: AnalysisContext) -> list[Provider]:
    return [
        DefaultInfo(),
        TvixToolchainInfo(bvix = RunInfo(args = ["bvix"]), nixpkgs = ctx.attrs.nixpkgs),
    ]

tvix_toolchain = rule(
    impl = _tvix_toolchain_impl,
    attrs = {
        "nixpkgs": attrs.source(),
    },
    is_toolchain_rule = True,
)

def _tvix_build_impl(ctx: AnalysisContext) -> list[Provider]:
    toolchain = ctx.attrs._tvix_toolchain[TvixToolchainInfo]

    build_request_out = ctx.actions.declare_output("build-request.json")
    idk = ctx.actions.declare_output("idk")

    ctx.actions.run(cmd_args([
        toolchain.bvix,
        "eval",
        "--expr",
        ctx.attrs.derivation,
        "--nixpkgs",
        toolchain.nixpkgs,
        "--output",
        build_request_out.as_output(),
    ]), category = "tvix")

    def f(ctx, artifacts, outputs):
        artifacts[build_request_out].print_json()
        fail("idk what to do yet")

    ctx.actions.dynamic_output(f = f, inputs = [], outputs = [idk.as_output()], dynamic = [build_request_out])

    return [DefaultInfo(default_output = idk)]

tvix_build = rule(
    impl = _tvix_build_impl,
    attrs = {
        "derivation": attrs.string(),
        "_tvix_toolchain": attrs.toolchain_dep(default = "toolchains//:tvix", providers = [TvixToolchainInfo]),
    },
)

tvix = struct(
    toolchain = tvix_toolchain,
    build = tvix_build,
)
