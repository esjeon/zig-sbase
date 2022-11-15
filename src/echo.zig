const std = @import("std");
const util = @import("./util.zig");

pub fn usage() noreturn {
    util.eprintf("usage: {s} [-n] [string ...]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();
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
    defer stdout_buffer.flush() catch {};

    if (args.nextPositional()) |arg|
        try stdout.print("{s}", .{arg});

    while (args.nextPositional()) |arg|
        try stdout.print(" {s}", .{arg});

    if (!nflag)
        try stdout.print("\n", .{});

    return 0;
}
