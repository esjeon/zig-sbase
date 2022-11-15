const std = @import("std");
const util = @import("./util.zig");

pub fn usage() noreturn {
    util.eprintf("usage: {s} path\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    var stdout = std.io.getStdOut().writer();

    while (args.nextPositional()) |arg| {
        const dirname = std.fs.path.dirname(arg) orelse "/";
        try stdout.print("{s}\n", .{dirname});
    }

    return 0;
}
