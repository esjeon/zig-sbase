const std = @import("std");
const ArgReader = @import("argreader.zig").ArgReader;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    std.debug.print("usage: {s} file\n", .{name});
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
	const pathname = args.nextPositional().?;
	try std.os.unlink(pathname);

    return 0;
}
