const std = @import("std");
const util = @import("./util.zig");

pub extern "c" fn ttyname(c_int) ?[*:0]u8;

pub fn usage() noreturn {
    util.eprintf("usage: {s}\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    if (args.countRest() != 0)
        usage();

    var stdout = std.io.getStdOut().writer();

    var c_tty = ttyname(0) orelse {
        try stdout.writeAll("not a tty\n");
        return 1;
    };

    try stdout.print("{s}\n", .{std.mem.sliceTo(c_tty, 0)});
    return 0;
}
