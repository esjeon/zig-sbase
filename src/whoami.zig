const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;
const errno = @import("util/errno.zig");

const c = @cImport({
    @cInclude("unistd.h");
    @cInclude("pwd.h");
});

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    eprintf("usage: {s}\n", .{name}, .{.exit=1});
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

    const uid = c.geteuid();
    errno.set(0);
    var pw = c.getpwuid(uid);
    if (pw == null) {
        if (errno.get() == 0) {
            eprintf("getpwuid {d}: no such user\n", .{uid}, .{});
        } else {
            eprintf("getpwuid {d}:", .{uid}, .{.perror=true});
        }
        unreachable;
    }
    const name = std.mem.sliceTo(pw.*.pw_name, 0);
    try stdout.print("{s}\n", .{name});

    return 0;
}
