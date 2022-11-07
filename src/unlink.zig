const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    eprintf("usage: {s} file\n", .{name}, .{});
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);

    while (args.nextFlag()) |_| {
        usage();
    }

    if (args.countRest() != 1) {
        usage();
    }
    const pathname = args.nextPositional().?;
    try std.os.unlink(pathname);

    return 0;
}
