const std = @import("std");

pub fn modMain() !u8 {
    var argv: [][*:0]const u8 = std.os.argv;
    var i: u8 = 1;
    var nflag = false;
    var first = true;

    if (i < argv.len and argv[i] == "-n") {
        nflag = true;
        i += 1;
    }

    var stdout_buffer = std.io.bufferedWriter(std.io.getStdOut().writer());
    var stdout = stdout_buffer.writer();
    defer stdout_buffer.flush() catch unreachable;

    while (i < argv.len) {
        if (!first) {
            try stdout.writeAll(" ");
        }
        try stdout.writeAll(std.mem.sliceTo(argv[i], 0));

        i += 1;
        first = false;
    }
    if (!nflag) {
        try stdout.writeAll("\n");
    }

    return 0;
}
