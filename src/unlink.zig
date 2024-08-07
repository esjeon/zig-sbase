const std = @import("std");
const util = @import("./util.zig");

pub fn usage() noreturn {
    util.eprintf("usage: {s} file\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    if (args.countRest() != 1)
        usage();

    const pathname = args.nextPositional().?;

    try std.posix.unlink(pathname);
    return 0;
}
