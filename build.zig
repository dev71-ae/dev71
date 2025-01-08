const std = @import("std");
const builtin = @import("builtin");

const XcFrameworkStep = @import("src/build/XcFrameworkStep.zig");

inline fn iosTargetQuery(b: *std.Build, simulator: bool) std.Build.ResolvedTarget {
    return b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .ios,
        .os_version_min = .{ .semver = .{ .major = 15, .minor = 0, .patch = 0 } },
        .abi = if (simulator) .simulator else null,
    });
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const prelude = buildPrelude(b, target, optimize);

    b.installArtifact(prelude);

    // TODO: Refactor
    if (builtin.target.isDarwin()) {
        const emit_xcframework = b.option(
            bool,
            "emit-xcframework",
            "Build and install the xcframework for the iOS library.",
        ) orelse (target.result.os.tag == .ios);

        const ios_prelude = buildPrelude(b, iosTargetQuery(b, false), optimize);
        const ios_sim_prelude = buildPrelude(b, iosTargetQuery(b, true), optimize);

        const xcframework = XcFrameworkStep.create(b, .{
            .name = "Prelude",
            .libraries = &.{ ios_prelude, ios_sim_prelude },
        });

        if (emit_xcframework) {
            b.getInstallStep().dependOn(&xcframework.install_dir.step);
        }

        const build_ios_step = b.step("ios", "Shorthand for zig build -Demit-xcframework");
        build_ios_step.dependOn(&xcframework.install_dir.step);
    }
}

fn buildPrelude(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "prelude",
        .root_source_file = b.path("src/prelude/prelude.zig"),
        .optimize = optimize,
        .target = target,
    });

    lib.installHeadersDirectory(b.path("src/prelude/include"), &.{}, .{
        .include_extensions = &.{ ".h", ".modulemap" },
    });

    return lib;
}
