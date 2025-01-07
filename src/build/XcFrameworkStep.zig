//! Adapted from Mitchell Hashimoto's awesome blog post:
//! https://mitchellh.com/writing/zig-and-swiftui#creating-an-xcframework

const std = @import("std");

const Step = std.Build.Step;
const RunStep = std.Build.Step.Run;
const LazyPath = std.Build.LazyPath;

const XcFrameworkStep = @This();

pub const Options = struct {
    /// The name of the xcframework to create.
    name: []const u8,

    /// The libraries to bundle
    libraries: []const *Step.Compile,
};

install_dir: *Step.InstallDir,

pub fn create(b: *std.Build, opts: Options) *XcFrameworkStep {
    const self = b.allocator.create(XcFrameworkStep) catch @panic("OOM");
    const name = b.fmt("{s}.xcframework", .{opts.name});

    const run = RunStep.create(b, name);
    run.addArgs(&.{ "xcodebuild", "-create-xcframework" });

    for (opts.libraries) |lib| {
        run.step.dependOn(&lib.step);
        run.addArg("-library");
        run.addFileArg(lib.getEmittedBin());
        run.addArg("-headers");
        run.addDirectoryArg(lib.getEmittedIncludeTree());
    }

    run.addArg("-output");
    const output = run.addOutputDirectoryArg(name);

    const install_dir = b.addInstallDirectory(.{
        .source_dir = output,
        .install_dir = .prefix,
        .install_subdir = name,
    });

    install_dir.step.dependOn(&run.step);

    self.* = .{
        .install_dir = install_dir,
    };

    return self;
}
