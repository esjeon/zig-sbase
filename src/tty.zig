const std = @import("std");
const util = @import("./util.zig");

pub extern "c" fn ttyname(c_int) ?[*:0]u8;

pub fn usage() void {
    util.eprintf("usage: {s}\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_| {
        usage();
    }

    if (args.countRest() != 0) {
        usage();
    }

    var stdout = std.io.getStdOut().writer();

    if (ttyname(0)) |tty| {
        const ttyslice = std.mem.sliceTo(tty, 0);
        try stdout.print("{s}\n", .{ttyslice});
        return 0;
    } else {
        try stdout.writeAll("not a tty\n");
        return 1;
    }
}
