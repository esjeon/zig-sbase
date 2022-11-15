const std = @import("std");
const util = @import("./util.zig");

pub fn usage() noreturn {
    util.eprintf("usage: {s} [var ...]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();
    var ret: u8 = 0;

    while (args.nextFlag()) |flag| {
        switch (flag) {
            else => usage(),
        }
    }

    var stdio_buf = std.io.bufferedWriter(std.io.getStdIn().writer());
    var stdio = stdio_buf.writer();

    if (args.countRest() == 0) {
        for (std.os.environ) |ptr| {
            try stdio.print("{s}\n", .{std.mem.sliceTo(ptr, 0)});
        }
    } else {
        while (args.nextPositional()) |key| {
            if (std.os.getenv(key)) |value| {
                try stdio.print("{s}\n", .{value});
            } else {
                ret = 1;
            }
        }
    }

    try stdio_buf.flush();
    return 0;
}
