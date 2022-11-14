const std = @import("std");

extern "c" fn perror([*c]const u8) void;

pub fn weprintf(comptime fmt: []const u8, args: anytype, comptime opts: anytype) void {
    const stderr = std.io.getStdErr().writer();

    if (!std.mem.startsWith(u8, fmt, "usage")) {
        const argv0 = std.mem.sliceTo(std.os.argv[0], 0);
        stderr.print("{s}: ", .{argv0}) catch {};
    }
    stderr.print(fmt, args) catch {};

    if (std.mem.endsWith(u8, fmt, ":") or
        (@hasField(@TypeOf(opts), "perror") and opts.perror == true))
    {
        _ = stderr.write(" ") catch {};
        perror(null);
    }
}

pub fn eprintf(comptime fmt: []const u8, args: anytype, comptime opts: anytype) noreturn {
    weprintf(fmt, args, opts);

    if (@hasField(@TypeOf(opts), "exit")) {
        std.os.exit(opts.exit);
    } else {
        std.os.exit(1);
    }
}
