const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;
const sliceTo = std.mem.sliceTo;

extern "c" fn gethostname(name: [*:0]const u8, len: usize) c_int;

// NOTE: `sethostname` receives length separately, thus doesn't require sentinel in `name`.
extern "c" fn sethostname(name: [*]const u8, len: usize) c_int;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    eprintf("usage: {s} [name]\n", .{name}, .{});
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);
    var buf: [std.os.HOST_NAME_MAX:0]u8 = undefined;

    while (args.nextFlag()) |_| {
        usage();
    }

    var stdout = std.io.getStdOut().writer();
    if (args.countRest() == 0) {
        if (gethostname(&buf, buf.len) < 0)
            eprintf("gethostname:", .{}, .{ .perror = true });
        try stdout.print("{s}\n", .{sliceTo(&buf, 0)});
    } else if (args.countRest() == 1) {
        const name = args.nextPositional().?;
        if (sethostname(name.ptr, name.len) < 0)
            eprintf("sethostname:", .{}, .{ .perror = true });
    } else {
        usage();
    }

    return 0;
}
