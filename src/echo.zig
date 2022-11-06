const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;
const eprintf = @import("util/eprintf.zig").eprintf;

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    eprintf("usage: {s} [-n] [string ...]", .{name}, .{});
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);
    var nflag = false;

    while (args.nextFlag()) |flag| {
        switch (flag) {
            'n' => {
                nflag = true;
            },
            else => usage(),
        }
    }

    var stdout_buffer = std.io.bufferedWriter(std.io.getStdOut().writer());
    var stdout = stdout_buffer.writer();
    defer stdout_buffer.flush() catch unreachable;

    if (args.nextPositional()) |arg|
        try stdout.print("{s}", .{arg});

    while (args.nextPositional()) |arg|
        try stdout.print(" {s}", .{arg});

    if (!nflag)
        try stdout.print("\n", .{});

    return 0;
}
