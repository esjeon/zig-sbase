const std = @import("std");

pub fn modMain() !u8 {
    var argv = std.os.argv;
    var s: []const u8 = if (argv.len >= 2) std.mem.sliceTo(argv[1], 0) else "y";

    var stdout = std.io.getStdOut();
    while (true) {
        try stdout.writeAll(s);
        try stdout.writeAll("\n");
    }
    return 0;
}
