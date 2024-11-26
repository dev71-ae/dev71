def _tvix_toolchain_impl(ctx: AnalysisContext) -> list[Providers]:
    return [DefaultInfo()]

tvix_toolchain = rule(
    impl = _tvix_toolchain_impl,
    attrs = {
        "search_paths": attr.dict(key = attrs.string(), value = attrs.source()),
    },
    is_toolchain_rule = True,
)
