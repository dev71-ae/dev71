load("@prelude//apple:apple_binary.bzl", "apple_binary_impl")
load("@prelude//apple:apple_common.bzl", "apple_common")
load("@prelude//apple:apple_rules_impl.bzl", "extra_attributes")
load("@prelude//apple:apple_toolchain_types.bzl", "AppleToolchainInfo", "AppleToolsInfo")
load("@prelude//apple/swift:swift_incremental_support.bzl", "SwiftCompilationMode")
load("@prelude//cxx:link_groups_types.bzl", "LINK_GROUP_MAP_ATTR")
load("@prelude//decls:common.bzl", "CxxRuntimeType", "CxxSourceType", "HeadersAsRawHeadersMode", "IncludeType", "buck")
load("@prelude//decls:cxx_common.bzl", "cxx_common")
load("@prelude//decls:native_common.bzl", "native_common")
load("@prelude//linking:types.bzl", "Linkage")

apple_binary = rule(
    impl = apple_binary_impl,
    attrs = (
        extra_attributes["apple_binary"] |
        # @unsorted-dict-items
        cxx_common.srcs_arg() |
        cxx_common.platform_srcs_arg() |
        apple_common.headers_arg() |
        {
            "entitlements_file": attrs.option(attrs.source(), default = None, doc = """
                An optional name of a plist file to be embedded in the binary. Some platforms like
                 `iphonesimulator` require this to run properly.
            """),
        } |
        apple_common.exported_headers_arg() |
        apple_common.header_path_prefix_arg() |
        apple_common.frameworks_arg() |
        cxx_common.preprocessor_flags_arg() |
        cxx_common.exported_preprocessor_flags_arg(exported_preprocessor_flags_type = attrs.list(attrs.arg(), default = [])) |
        cxx_common.compiler_flags_arg() |
        cxx_common.platform_compiler_flags_arg() |
        cxx_common.linker_extra_outputs_arg() |
        cxx_common.linker_flags_arg() |
        cxx_common.exported_linker_flags_arg() |
        cxx_common.platform_linker_flags_arg() |
        native_common.link_style() |
        native_common.link_group_public_deps_label() |
        apple_common.target_sdk_version() |
        apple_common.extra_xcode_sources() |
        apple_common.extra_xcode_files() |
        apple_common.serialize_debugging_options_arg() |
        apple_common.uses_explicit_modules_arg() |
        apple_common.apple_sanitizer_compatibility_arg() |
        {
            # -- Shouldn't need to add these
            # "_apple_toolchain": attrs.toolchain_dep(default = "toolchains//:apple", providers = [AppleToolchainInfo]),
            # "_apple_tools": attrs.exec_dep(default = "toolchains//:apple-tools", providers = [AppleToolsInfo]),
            # "swift_package_name": attrs.option(attrs.string(), default = None),
            # "_swift_enable_testing": attrs.bool(default = False),
            # "enable_library_evolution": attrs.bool(default = True),
            # "swift_compilation_mode": attrs.enum(SwiftCompilationMode.values(), default = "wmo"),
            # "stripped": attrs.bool(default = False),
            # "prefer_stripped_objects": attrs.bool(default = False),
            # "binary_linker_flags": attrs.bool(default = False),
            # # --
            "bridging_header": attrs.option(attrs.source(), default = None),
            "can_be_asset": attrs.option(attrs.bool(), default = None),
            "contacts": attrs.list(attrs.string(), default = []),
            "cxx_runtime_type": attrs.option(attrs.enum(CxxRuntimeType), default = None),
            "default_host_platform": attrs.option(attrs.configuration_label(), default = None),
            "default_platform": attrs.option(attrs.string(), default = None),
            "defaults": attrs.dict(key = attrs.string(), value = attrs.string(), sorted = False, default = {}),
            "deps": attrs.list(attrs.dep(), default = []),
            "devirt_enabled": attrs.bool(default = False),
            "diagnostics": attrs.dict(key = attrs.string(), value = attrs.source(), sorted = False, default = {}),
            "enable_cxx_interop": attrs.bool(default = False),
            "executable_name": attrs.option(attrs.string(), default = None),
            "exported_header_style": attrs.enum(IncludeType, default = "local"),
            "exported_lang_platform_preprocessor_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg()))), sorted = False, default = {}),
            "exported_lang_preprocessor_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.arg()), sorted = False, default = {}),
            "exported_platform_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = True)), default = []),
            "exported_platform_headers": attrs.list(attrs.tuple(attrs.regex(), attrs.named_set(attrs.source(), sorted = True)), default = []),
            "exported_platform_linker_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg())), default = []),
            "exported_platform_preprocessor_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg())), default = []),
            "exported_post_linker_flags": attrs.list(attrs.arg(), default = []),
            "exported_post_platform_linker_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg())), default = []),
            "fat_lto": attrs.bool(default = False),
            "focused_list_target": attrs.option(attrs.dep(), default = None),
            "force_static": attrs.option(attrs.bool(), default = None),
            "header_namespace": attrs.option(attrs.string(), default = None),
            "headers_as_raw_headers_mode": attrs.option(attrs.enum(HeadersAsRawHeadersMode), default = None),
            "import_obj_c_forward_declarations": attrs.bool(default = True),
            "include_directories": attrs.set(attrs.string(), sorted = True, default = []),
            "info_plist": attrs.option(attrs.source(), default = None),
            "info_plist_substitutions": attrs.dict(key = attrs.string(), value = attrs.string(), sorted = False, default = {}),
            "labels": attrs.list(attrs.string(), default = []),
            "lang_compiler_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.arg()), sorted = False, default = {}),
            "lang_platform_compiler_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg()))), sorted = False, default = {}),
            "lang_platform_preprocessor_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg()))), sorted = False, default = {}),
            "lang_preprocessor_flags": attrs.dict(key = attrs.enum(CxxSourceType), value = attrs.list(attrs.arg()), sorted = False, default = {}),
            "libraries": attrs.list(attrs.string(), default = []),
            "licenses": attrs.list(attrs.source(), default = []),
            "link_group": attrs.option(attrs.string(), default = None),
            "link_group_map": LINK_GROUP_MAP_ATTR,
            "link_whole": attrs.option(attrs.bool(), default = None),
            "modular": attrs.bool(default = False),
            "module_name": attrs.option(attrs.string(), default = None),
            "module_requires_cxx": attrs.bool(default = False),
            "platform_deps": attrs.list(attrs.tuple(attrs.regex(), attrs.set(attrs.dep(), sorted = True)), default = []),
            "platform_headers": attrs.list(attrs.tuple(attrs.regex(), attrs.named_set(attrs.source(), sorted = True)), default = []),
            "platform_preprocessor_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg())), default = []),
            "post_linker_flags": attrs.list(attrs.arg(), default = []),
            "post_platform_linker_flags": attrs.list(attrs.tuple(attrs.regex(), attrs.list(attrs.arg())), default = []),
            "precompiled_header": attrs.option(attrs.source(), default = None),
            "preferred_linkage": attrs.option(attrs.enum(Linkage.values()), default = None),
            "prefix_header": attrs.option(attrs.source(), default = None),
            "public_include_directories": attrs.set(attrs.string(), sorted = True, default = []),
            "public_system_include_directories": attrs.set(attrs.string(), sorted = True, default = []),
            "raw_headers": attrs.set(attrs.source(), sorted = True, default = []),
            "reexport_all_header_dependencies": attrs.option(attrs.bool(), default = None),
            "sdk_modules": attrs.list(attrs.string(), default = []),
            "soname": attrs.option(attrs.string(), default = None),
            "static_library_basename": attrs.option(attrs.string(), default = None),
            "supported_platforms_regex": attrs.option(attrs.regex(), default = None),
            "supports_merged_linking": attrs.option(attrs.bool(), default = None),
            "swift_compiler_flags": attrs.list(attrs.arg(), default = []),
            "swift_module_skip_function_bodies": attrs.bool(default = True),
            "swift_version": attrs.option(attrs.string(), default = None),
            "thin_lto": attrs.bool(default = False),
            "use_submodules": attrs.bool(default = True),
            "uses_cxx_explicit_modules": attrs.bool(default = False),
            "uses_modules": attrs.bool(default = False),
        } |
        buck.allow_cache_upload_arg()
    ),
)
