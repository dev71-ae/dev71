def cbindgen_impl(ctx: AnalysisContext) -> list[Provider]:
    header = ctx.actions.declare_output(ctx.attrs.header_name + ".h")

    ctx.actions.run([
        ctx.attrs._cbindgen_cli[RunInfo],
        "--config",
        ctx.attrs.cbindgen_toml,
        "--output",
        header.as_output(),
        ctx.attrs.src,
    ], category = "bindgen")

    return [
        DefaultInfo(default_output = header),
    ]

cbindgen = rule(
    impl = cbindgen_impl,
    attrs = {
        "src": attrs.source(),
        "cbindgen_toml": attrs.source(),
        "header_name": attrs.string(),
        "_cbindgen_cli": attrs.exec_dep(providers = [RunInfo], default = "third_party//tools/cbindgen:bin"),
    },
)
