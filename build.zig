const std = @import("std");
const Build = std.Build;
const CompileStep = std.Build.Step.Compile;

/// set this to true to link libc
const should_link_libc = false;

fn linkObject(b: *Build, obj: *CompileStep) void {
    if (should_link_libc) obj.linkLibC();
    _ = b;

    // Add linking for packages or third party libraries here
}

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const install_all = b.step("install_all", "Install all days");
    const install_all_tests = b.step("install_tests_all", "Install tests for all days");
    _ = install_all_tests;
    const run_all = b.step("run_all", "Run all days");

    const generate = b.step("generate", "Generate stub files from template/template.zig");
    const build_generate = b.addExecutable(.{
        .name = "generate",
        .root_source_file = .{ .path = "template/generate.zig" },
        .optimize = .ReleaseSafe,
    });

    const run_generate = b.addRunArtifact(build_generate);
    run_generate.setCwd(.{ .path = std.fs.path.dirname(@src().file).? });
    generate.dependOn(&run_generate.step);

    // Set up an exe for each day
    var day: u32 = 1;
    while (day <= 25) : (day += 1) {
        const dayString = b.fmt("day{:0>2}", .{day});
        const zigFile = b.fmt("src/{s}.zig", .{dayString});

        const exe = b.addExecutable(.{
            .name = dayString,
            .root_source_file = .{ .path = zigFile },
            .target = target,
            .optimize = mode,
        });
        linkObject(b, exe);
        // b.installArtifact(exe);

        const install_cmd = b.addInstallArtifact(exe, .{});

        const build_test = b.addTest(.{
            .root_source_file = .{ .path = zigFile },
            .target = target,
            .optimize = mode,
        });
        linkObject(b, build_test);

        const run_test = b.addRunArtifact(build_test);

        // const build_test = b.addTestExe(b.fmt("test_{s}", .{dayString}), zigFile);
        // build_test.setTarget(target);
        // build_test.setBuildMode(mode);
        // linkObject(b, exe);
        // const install_test = b.addInstallArtifact(build_test);

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

        const run_cmd = b.addRunArtifact(exe);
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
        const test_cmd = b.addTest(.{
            .root_source_file = .{ .path = "src/util.zig" },
            .target = target,
            .optimize = mode,
        });
        linkObject(b, test_cmd);
        test_util.dependOn(&test_cmd.step);
    }
}
