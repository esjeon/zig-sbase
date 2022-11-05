const std = @import("std");
const GenerateMainFileStep  = @import("build/generatedmain.zig").GenerateMainFileStep;

const commands = [_][]const u8 {
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
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Add all command executables.
    inline for (commands) |cmd| {
        const main_file = GenerateMainFileStep.create(b, cmd);

        // register executable.
        // const exe = b.addExecutable(cmd, "src/" ++ cmd ++ ".zig");
        const exe = b.addExecutableSource(cmd, main_file.getSource());
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.linkLibC();
        exe.install();

        // add per-executable build step.
        const build_step = b.step("bin-" ++ cmd, "Build `" ++ cmd ++ "`");
        build_step.dependOn(&(exe.install_step orelse unreachable).step);
    }
}
