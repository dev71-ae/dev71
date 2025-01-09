const std = @import("std");
const builtin = @import("builtin");

comptime {
    const current = builtin.zig_version;
    const required: std.SemanticVersion = .{ .major = 0, .minor = 13, .patch = 0 };

    if (current.major != required.major or current.minor != required.minor)
        @compileError(std.fmt.comptimePrint("Your zig version: v{}, required version: v{}", .{ current, required }));
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const install_step = b.getInstallStep();
    const prelude_step = b.step("prelude", "Build's only the prelude static library");

    const prelude = b.addStaticLibrary(.{
        .name = "prelude",
        .root_source_file = b.path("src/prelude/prelude.zig"),
        .optimize = optimize,
        .target = target,
    });

    // REASON(ref: https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleexecutable#Discussion):
    // > For a framework, it’s the shared library framework and must have the same name as the framework but without
    // > the .framework extension.
    const install_prelude = if (target.result.os.tag == .ios) b: {
        // NOTE: The header file is omitted on purpose, as Xcode generates a modulemap
        // so we need to directly depend on the header as opposed to copy it in.
        const install_lib = b.addInstallFileWithDir(prelude.getEmittedBin(), .lib, "Prelude");
        install_lib.step.dependOn(&prelude.step);
        break :b &install_lib.step;
    } else b: {
        prelude.installHeadersDirectory(b.path("src/prelude"), &.{}, .{});
        break :b &b.addInstallArtifact(prelude, .{}).step;
    };

    prelude_step.dependOn(install_prelude);
    install_step.dependOn(prelude_step);
}
