const std = @import("std");
const builtin = @import("builtin");

const Build = std.Build;
const Step = Build.Step;

const Builder = struct {
    target: Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    const Self = @This();

    pub fn buildMls(self: Self, b: *Build, build_step: *Step) *Build.Module {
        const lib = b.addStaticLibrary(.{
            .name = "mls",
            .target = self.target,
            .optimize = self.optimize,
            .pic = true,
            .link_libc = true,
        });

        lib.addCSourceFiles(.{
            .root = b.path("src/mls"),
            .files = &.{"mls.c"},
            .flags = &.{
                "-std=c11",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-Wpedantic",
            },
        });

        lib.root_module.sanitize_c = true;

        lib.installHeadersDirectory(b.path("src/mls"), &.{}, .{});
        build_step.dependOn(&b.addInstallArtifact(lib, .{}).step);

        const module = b.addModule("mls", .{
            .root_source_file = b.path("src/mls/mls.zig"),
            .link_libc = true,
        });

        module.linkLibrary(lib);

        return module;
    }

    pub fn buildPrelude(self: Self, b: *Build, build_step: *Step, dep_mls: *Build.Module) *Step.Compile {
        const lib = b.addStaticLibrary(.{
            .name = "prelude",
            .root_source_file = b.path("src/prelude/prelude.zig"),
            .target = self.target,
            .optimize = self.optimize,
            .pic = true,
        });

        lib.root_module.addImport("mls", dep_mls);

        // NOTE:
        // > For a framework, it’s the shared library framework and must have the same name as the framework but without
        // > the .framework extension.
        // @cite https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleexecutable#Discussion
        if (self.target.result.os.tag == .ios) {
            // NOTE: The header file is referenced directly in the Project.swift. Xcode uses it to generate a modulemap.
            const install_lib = b.addInstallFileWithDir(lib.getEmittedBin(), .lib, "Prelude");
            install_lib.step.dependOn(&lib.step);

            build_step.dependOn(&install_lib.step);
        } else {
            lib.installHeadersDirectory(b.path("src/prelude"), &.{}, .{});
            build_step.dependOn(&b.addInstallArtifact(lib, .{}).step);
        }

        return lib;
    }
};

pub fn build(b: *Build) void {
    const steps = .{
        .install = b.getInstallStep(),
        .lib_mls = b.step(
            "lib:mls",
            "An implementation of the Message Layer Security (MLS) protocol in C11 with Zig bindings",
        ),
        .lib_prelude = b.step("lib:prelude", "The backbone of Dev71 applications"),
    };

    const builder: Builder = .{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    };

    const module_mls = builder.buildMls(b, steps.lib_mls);
    _ = builder.buildPrelude(b, steps.lib_prelude, module_mls);

    steps.install.dependOn(steps.lib_mls);
    steps.install.dependOn(steps.lib_prelude);
}

comptime {
    const current = builtin.zig_version;
    const required: std.SemanticVersion = .{ .major = 0, .minor = 13, .patch = 0 };

    if (current.major != required.major or current.minor != required.minor)
        @compileError(
            std.fmt.comptimePrint("Build requires Zig {}. Current version is {}.", .{ current, required }),
        );
}
