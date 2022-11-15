const std = @import("std");
const util = @import("./util.zig");
const c = @cImport({
    @cInclude("stdlib.h");
});

pub fn usage() noreturn {
    util.eprintf("usage: {s} file\n", .{util.getArgv0()}, .{});
}

fn copyData(src: std.fs.File, dest: std.fs.File) !void {
    var buf: [8192]u8 = undefined;
    while (src.read(&buf)) |cnt| {
        if (cnt == 0) break;
        try dest.writeAll(buf[0..cnt]);
    } else |err| {
        return err;
    }
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    if (args.countRest() != 1)
        usage();

    const outpath = args.nextPositional().?;
    const tmpl = "/tmp/sponge-XXXXXX";

    // `mkstemp` modifies the provided string, so we need a writable buffer.
    var tmpl_buf = std.mem.zeroes([tmpl.len + 1:0]u8);
    std.mem.copy(u8, &tmpl_buf, tmpl);

    {
        const tmpfd = c.mkstemp(&tmpl_buf);
        if (tmpfd < 0)
            util.eprintf("mkstemp:", .{}, .{ .perror = true });
        std.os.close(tmpfd);
    }

    const tmppath = std.mem.sliceTo(&tmpl_buf, 0);

    const tmpfile = try std.fs.openFileAbsolute(tmppath, .{
        .mode = .read_write,
    });
    std.os.unlink(tmppath) catch {};

    try copyData(std.io.getStdIn(), tmpfile);

    var outfile = try std.fs.cwd().createFile(outpath, .{
        .read = false,
        .truncate = true,
        .mode = 0o666,
    });
    try tmpfile.seekTo(0);
    try copyData(tmpfile, outfile);

    return 0;
}
