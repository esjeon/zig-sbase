const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    eprintf("usage: {s} path [suffix]\n", .{name}, .{});
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);

    while (args.nextFlag()) |_| {
        usage();
    }

    const argc = args.countRest();
    if (argc != 1 and argc != 2) {
        usage();
    }

    const path = args.nextPositional().?;
    var name = std.fs.path.basename(path);
    if (argc == 2) {
        const suffix = args.nextPositional().?;
        if (std.mem.endsWith(u8, name, suffix)) {
            name = name[0 .. name.len - suffix.len];
        }
    }

    var stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{name});

    return 0;
}
