const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    std.debug.print("usage: {s} num\n", .{name});
    std.os.exit(1);
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);

    while (args.nextFlag()) |_| {
        usage();
    }

	if (args.countRest() != 1) {
		usage();
	}

    const sec = try std.fmt.parseInt(u64, args.nextPositional().?, 10);
    std.time.sleep(sec * 1000 * 1000 * 1000);

    return 0;
}
