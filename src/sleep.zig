const std = @import("std");
const util = @import("./util.zig");

pub fn usage() void {
    util.eprintf("usage: {s} num\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

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
