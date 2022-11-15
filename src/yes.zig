const std = @import("std");
const util = @import("util.zig");

pub fn usage() noreturn {
    util.eprintf("usage: yes [string]\n", .{}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    var s: []const u8 = switch (args.countRest()) {
        0 => "y",
        1 => args.nextPositional().?,
        else => usage(),
    };

    var stdout = std.io.getStdOut();
    while (true) {
        try stdout.writeAll(s);
        try stdout.writeAll("\n");
    }
    return 0;
}
