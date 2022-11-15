const std = @import("std");
const util = @import("./util.zig");

pub fn usage() noreturn {
    util.eprintf("usage: {s} path [suffix]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    const path = args.nextPositional() orelse usage();
    const opt_suffix = args.nextPositional();
    if (args.countRest() > 0) usage();

    var name = std.fs.path.basename(path);
    if (opt_suffix) |suffix| {
        if (std.mem.endsWith(u8, name, suffix))
            name = name[0 .. name.len - suffix.len];
    }

    var stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{name});
    return 0;
}
