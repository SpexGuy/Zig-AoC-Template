const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

const required_zig_version = std.SemanticVersion.parse("0.10.0") catch unreachable;
const padded_int_fix = std.SemanticVersion.parse("0.11.0-dev.331+304e82808") catch unreachable;

/// set this to true to link libc
const should_link_libc = false;

fn linkObject(b: *Builder, obj: *LibExeObjStep) void {
    if (should_link_libc) obj.linkLibC();
    _ = b;

    // Padded integers are buggy in 0.10.0, fixed in 0.11.0-dev.331+304e82808
    // This is especially bad for AoC because std.StaticBitSet is commonly used.
    // If your version is older than that, we use stage1 to avoid this bug.
    // Issue: https://github.com/ziglang/zig/issues/13480
    // Fix: https://github.com/ziglang/zig/pull/13637
    if (comptime @import("builtin").zig_version.order(padded_int_fix) == .lt) {
        obj.use_stage1 = true;
    }

    // Add linking for packages or third party libraries here
}

pub fn build(b: *Builder) void {
    if (comptime @import("builtin").zig_version.order(required_zig_version) == .lt) {
        std.debug.print(
            \\Error: Your version of Zig is missing features that are needed for this template.
            \\You will need to download a newer build.
            \\
            \\    https://ziglang.org/download/
            \\
            \\
        , .{});
        std.os.exit(1);
    }

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const install_all = b.step("install_all", "Install all days");
    const install_all_tests = b.step("install_tests_all", "Install tests for all days");
    const run_all = b.step("run_all", "Run all days");

    const generate = b.step("generate", "Generate stub files from template/template.zig");
    const build_generate = b.addExecutable("generate", "template/generate.zig");
    build_generate.setBuildMode(.ReleaseSafe);
    const run_generate = build_generate.run();
    run_generate.cwd = std.fs.path.dirname(@src().file).?;
    generate.dependOn(&run_generate.step);

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

        const run_test = b.addTest(zigFile);
        run_test.setTarget(target);
        run_test.setBuildMode(mode);
        linkObject(b, exe);

        const build_test = b.addTestExe(b.fmt("test_{s}", .{dayString}), zigFile);
        build_test.setTarget(target);
        build_test.setBuildMode(mode);
        linkObject(b, exe);
        const install_test = b.addInstallArtifact(build_test);

        {
            const step_key = b.fmt("install_{s}", .{dayString});
            const step_desc = b.fmt("Install {s}.exe", .{dayString});
            const install_step = b.step(step_key, step_desc);
            install_step.dependOn(&install_cmd.step);
            install_all.dependOn(&install_cmd.step);
        }

        {
            const step_key = b.fmt("test_{s}", .{dayString});
            const step_desc = b.fmt("Run tests in {s}", .{zigFile});
            const step = b.step(step_key, step_desc);
            step.dependOn(&run_test.step);
        }

        {
            const step_key = b.fmt("install_tests_{s}", .{dayString});
            const step_desc = b.fmt("Install test_{s}.exe", .{dayString});
            const step = b.step(step_key, step_desc);
            step.dependOn(&install_test.step);
            install_all_tests.dependOn(&install_test.step);
        }

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

    // Set up tests for util.zig
    {
        const test_util = b.step("test_util", "Run tests in util.zig");
        const test_cmd = b.addTest("src/util.zig");
        test_cmd.setTarget(target);
        test_cmd.setBuildMode(mode);
        linkObject(b, test_cmd);
        test_util.dependOn(&test_cmd.step);
    }

    // Set up test executable for util.zig
    {
        const test_util = b.step("install_tests_util", "Run tests in util.zig");
        const test_exe = b.addTestExe("test_util", "src/util.zig");
        test_exe.setTarget(target);
        test_exe.setBuildMode(mode);
        linkObject(b, test_exe);
        const install = b.addInstallArtifact(test_exe);
        test_util.dependOn(&install.step);
    }

    // Set up a step to run all tests
    {
        const test_step = b.step("test", "Run all tests");
        const test_cmd = b.addTest("src/test_all.zig");
        test_cmd.setTarget(target);
        test_cmd.setBuildMode(mode);
        linkObject(b, test_cmd);
        test_step.dependOn(&test_cmd.step);
    }

    // Set up a step to build tests (but not run them)
    {
        const test_build = b.step("install_tests", "Install test_all.exe");
        const test_exe = b.addTestExe("test_all", "src/test_all.zig");
        test_exe.setTarget(target);
        test_exe.setBuildMode(mode);
        linkObject(b, test_exe);
        const test_exe_install = b.addInstallArtifact(test_exe);
        test_build.dependOn(&test_exe_install.step);
    }
}
