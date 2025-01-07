const std = @import("std");
const builtin = @import("builtin");

const XcFrameworkStep = @import("src/build/XcFrameworkStep.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const emit_xcframework = b.option(
        bool,
        "emit-xcframework",
        "Build and install the xcframework for the iOS library.",
    ) orelse builtin.target.isDarwin() and
        target.result.os.tag == .ios;

    const ios_lib = createIOSLib(b, null, optimize);
    const ios_sim_lib = createIOSLib(b, .simulator, optimize);

    const xcframework = XcFrameworkStep.create(b, .{
        .name = "Prelude",
        .libraries = &.{ ios_lib, ios_sim_lib },
    });

    if (emit_xcframework) {
        b.getInstallStep().dependOn(&xcframework.install_dir.step);
    }

    if (builtin.target.isDarwin()) {
        const build_ios_step = b.step("ios", "Shorthand for zig build -Demit-xcframework");
        build_ios_step.dependOn(&xcframework.install_dir.step);
    }
}

fn createIOSLib(
    b: *std.Build,
    abi: ?std.Target.Abi,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "prelude",
        .root_source_file = b.path("src/prelude/prelude.zig"),
        .optimize = optimize,
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .aarch64,
            .os_tag = .ios,
            .os_version_min = .{ .semver = .{ .major = 15, .minor = 0, .patch = 0 } },
            .abi = abi,
        }),
    });

    lib.bundle_compiler_rt = true;
    lib.linkLibC();

    lib.installHeadersDirectory(b.path("src/prelude"), &.{}, .{});

    return lib;
}
