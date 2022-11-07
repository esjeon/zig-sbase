const std = @import("std");
const util = @import("./util.zig");

pub fn usage() void {
    util.eprintf("usage: {s} path [suffix]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

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
