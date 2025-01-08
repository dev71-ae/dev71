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

    const prelude = b.addStaticLibrary(.{
        .name = "prelude",
        .root_source_file = b.path("src/prelude/prelude.zig"),
        .optimize = optimize,
        .target = target,
    });

    prelude.installHeadersDirectory(b.path("src/prelude"), &.{}, .{});

    b.installArtifact(prelude);
}
