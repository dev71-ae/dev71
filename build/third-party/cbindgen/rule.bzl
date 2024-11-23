def cbindgen_impl(ctx: AnalysisContext) -> list[Provider]:
    header = ctx.actions.declare_output(ctx.attrs.header_name + ".h")

    ctx.actions.run([
        ctx.attrs._cbindgen[RunInfo],
        "--config",
        ctx.attrs.config_file,
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
        "config_file": attrs.source(),
        "header_name": attrs.string(),
        "_cbindgen": attrs.dep(providers = [RunInfo], default = "third-party//cbindgen:bin-native")
    },
)
