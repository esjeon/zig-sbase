const std = @import("std");

extern "c" fn perror([*c]const u8) void;

pub fn eprintf(comptime fmt: []const u8, args: anytype, comptime opts: anytype) noreturn {
    const stderr = std.io.getStdErr().writer();

    if (!std.mem.startsWith(u8, fmt, "usage")) {
        const argv0 = std.mem.sliceTo(std.os.argv[0], 0);
        stderr.print("{s}: ", .{argv0}) catch {};
    }
    stderr.print(fmt, args) catch {};

    if (@hasField(@TypeOf(opts), "perror")) {
        if (opts.perror == true) {
            _ = stderr.write(" ") catch {};
            perror(null);
        }
    }

    if (@hasField(@TypeOf(opts), "exit")) {
        std.os.exit(opts.exit);
    } else {
        std.os.exit(1);
    }
}
