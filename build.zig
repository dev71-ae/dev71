const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const prelude = b.addStaticLibrary(.{
        .name = "prelude",
        .root_source_file = b.path("src/prelude/prelude.zig"),
        .target = target,
        .optimize = optimize,
    });

    prelude.installHeadersDirectory(
        b.path("src/prelude/include"),
        &.{},
        .{ .include_extensions = &.{ ".h", ".modulemap" } },
    );

    b.installArtifact(prelude);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
