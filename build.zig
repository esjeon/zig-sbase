const std = @import("std");

const commands = [_][]const u8 {
    "false",
    "true",
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Add all command executables.
    inline for (commands) |cmd| {
        // register executable.
        const exe = b.addExecutable(cmd, "src/" ++ cmd ++ ".zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        // add per-executable build step.
        const build_step = b.step("bin-" ++ cmd, "Build `" ++ cmd ++ "`");
        build_step.dependOn(&(exe.install_step orelse unreachable).step);
    }
}
