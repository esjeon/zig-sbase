const std = @import("std");
const util = @import("./util.zig");
const sliceTo = std.mem.sliceTo;

extern "c" fn gethostname(name: [*:0]const u8, len: usize) c_int;

// NOTE: `sethostname` receives length separately, thus doesn't require sentinel in `name`.
extern "c" fn sethostname(name: [*]const u8, len: usize) c_int;

pub fn usage() noreturn {
    util.eprintf("usage: {s} [name]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    var stdout = std.io.getStdOut().writer();
    var buf: [std.posix.HOST_NAME_MAX:0]u8 = undefined;

    switch (args.countRest()) {
        0 => {
            if (gethostname(&buf, buf.len) < 0)
                util.eprintf("gethostname:", .{}, .{ .perror = true });
            stdout.print("{s}\n", .{sliceTo(&buf, 0)}) catch {};
        },
        1 => {
            const name = args.nextPositional().?;
            if (sethostname(name.ptr, name.len) < 0)
                util.eprintf("sethostname:", .{}, .{ .perror = true });
        },
        else => usage(),
    }

    return 0;
}
