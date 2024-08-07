const std = @import("std");
const util = @import("./util.zig");
const c = @cImport({
    @cInclude("sys/stat.h");
});

pub fn usage() noreturn {
    util.eprintf("usage: {s} [-m mode] name ...\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    var mode: c.mode_t = 0o666;
    var ret: u8 = 0;

    while (args.nextFlag()) |flag| {
        switch (flag) {
            'm' => {
                const str = args.readString() catch
                    util.eprintf("expect an argument for -m flag\n", .{}, .{});
                mode = util.parseMode(str, mode, c.umask(0)) catch
                    util.eprintf("invalid file mode: {s}\n", .{str}, .{});
            },
            else => usage(),
        }
    }

    if (args.countRest() == 0)
        usage();

    while (args.nextPositionalRaw()) |path| {
        if (c.mkfifo(path, mode) < 0) {
            util.weprintf("mkfifo {s}:", .{path}, .{ .perror = true });
            ret = 1;
        }
    }

    return ret;
}
