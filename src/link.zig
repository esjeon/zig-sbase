const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    eprintf("usage: {s} target name\n", .{name}, .{});
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);

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
