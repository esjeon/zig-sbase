const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;
const sliceTo = std.mem.sliceTo;

extern "c" fn getlogin() ?[*:0]const u8;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    std.debug.print("usage: {s}\n", .{name});
    std.os.exit(1);
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);

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
        eprintf("no login name\n", .{}, .{});
    }

    return 0;
}
