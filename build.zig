const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

// set this to true to link libc
const should_link_libc = false;

const test_files = [_][]const u8{
    // list any zig files with tests here
};

fn linkObject(b: *Builder, obj: *LibExeObjStep) void {
    if (should_link_libc) obj.linkLibC();
    _ = b;

    // Add linking for packages or third party libraries here
}

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const install_all = b.step("install_all", "Install all days");
    const run_all = b.step("run_all", "Run all days");

    // Set up an exe for each day
    var day: u32 = 1;
    while (day <= 25) : (day += 1) {
        const dayString = b.fmt("day{:0>2}", .{day});
        const zigFile = b.fmt("src/{s}.zig", .{dayString});

        const exe = b.addExecutable(dayString, zigFile);
        exe.setTarget(target);
        exe.setBuildMode(mode);
        linkObject(b, exe);

        exe.install();

        const install_cmd = b.addInstallArtifact(exe);

        const step_key = b.fmt("install_{s}", .{dayString});
        const step_desc = b.fmt("Install {s}.exe", .{dayString});
        const install_step = b.step(step_key, step_desc);
        install_step.dependOn(&install_cmd.step);
        install_all.dependOn(&install_cmd.step);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(&install_cmd.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_desc = b.fmt("Run {s}", .{dayString});
        const run_step = b.step(dayString, run_desc);
        run_step.dependOn(&run_cmd.step);
        run_all.dependOn(&run_cmd.step);
    }

    // Set up a step to run all tests
    const test_step = b.step("test", "Run all tests");
    for (test_files) |file| {
        const test_cmd = b.addTest(file);
        test_cmd.setTarget(target);
        test_cmd.setBuildMode(mode);
        linkObject(b, test_cmd);

        test_step.dependOn(&test_cmd.step);
    }
}
