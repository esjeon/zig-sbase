const std = @import("std");
const GenerateMainFileStep = @import("build/generatedmain.zig").GenerateMainFileStep;

const commands = [_][]const u8{
    "basename",
    "dirname",
    "echo",
    "false",
    "link",
    "logname",
    "sleep",
    "sync",
    "true",
    "tty",
    "unlink",
    "yes",
    "whoami",
    "hostname",
    "mkfifo",
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Add all command executables.
    inline for (commands) |cmd| {
        const main_file = GenerateMainFileStep.create(b, cmd);

        // register executable.
        const exe = b.addExecutableSource(cmd, main_file.getSource());
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.linkLibC();
        exe.install();

        const exe_install = exe.install_step orelse unreachable;

        // add per-executable build step.
        const build_step = b.step("bin-" ++ cmd, "Build `" ++ cmd ++ "`");
        build_step.dependOn(&exe_install.step);

        // add run step for each command.
        const exe_run = exe.run();
        exe_run.step.dependOn(&exe_install.step);
        if (b.args) |args| {
            exe_run.addArgs(args);
        }

        const run_step = b.step("run-" ++ cmd, "Run `" ++ cmd ++ "`");
        run_step.dependOn(&exe_run.step);
    }

    const test_util_step = b.step("test-util", "test utility functions");

    const test_errno = b.addTest("src/util/errno.zig");
    test_errno.linkLibC();
    test_util_step.dependOn(&test_errno.step);

    const test_mode = b.addTest("src/util/mode.zig");
    test_mode.linkLibC();
    test_util_step.dependOn(&test_mode.step);

    const test_args = b.addTest("src/util/args.zig");
    test_util_step.dependOn(&test_args.step);
}
