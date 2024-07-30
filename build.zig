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
    "printenv",
    "sponge",
    "nohup",
    "setsid",
    "chroot",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    // Add all command executables.
    inline for (commands) |cmd| {
        const main_file = GenerateMainFileStep.create(b, cmd);

        // register executable.
        const exe = b.addExecutable(.{
            .name = cmd,
            .root_source_file = main_file.getSource(),
            .target = target,
            .optimize = mode,
            .link_libc = true,
        });

        b.installArtifact(exe);

        const exe_install = b.addInstallArtifact(exe, .{});

        // add per-executable build step.
        const build_step = b.step("bin-" ++ cmd, "Build `" ++ cmd ++ "`");
        build_step.dependOn(&exe_install.step);

        // add run step for each command.
        const exe_run = b.addRunArtifact(exe);
        exe_run.step.dependOn(&exe_install.step);
        if (b.args) |args| {
            exe_run.addArgs(args);
        }

        const run_step = b.step("run-" ++ cmd, "Run `" ++ cmd ++ "`");
        run_step.dependOn(&exe_run.step);
    }

    const test_util_step = b.step("test-util", "test utility functions");

    const test_errno = b.addTest(.{
        .root_source_file = b.path("src/util/errno.zig"),
        .link_libc = true,
    });
    test_util_step.dependOn(&test_errno.step);

    const test_mode = b.addTest(.{
        .root_source_file = b.path("src/util/mode.zig"),
        .link_libc = true,
    });
    test_util_step.dependOn(&test_mode.step);

    const test_args = b.addTest(.{
        .root_source_file = b.path("src/util/args.zig"),
        .link_libc = true,
    });
    test_util_step.dependOn(&test_args.step);
}
