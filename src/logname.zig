const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;

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

    // NOTE: the musl implementation of `getenv` only reads env var, but glibc
    // goes further and reads the info of the controlling TTY.
    //
    // Here, the musl approach is implemented.
	if (std.os.getenv("LOGNAME")) |logname| {
        try stdout.print("{s}\n", .{logname});
    } else {
        try stdout.writeAll("no login name\n");
    }

    return 0;
}
