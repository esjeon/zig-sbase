const std = @import("std");
const util = @import("./util.zig");
const sliceTo = std.mem.sliceTo;

extern "c" fn getlogin() ?[*:0]const u8;

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

    const name = getlogin();
    if (name) |n| {
        try stdout.print("{s}\n", .{sliceTo(n, 0)});
    } else {
        util.eprintf("no login name\n", .{}, .{});
    }

    return 0;
}
