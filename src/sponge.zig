const std = @import("std");
const util = @import("./util.zig");
const c = @cImport({
    @cInclude("stdlib.h");
});

pub fn usage() noreturn {
    util.eprintf("usage: {s} [-n] [string ...]\n", .{util.getArgv0()}, .{});
}

fn copyData(src: std.fs.File, dest: std.fs.File) !void {
    var buf: [8192]u8 = undefined;
    while (src.read(&buf)) |cnt| {
        if (cnt == 0) break;
        var wbuf: []u8 = buf[0..cnt];
        try dest.writeAll(wbuf);
    } else |err| {
        return err;
    }
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_| {
        usage();
    }

    if (args.countRest() != 1) {
        usage();
    }

    const outpath = args.nextPositional().?;
    const template = "/tmp/sponge-XXXXXX";

    // `mkstemp` modifies the provided string, so we need a writable buffer.
    var tmppath_buf = std.mem.zeroes([std.fs.MAX_PATH_BYTES:0]u8);
    std.mem.copy(u8, &tmppath_buf, template);

    // Create temp file and update the name.
    const tmpfd = c.mkstemp(&tmppath_buf);
    if (tmpfd < 0)
        util.eprintf("mkstemp:", .{}, .{ .perror = true });

    // Open the temporary file again using the standard API.
    const tmppath = std.mem.sliceTo(&tmppath_buf, 0);
    const tmpfile = try std.fs.openFileAbsolute(tmppath, .{
        .mode = .read_write,
    });

    // Close unnecessary file descriptor.
    std.os.close(tmpfd);

    // Unlink the file early.
    std.os.unlink(tmppath) catch {};

    // Dump everything to the temporary file.
    try copyData(std.io.getStdIn(), tmpfile);

    // Create the output file.
    var outfile = try std.fs.cwd().createFile(outpath, .{
        .read = false,
        .truncate = true,
        .mode = 0o666,
    });

    // Move from temporary to output.
    try tmpfile.seekTo(0);
    try copyData(tmpfile, outfile);

    return 0;
}
