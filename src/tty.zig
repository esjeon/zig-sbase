const std = @import("std");
const ArgReader = @import("argreader.zig").ArgReader;

pub extern "c" fn ttyname(c_int) ?[*:0]u8;

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

    if (ttyname(0)) |tty| {
        const ttyslice = std.mem.sliceTo(tty, 0);
        try stdout.print("{s}\n", .{ttyslice});
        return 0;
    } else {
        try stdout.writeAll("not a tty\n");
        return 1;
    }

}
