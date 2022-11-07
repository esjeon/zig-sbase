const std = @import("std");
const util = @import("./util.zig");

pub fn usage() void {
    util.eprintf("usage: {s} target name\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_| {
        usage();
    }

    if (args.countRest() != 2) {
        usage();
    }

    const oldpath = args.nextPositional().?;
    const newpath = args.nextPositional().?;
    try std.os.link(oldpath, newpath, 0);

    return 0;
}
