const std = @import("std");
const util = @import("./util.zig");

pub fn usage() void {
    util.eprintf("usage: {s} path\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_| {
        usage();
    }

    var stdout = std.io.getStdOut();
    while (args.nextPositional()) |arg| {
        if (std.fs.path.dirname(arg)) |dirname| {
            try stdout.writeAll(dirname);
            try stdout.writeAll("\n");
        } else {
            try stdout.writeAll("/\n");
        }
    }

    return 0;
}
