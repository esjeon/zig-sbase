const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    eprintf("usage: {s} path\n", .{name}, .{});
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);

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
