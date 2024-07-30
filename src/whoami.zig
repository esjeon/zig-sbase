const std = @import("std");
const util = @import("./util.zig");
const errno = @import("util/errno.zig");

const c = @cImport({
    @cInclude("unistd.h");
    @cInclude("pwd.h");
});

pub fn usage() noreturn {
    util.eprintf("usage: {s}\n", .{util.getArgv0()}, .{ .exit = 1 });
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    if (args.countRest() != 0)
        usage();

    var stdout = std.io.getStdOut().writer();

    const uid = c.geteuid();
    errno.set(0);
    const pw = c.getpwuid(uid);
    if (pw == null) {
        if (errno.get() == 0) {
            util.eprintf("getpwuid {d}: no such user\n", .{uid}, .{});
        } else {
            util.eprintf("getpwuid {d}:", .{uid}, .{ .perror = true });
        }
        unreachable;
    }
    const name = std.mem.sliceTo(pw.*.pw_name, 0);
    try stdout.print("{s}\n", .{name});

    return 0;
}
