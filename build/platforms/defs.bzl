def _execution_platform_impl(ctx: AnalysisContext) -> list[Provider]:
    constraints = dict()

    constraints.update(ctx.attrs.cpu_configuration[ConfigurationInfo].constraints)
    constraints.update(ctx.attrs.os_configuration[ConfigurationInfo].constraints)

    cfg = ConfigurationInfo(constraints = constraints, values = {})

    name = ctx.label.raw_target()
    platform = ExecutionPlatformInfo(
        label = name,
        configuration = cfg,
        executor_config = CommandExecutorConfig(
            local_enabled = True,
            remote_enabled = False,
            use_windows_path_separators = ctx.attrs.use_windows_path_separators,
        ),
    )

    return [
        DefaultInfo(),
        platform,
        PlatformInfo(label = str(name), configuration = cfg),
        ExecutionPlatformRegistrationInfo(platforms = [platform]),
    ]

_execution_platform = rule(
    impl = _execution_platform_impl,
    attrs = {
        "cpu_configuration": attrs.dep(providers = [ConfigurationInfo]),
        "os_configuration": attrs.dep(providers = [ConfigurationInfo]),
        "use_windows_path_separators": attrs.bool(),
    },
)

def _pp_arch(arch) -> str:
    if arch.is_x86_64:
        return "x86_64"
    elif arch.is_aarch64:
        return "arm64"
    else:
        return "unknown"

def _pp_os(os) -> str:
    if os.is_linux:
        return "linux"
    elif os.is_macos:
        return "darwin"
    elif os.is_windows:
        return "windows"
    else:
        return "unknown"

def local_execution_platform() -> None:
    host = host_info()

    arch = host.arch
    os = host.os

    cpu_configuration: str = "config//cpu:{}".format(_pp_arch(arch))
    os_configuration: str = "config//os:{}".format(_pp_os(os))

    _execution_platform(
        name = "local",
        cpu_configuration = cpu_configuration,
        os_configuration = os_configuration,
        use_windows_path_separators = os.is_windows
    )
